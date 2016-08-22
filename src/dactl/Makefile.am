CLEANFILES =
DISTCLEANFILES =
BUILT_SOURCES =
EXTRA_DIST =

include $(top_srcdir)/common.am

bin_PROGRAMS = dactl

gresource_file = $(top_srcdir)/data/dactl.gresource.xml

dactl_VALAFLAGS = \
	-H $(srcdir)/libdactl.h -C -c \
	--target-glib=2.44 \
	--thread \
	--gresources $(gresource_file) \
	$(DACTL_DEPS_VALAFLAGS) \
	$(DACTL_CLD_DEPS_VALAFLAGS) \
	$(DACTL_UI_DEPS_VALAFLAGS) \
	$(DACTL_COMMON_LIBDACTL_CORE_VALAFLAGS) \
	$(DACTL_COMMON_LIBDACTL_UI_VALAFLAGS) \
	$(DACTL_COMMON_VALAFLAGS) \
	--vapidir=$(top_srcdir)/vapi \
	--pkg posix \
	--pkg linux \
	--pkg json-glib-1.0

dactl_includes = \
	$(DEBUG_CFLAGS) \
	-include config.h \
	-DLOCALEDIR=\""$(datadir)/locale"\" \
	-DDATADIR=\""$(sharedir)"\"

dactl_CFLAGS = \
	-DG_LOG_DOMAIN=\"dactl\" \
	-DGETTEXT_PACKAGE=\"dactl\" \
	$(DACTL_DEPS_CFLAGS) \
	$(DACTL_CLD_DEPS_CFLAGS) \
	$(DACTL_UI_DEPS_CFLAGS) \
	$(DACTL_COMMON_LIBDACTL_CORE_CFLAGS) \
	$(DACTL_COMMON_LIBDACTL_UI_CFLAGS) \
	$(LIBDACTL_CFLAGS) \
	$(LIBDACTL_UI_CFLAGS) \
	$(OPTIMIZE_CFLAGS) \
	$(dactl_includes) \
	-Wno-deprecated-declarations \
	-Wno-discarded-qualifiers \
	-Wno-implicit-function-declaration \
	-Wno-incompatible-pointer-types \
	-Wno-unused-but-set-variable \
	-Wno-unused-label \
	-Wno-unused-function

dactl_LDADD = \
	$(DACTL_DEPS_LIBS) \
	$(DACTL_CLD_DEPS_LIBS) \
	$(DACTL_UI_DEPS_LIBS) \
	$(DACTL_COMMON_LIBDACTL_CORE_LIBS) \
	$(DACTL_COMMON_LIBDACTL_UI_LIBS) \
	$(LIBDACTL_LIBS) \
	$(LIBDACTL_UI_LIBS)


if ENABLE_WEBKIT
dactl_VALAFLAGS += --pkg webkit2gtk-4.0
dactl_CFLAGS += \
	-DWEB_EXTENSION_DIR=\""$(extensiondir)"\" \
	$(WEBKIT_CFLAGS) \
	$(NULL)
dactl_LDADD += $(WEBKIT_LIBS)
endif


dactl_headers = \
	dactl.h \
	libdactl.h \
	$(NULL)

resource_files = $(shell $(GLIB_COMPILE_RESOURCES) --generate-dependencies --sourcedir=$(top_srcdir)/data $(gresource_file))
resources.c: $(gresource_file) $(resource_files)
	$(AM_V_GEN) $(GLIB_COMPILE_RESOURCES) --target=$@ --sourcedir=$(top_srcdir)/data --generate-source $<

BUILT_SOURCES += resources.c

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
	dactl-ui-ux-manager.vala

dactl_SOURCES = \
	$(BUILT_SOURCES) \
	dactl-main.vala \
	dactl-dbus-service.vala \
	dactl-cmdline-config.vala \
	dactl-utility.vala \
	$(UI_SOURCES) \
	$(NULL)

MAINTAINERCLEANFILES += $(BUILT_SOURCES)

CLEANFILES += \
	*.stamp \
	stamp-h1 \
	$(srcdir)/libdactl.h \
	$(NULL)

EXTRA_DIST += \
	$(gresource_file) \
	$(BUILT_SOURCES) \
	$(NULL)

-include $(top_srcdir)/git.mk
