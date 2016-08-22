#!/bin/bash

SESSION=org.coanda.Dactl.UI.Manager
PATH="/org/coanda/dactl/ui/manager"

function dbus_call {
    _s=$1
    _p=$2
    _m=$_s.$3
    _d=$4

    if [ -n "$_d" ]; then
        echo $_d
        /usr/bin/gdbus call --session \
            --dest $_s \
            --object-path $_p \
            --method $_m \
            "$_d"
    else
        /usr/bin/gdbus call --session \
            --dest $_s \
            --object-path $_p \
            --method $_m
    fi
}

read -r -d '' JSON << EOM
{
  'type': 'DactlUIWindow',
  'properties': {
    'dest': '',
    'id': 'win0'
  },
  'objects': [{
    'type': 'DactlPage',
      'properties': {
        'dest': 'win0',
        'id': 'pg1',
      },
      'objects': [{
        'type': 'DactlBox',
        'properties': {
          'dest': 'pg1',
          'id': 'box0',
          'orientation': 'horizontal'
        }
      }]
    }
  }]
}
EOM

#dbus_call $SESSION $PATH "AddWidget" "$JSON"

dbus_call $SESSION $PATH "AddWidget" "{ 'type': 'DactlUIWindow', 'properties': { 'dest': '', 'id': 'win0' } }"

#dbus_call $SESSION $PATH "ListPages"
dbus_call $SESSION $PATH "AddWidget" "{ 'type': 'DactlPage', 'properties': { 'dest': 'win0', 'id': 'pg1' } }"
dbus_call $SESSION $PATH "AddWidget" "{ 'type': 'DactlBox', 'properties': { 'dest': 'pg1', 'id': 'box0', 'orientation': 'horizontal' } }"
dbus_call $SESSION $PATH "AddWidget" "{ 'type': 'DactlBox', 'properties': { 'dest': 'box0', 'id': 'box0-0', 'orientation': 'vertical' } }"
dbus_call $SESSION $PATH "AddWidget" "{ 'type': 'DactlBox', 'properties': { 'dest': 'box0', 'id': 'box0-1', 'orientation': 'vertical' } }"
dbus_call $SESSION $PATH "AddWidget" "{ 'type': 'DactlUIRichContent', 'properties': { 'dest': 'box0-1', 'id': 'rc0', 'uri': 'http://10.0.2.2/~gjohn/dev/dcs/' } }"
#dbus_call $SESSION $PATH "ListPages"
