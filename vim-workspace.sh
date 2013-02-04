#!/bin/bash

package="dactl"
args="--servername $package"
srcdir="src"
tlist="TlistToggle"
nerd="NERDTreeTabsToggle"
files=(application-data.vala
       driver-data.vala
       user-interface-data.vala
       application-settings-dialog.vala
       aichannel-treeview.vala
       aochannel-treeview.vala
       calibration-treeview.vala
       coefficient-treeview.vala
       device-treeview.vala
       log-treeview.vala
       pid-box.vala
       pid-control-treeview.vala
       pid-settings-dialog.vala)

vim $args && sleep 1
args="$args --remote-send"

vim $args ":e $srcdir/main.vala | $tlist<CR>"

for file in "${files[@]}"; do
    echo Adding tab: $file
    vim $args ":tabnew $srcdir/$file | $tlist<CR>"
done

vim $args ":$nerd<CR>"
