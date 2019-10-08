if valadoc.found()
  core_doc_common_args = [
    '--package-name', 'libdactl',
    '--package-version', api_version,
    '-b', join_paths(meson.source_root(), 'src', 'libdactl'),
    '--force',
    '--directory', '@OUTPUT@',
    '--vapidir', join_paths(meson.source_root(), 'vapi'),
    '--vapidir', join_paths(meson.source_root(), 'src', 'config'),
    '--pkg', 'cld-1.0',
    '--pkg', 'comedilib',
    '--pkg', 'dactl-config',
    '--pkg', 'gio-2.0',
    '--pkg', 'gee-0.8',
    '--pkg', 'gmodule-2.0',
    '--pkg', 'libpeas-1.0',
    '--pkg', 'libxml-2.0',
    '--pkg', 'linux',
    '--pkg', 'posix'
 ]

  #custom_target('valadoc-core',
    #input: libdactl_core_sources,
    #output: 'valadoc-core',
    #depends : libdactl,
    #build_by_default : get_option('with-valadoc'),
    #command :
    #[
      #valadoc,
      #core_doc_common_args,
      #'-o', 'valadoc',
      #libdactl_core_sources
    #]
  #)

  dactl_doc_common_args = [
    '--package-name', 'dactl',
    '--package-version', api_version,
    '-b', join_paths(meson.source_root(), 'src', 'dactl'),
    '--force',
    '--directory', '@OUTPUT@',
    '--vapidir', join_paths(meson.source_root(), 'vapi'),
    '--vapidir', join_paths(meson.source_root(), 'src', 'config'),
    '--pkg', 'cld-1.0',
    '--pkg', 'comedilib',
    '--pkg', 'dactl-1.0',
    '--pkg', 'dactl-config',
    '--pkg', 'gee-0.8',
    '--pkg', 'glib-2.0',
    '--pkg', 'glib-extra',
    '--pkg', 'gobject-2.0',
    '--pkg', 'gtk+-3.0',
    '--pkg', 'gtksourceview-3.0',
    '--pkg', 'json-glib-1.0',
    '--pkg', 'libxml-2.0',
    '--pkg', 'librsvg-2.0',
    '--pkg', 'libpeas-1.0',
    '--pkg', 'posix',
    '--pkg', 'webkit2gtk-4.0',
 ]

  custom_target('valadoc-dactl',
    input: dactl_sources_object,
    output: 'valadoc-dactl',
    depends : libdactl,
    build_by_default : get_option('with-valadoc'),
    command :
    [
      valadoc,
      dactl_doc_common_args,
      '-o', 'valadoc',
      dactl_sources_object
    ]
  )

  ui_doc_common_args = [
    '--verbose',
    '--package-name', 'libdactl',
    '--package-version', api_version,
    '-b', join_paths(meson.source_root(), 'src', 'libdactl'),
    '--force',
    '--directory', '@OUTPUT@',
    '--vapidir', join_paths(meson.source_root(), 'vapi'),
    '--vapidir', join_paths(meson.source_root(), 'src', 'config'),
    '--pkg', 'cld-1.0',
    '--pkg', 'comedilib',
    '--pkg', 'dactl-config',
    '--pkg', 'gee-0.8',
    '--pkg', 'gmodule-2.0',
    '--pkg', 'gsl',
    '--pkg', 'gtk+-3.0',
    '--pkg', 'libpeas-1.0',
    '--pkg', 'libxml-2.0',
    '--pkg', 'librsvg-2.0',
    '--pkg', 'linux',
    '--pkg', 'posix',
    '--pkg', 'webkit2gtk-4.0',
  ]

  core_ui_sources = [libdactl_core_sources, ui_sources_object]
  custom_target('valadoc-dactl-ui',
    input: core_ui_sources,
    output: 'valadoc-dactl-ui',
    depends : libdactl,
    build_by_default : get_option('with-valadoc'),
    command :
    [
      valadoc,
      ui_doc_common_args,
      '-o', 'valadoc',
      core_ui_sources,
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

    #custom_target('gtkdoc-dactl',
      #input : libdactl_core_sources,
      #output : 'gtkdoc',
      #depends : libdactl,
      #build_by_default : get_option('with-gtkdoc'),
      #command :
      #[
        #valadoc,
        #'--doclet', 'gtkdoc',
        #'-o', 'gtkdoc',
        #core_doc_common_args,
        #'-X', join_paths(meson.build_root(), 'src/libdactl/dactl.h'),
        #'-X', '-l',
        #'-X', join_paths(meson.build_root(), 'src/libdactl/libdactl-1.0.so'),
        #'-b', join_paths(meson.source_root(), 'src', 'libdactl'),
        #libdactl_core_sources
      #]
    #)
  endif

# TODO: implement gtkdoc creation - see https://gitlab.gnome.org/sbacher/rygel/tree/master/doc/reference/librygel-core/gtkdoc
##    if get_option('with-gtkdoc')
##      install_subdir('gtkdoc/html',
##            install_dir : join_paths(get_option('datadir'), 'gtk-doc/html/libdactl'),
##        strip_directory : true
##      )
##    endif
endif
