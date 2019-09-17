if valadoc.found()

ui_doc_common_args = [
  '--package-name', 'libdactl-ui',
  '--package-version', api_version,
  '-b', join_paths(meson.source_root(), 'src', 'libdactl'),
  '--force',
  '--directory', '@OUTPUT@',
  '--vapidir', join_paths(meson.source_root(), 'vapi'),
  '--vapidir', join_paths(meson.source_root(), 'src', 'config'),
  '--vapidir', join_paths(meson.build_root(), 'src', 'libdactl'),
  '--pkg', 'dactl-config',
  '--pkg', 'dactl-1.0',
  '--pkg', 'cld-1.0',
  '--pkg', 'gio-2.0',
  '--pkg', 'gee-0.8',
  '--pkg', 'gmodule-2.0',
  '--pkg', 'gtk+-3.0',
  '--pkg', 'gtksourceview-3.0',
  '--pkg', 'libpeas-1.0',
  '--pkg', 'libpeas-gtk-1.0',
  '--pkg', 'librsvg-2.0',
  '--pkg', 'libxml-2.0',
  '--pkg', 'comedilib',
  '--pkg', 'linux',
  '--pkg', 'posix'
]

##custom_target('valadoc-ui',
##             input: libdactl_ui_sources,
##            output: 'valadoc',
##           depends: libdactl,
##  build_by_default: get_option('with-valadoc'),
##           command: [
##             valadoc,
##             ui_doc_common_args,
##             '-o', 'valadoc',
##             libdactl_ui_sources,
##           ]
##)

##if gtkdoc.found()
##  custom_target('gtkdoc-ui',
##               input: libdactl_ui_sources,
##              output: 'gtkdoc',
##             depends: libdactl,
##    build_by_default: get_option('with-gtkdoc'),
##             command: [
##               valadoc,
##               '--doclet', 'gtkdoc',
##               '-o', 'gtkdoc',
##               ui_doc_common_args,
##               '-X', join_paths(meson.build_root(), 'src/libdactl/dactl.h'),
##               '-X', '-l',
##               '-X', join_paths(meson.build_root(), 'src/libdactl/libdactl-1.0.so'),
##               '-b', join_paths(meson.source_root(), 'src', 'libdactl'),
##               libdactl_ui_sources,
##             ]
##  )
##
##  if get_option('with-gtkdoc')
##    install_subdir('gtkdoc/html',
##          install_dir: join_paths(get_option('datadir'), 'gtk-doc/html/libdactl'),
##      strip_directory: true,
##    )
##  endif
##endif

endif
