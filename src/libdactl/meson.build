libdactl_header_subdir = join_paths('dactl', 'libdactl')
libdactl_header_dir = pkg_includedir + '/libdactl'

libdactl_generated_sources = []
libdactl_generated_headers = []
libdactl_sources = []
libdactl_headers = []
libdactl_vala_args = dactl_vala_args

libdactl_reqs = [
  'cld-1.0',
  'glib-2.0',
  'gee-0.8',
  'gsl',
  'json-glib-1.0',
  'libpeas-1.0',
  'libsoup-2.4',
  'libxml-2.0',
]

# TODO: remove this, it's only needed by the old plugin loader
dep_gmodule = dependency('gmodule-2.0', version: '>= 2.50.0')

libdactl_deps = dactl_deps + [
  link_libconfig,
  dep_gmodule,
]

# XXX: This would be needed for Peas, not necessarily for current modules
#libdactl_vala_flags = dactl_vala_flags + [
  #'--vapidir', join_paths(meson.current_source_dir(), 'plugin'),
  #'--pkg', 'dactl-plugin',
#]

subdir('core')
subdir('ui')

sources = libdactl_sources + libdactl_headers + libdactl_generated_sources + libdactl_generated_headers

libdactl = library('dactl-' + api_version, sources,
  dependencies: libdactl_deps,
   vala_header: 'dactl.h',
     vala_args: libdactl_vala_args,
     vala_vapi: 'dactl-@0@.vapi'.format(api_version),
       install: true,
   install_dir: [true, true, true],
)

# XXX: Pretty sure this can just be headers
gir_sources = libdactl_sources + libdactl_headers + libdactl_generated_headers + [
  join_paths(meson.current_build_dir(), 'dactl.h')
]

libdactl_gir = gnome.generate_gir(libdactl,
            sources: gir_sources,
          namespace: 'Dactl',
          nsversion: '@0@'.format(api_version),
       dependencies: dactl_deps,
           includes: [
             'cairo-1.0',
             'Cld-1.0',
             'GObject-2.0',
             'Gee-0.8',
             'Json-1.0',
             'Peas-1.0',
             'Soup-2.4',
             'libxml2-2.0',
           ],
      symbol_prefix: 'dactl',
  identifier_prefix: 'Dactl',
            install: true,
         extra_args: [
           '--warn-all',
           '--c-include', 'dactl.h',
         ],
)

pkgconfig = import('pkgconfig')
pkgconfig.generate(
    libraries: [libdactl],
      subdirs: [ 'libdactl-@0@'.format(api_version) ],
      version: meson.project_version(),
         name: 'libdactl',
     filebase: 'libdactl-@0@'.format(api_version),
  description: 'Library for applications and plugins related to data acquisition and control',
     requires: libdactl_reqs,
  install_dir: join_paths(pkg_libdir, 'pkgconfig'),
)

link_libdactl = declare_dependency(
            link_with: libdactl,
         dependencies: dactl_deps,
  include_directories: [ include_directories('.') ],
)

# Expose this directory to use with vapidir
dir_libdactl = meson.current_source_dir()
