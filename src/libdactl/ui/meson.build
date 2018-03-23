if get_option('with-ui')

gresource = join_paths(meson.current_source_dir(), 'ui.gresource.xml')

ui_resources = gnome.compile_resources('ui-resources',
  gresource,
  c_name: 'ui',
)

ui_headers = []
ui_vala_args = []

libdactl_generated_headers += [ ui_resources[1] ]

ui_sources = [
  'ai-control.vala',
  'ao-control.vala',
  'box.vala',
  'channel-matrix.vala',
  'channel-treeview.vala',
  'channel-vector.vala',
  'chart-axis.vala',
  'chart-colormap.vala',
  'chart-trace.vala',
  'chart.vala',
  'chart-widget.vala',
  'digital-control.vala',
  'drawing.vala',
  'exec-control.vala',
  'factory.vala',
  'grid.vala',
  'heatmap.vala',
  'log-control.vala',
  'page.vala',
  'pid-control.vala',
  'plugin-control.vala',
  'plugin-manager.vala',
  'pnid.vala',
  'polar-axis.vala',
  'polar-canvas.vala',
  'polar-chart.vala',
  'polar-heatmap.vala',
  'rt-chart-trace.vala',
  'rt-chart.vala',
  'rt-multichannel-trace.vala',
  'settable.vala',
  'stripchart.vala',
  'utility.vala',
  'video-processor.vala',
  'widget-information.vala',
  'widget.vala',
  'window.vala',
]

gsl_lib = meson.get_compiler('c').find_library('gsl')
gsl_vapi = meson.get_compiler('vala').find_library('gsl', dirs: dir_vapi)
dep_gsl = declare_dependency(dependencies: [gsl_lib, gsl_vapi])

dep_gtk = dependency('gtk+-3.0', version: '>= 3.22.0')
dep_gtksource = dependency('gtksourceview-3.0', version: '>= 3.22.0')
dep_peasgtk = dependency('libpeas-gtk-1.0', version: '>= 1.20.0')
dep_rsvg = dependency('librsvg-2.0', version: '>= 2.40.0')

ui_deps = [
  dep_gtk,
  dep_gtksource,
  dep_gsl,
  dep_peasgtk,
  dep_rsvg,
]

if get_option('with-webkit')
  ui_deps += [dependency('webkit2gtk-4.0', version: '>= 2.12.0')]
  #ui_deps += [dependency('webkit2gtk-web-extension-4.0', version: '>= 2.12.0')]

  ui_vala_args += [
    '--pkg', 'javascriptcoregtk-3.0',
    '--gresources=' + gresource,
  ]

  ui_sources += [
    'rich-content.vala',
    'webkit-widget.vala',
    #'extensions/dom.vala',
  ]
endif

libdactl_deps += ui_deps
libdactl_vala_args += ui_vala_args

libdactl_headers += files(ui_headers)
libdactl_sources += files(ui_sources)

install_headers(ui_headers,
  subdir: join_paths(libdactl_header_subdir, 'ui')
)

endif
