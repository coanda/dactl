# Desktop launcher and description file.
if get_option('with-ui')

install_data('config/dactl.xml',
  install_dir: join_paths (get_option('sysconfdir'), meson.project_name()),
)

desktop_file = i18n.merge_file(
  input: 'org.coanda.Dactl.desktop.in.in',
  output: 'org.coanda.Dactl.desktop',
  type: 'desktop',
  po_dir: '../po',
  install: true,
  install_dir: join_paths(get_option('datadir'), 'applications'),
)

desktop_utils = find_program('desktop-file-validate', required: false)
if desktop_utils.found()
  test('Validate desktop file', desktop_utils,
    args: [desktop_file]
  )
endif

# Appdata file.
appdata_file = i18n.merge_file(
  input: 'org.coanda.Dactl.appdata.xml.in',
  output: 'org.coanda.Dactl.appdata.xml',
  po_dir: '../po',
  install: true,
  install_dir: join_paths(get_option('datadir'), 'appdata'),
)

appstream_util = find_program('appstream-util', required: false)
if appstream_util.found()
  test('', appstream_util,
    args: ['validate-relax', appdata_file]
  )
endif

# D-Bus service file.
dbusconf = configuration_data()
dbusconf.set('bindir', join_paths(get_option('prefix'), get_option('bindir')))
configure_file(
  input: 'org.coanda.Dactl.service.in',
  output: 'org.coanda.Dactl.service',
  configuration: dbusconf,
  install: true,
  install_dir: join_paths(get_option('datadir'), 'dbus-1', 'services'),
)

endif

subdir('glade')
subdir('gsettings')
subdir('icons')
