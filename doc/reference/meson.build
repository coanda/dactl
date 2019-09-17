if valadoc.found()
  core_doc_common_args = [
    '--package-name', 'libdactl',
    '--package-version', api_version,
    '-b', join_paths(meson.source_root(), 'src', 'libdactl'),
    '--force',
    '--directory', '@OUTPUT@',
    '--vapidir', join_paths(meson.source_root(), 'vapi'),
    '--vapidir', join_paths(meson.source_root(), 'src', 'config'),
    '--pkg', 'dactl-config',
    '--pkg', 'cld-1.0',
    '--pkg', 'gio-2.0',
    '--pkg', 'gee-0.8',
    '--pkg', 'gmodule-2.0',
    '--pkg', 'libpeas-1.0',
    '--pkg', 'libxml-2.0',
    '--pkg', 'comedilib',
    '--pkg', 'linux',
    '--pkg', 'posix'
 ]

  custom_target('valadoc-core',
    input: libdactl_core_sources,
    output: 'valadoc',
    depends : libdactl,
    build_by_default : get_option('with-valadoc'),
    command :
    [
      valadoc,
      core_doc_common_args,
      '-o', 'valadoc',
      libdactl_core_sources
    ]
  )

  if gtkdoc.found()
    custom_target('gtkdoc-core',
      input : libdactl_core_sources,
      output : 'gtkdoc',
      depends : libdactl,
      build_by_default : get_option('with-gtkdoc'),
      command :
      [
        valadoc,
        '--doclet', 'gtkdoc',
        '-o', 'gtkdoc',
        core_doc_common_args,
        '-X', join_paths(meson.build_root(), 'src/libdactl/dactl.h'),
        '-X', '-l',
        '-X', join_paths(meson.build_root(), 'src/libdactl/libdactl-1.0.so'),
        '-b', join_paths(meson.source_root(), 'src', 'libdactl'),
        libdactl_core_sources
      ]
    )

# TODO: implement gtkdoc creation - see https://gitlab.gnome.org/sbacher/rygel/tree/master/doc/reference/librygel-core/gtkdoc
##    if get_option('with-gtkdoc')
##      install_subdir('gtkdoc/html',
##            install_dir : join_paths(get_option('datadir'), 'gtk-doc/html/libdactl'),
##        strip_directory : true
##      )
##    endif
  endif
endif
