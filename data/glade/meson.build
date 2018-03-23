if get_option('with-ui')

configure_file(
  input: 'dactlui.xml',
  output: 'dactlui.xml',
  configuration: configuration_data(),
  install: true,
  install_dir: join_paths(get_option('datadir'), 'glade', 'catalogs'),
)

endif
