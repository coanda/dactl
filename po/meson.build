i18n = import('i18n')

# FIXME: This is to get past config.h not found errors
# define GETTEXT_PACKAGE
add_project_arguments('-DGETTEXT_PACKAGE="dactl"', language:'c')

i18n.gettext(meson.project_name(),
  args: '--directory=' + meson.source_root(),
  preset: 'glib',
)

podir = meson.current_source_dir()
