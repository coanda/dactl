core_headers = []

core_sources = [
  'abstract-config.vala',
  'application-config.vala',
  'application-controller.vala',
  'application-factory.vala',
  'application-model.vala',
  'application.vala',
  'application-view.vala',
  'buildable.vala',
  'cld-adapter.vala',
  'config.vala',
  'container.vala',
  'dataseries.vala',
  'dbus-interface.vala',
  'factory.vala',
  'log.vala',
  'meta-config.vala',
  'module-loader.vala',
  'object.vala',
  'plugin-information.vala',
  'plugin-loader.vala',
  'plugin-manager.vala',
  'plugin.vala',
  'point.vala',
  'view.vala',
]

libdactl_headers += files(core_headers)
libdactl_sources += files(core_sources)

install_headers(core_headers,
  subdir: join_paths(libdactl_header_subdir, 'core')
)
