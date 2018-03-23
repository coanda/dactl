# Build a .a archive to fix linking in vala build.
# Borrowed from: https://github.com/budgie-desktop/budgie-desktop/blob/master/src/config/meson.build

libconfig_sources = [
  'dactl-config.c',
]

libconfig = static_library('config', libconfig_sources,
  include_directories: extra_includes,
)

link_libconfig = declare_dependency(
            link_with: libconfig,
  include_directories: [ include_directories('.'), ],
)

# Expose this directory to use with vapidir
dir_libconfig = meson.current_source_dir()
