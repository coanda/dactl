if get_option('with-ui')

dactl_resources = gnome.compile_resources('dactl-resources',
  'dactl.gresource.xml',
  c_name: 'dactl',
)

dactl_sources = [
  'application.vala',
  'application-controller.vala',
  'application-menu.vala',
  'application-model.vala',
  'application-toolbar.vala',
  'application-view.vala',
  'cmdline-config.vala',
  'dbus-service.vala',
  'loader-toolbar.vala',
  'loader.vala',
  'main.vala',
  'sidebar.vala',
  'topbar.vala',
  'utility.vala',
  'ux-manager.vala',
  'configuration/editor.vala',
  'configuration/toolbar.vala',
  #'csv/export-toolbar.vala',
  #'csv/export.vala',
  'settings/data.vala',
  'settings/dialog.vala',
  'settings/general.vala',
  'settings/listbox.vala',
  'settings/page.vala',
  'settings/sidebar.vala',
  'settings/toolbar.vala',
  'settings/topbar.vala',
  'settings/treeview.vala',
]

dactl_c_args = [
  '-DG_LOG_DOMAIN="dactl"',
]

vapi_glibextra = meson.get_compiler('vala').find_library('glib-extra', dirs: join_paths(meson.source_root(), 'vapi'))
dep_glibextra = declare_dependency(dependencies: vapi_glibextra)

dactl_deps = ui_deps + [
  link_libconfig,
  link_libdactl,
  dep_glibextra,
]

executable('dactl', dactl_sources + dactl_resources,
        gui_app: true,
        install: true,
         c_args: dactl_c_args,
      vala_args: dactl_vala_args,
      #link_args: exe_link_args,
  #install_rpath: pkg_libdir_abs,
   dependencies: dactl_deps,
)

endif
