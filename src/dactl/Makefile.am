CLEANFILES =
DISTCLEANFILES =
BUILT_SOURCES =
EXTRA_DIST =

include $(top_srcdir)/common.am

bin_PROGRAMS = dactl

gresource_file = $(top_srcdir)/data/dactl.gresource.xml

dactl_VALAFLAGS = \
	--enable-experimental --target-glib=2.38 --gresources $(gresource_file) \
	-H $(srcdir)/libdactl.h -C -c --thread \
	--vapidir=$(top_srcdir)/vapi \
	--pkg posix \
	--pkg linux \
	$(DACTL_DEPS_VALAFLAGS) \
	$(DACTL_CLD_DEPS_VALAFLAGS) \
	$(DACTL_UI_DEPS_VALAFLAGS) \
	$(DACTL_COMMON_LIBDACTL_CORE_VALAFLAGS) \
	$(DACTL_COMMON_LIBDACTL_UI_VALAFLAGS) \
	$(DACTL_COMMON_VALAFLAGS)

dactl_CFLAGS = \
	--include config.h \
	-DG_LOG_DOMAIN='"Dactl"' \
	-DLOCALEDIR=\""$(datadir)/locale"\" \
	$(DACTL_DEPS_CFLAGS) \
	$(DACTL_CLD_DEPS_CFLAGS) \
	$(DACTL_UI_DEPS_CFLAGS) \
	$(DACTL_COMMON_LIBDACTL_CORE_CFLAGS) \
	$(DACTL_COMMON_LIBDACTL_UI_CFLAGS)

dactl_LDADD = \
	$(DACTL_DEPS_LIBS) \
	$(DACTL_CLD_DEPS_LIBS) \
	$(DACTL_UI_DEPS_LIBS) \
	$(DACTL_COMMON_LIBDACTL_CORE_LIBS) \
	$(DACTL_COMMON_LIBDACTL_UI_LIBS)

dactl_headers = \
	dactl.h \
	libdactl.h

resource_files = $(shell $(GLIB_COMPILE_RESOURCES) --generate-dependencies --sourcedir=$(top_srcdir)/data $(gresource_file))
resources.c: $(gresource_file) $(resource_files)
	$(AM_V_GEN) $(GLIB_COMPILE_RESOURCES) --target=$@ --sourcedir=$(top_srcdir)/data --generate-source $<

BUILT_SOURCES = resources.c

UI_SOURCES = \
	dactl-application-menu.vala \
	dactl-application-toolbar.vala \
	dactl-configuration-editor.vala \
	dactl-configuration-toolbar.vala \
	dactl-csv-export.vala \
	dactl-csv-export-toolbar.vala \
	dactl-general-settings.vala \
	dactl-loader.vala \
	dactl-loader-toolbar.vala \
	dactl-settings-data.vala \
	dactl-settings-dialog.vala \
	dactl-settings-listbox.vala \
	dactl-settings-page.vala \
	dactl-settings-propertybox.ui \
	dactl-settings-sidebar.vala \
	dactl-settings-topbar.vala \
	dactl-settings-toolbar.vala \
	dactl-settings-treeview.vala \
	dactl-sidebar.vala \
	dactl-topbar.vala \
	dactl-ui-application.vala \
	dactl-ui-application-model.vala \
	dactl-ui-application-view.vala \
	dactl-ui-application-controller.vala \
	dactl-ux-manager.vala

dactl_SOURCES = \
	$(BUILT_SOURCES) \
	dactl-main.vala \
	dactl-dbus-service.vala \
	dactl-cmdline-config.vala \
	dactl-utility.vala \
	$(UI_SOURCES) \
	$(NULL)

MAINTAINERCLEANFILES += $(BUILT_SOURCES)

CLEANFILES = \
	*.stamp \
	stamp-h1 \
	$(srcdir)/libdactl.h

EXTRA_DIST = \
	$(gresource_file) \
	$(BUILT_SOURCES)

-include $(top_srcdir)/git.mk
