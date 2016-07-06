if ENABLE_VELMEX_PLUGIN

include $(top_srcdir)/common.am

plugin_LTLIBRARIES = libdactl-velmex.la
dist_plugin_DATA = velmex.plugin

gresource_file = velmex.gresource.xml
resource_files = $(shell $(GLIB_COMPILE_RESOURCES) --generate-dependencies $(gresource_file))
resources.c: $(gresource_file) $(resource_files)
	$(AM_V_GEN) $(GLIB_COMPILE_RESOURCES) --target=$@ --sourcedir=. --generate-source $<

BUILT_SOURCES = resources.c

libdactl_velmex_la_SOURCES = \
	$(BUILT_SOURCES) \
	dactl-velmex-control.vala \
	dactl-velmex-factory.vala \
	dactl-velmex-settings.vala \
	dactl-velmex-plugin.vala \
	$(NULL)

libdactl_velmex_la_VALAFLAGS = \
	--gresources $(gresource_file) \
	--vapidir=$(top_srcdir)/vapi \
	$(DACTL_PLUGIN_COMMON_VALAFLAGS) \
	$(DACTL_CLD_DEPS_VALAFLAGS) \
	$(DACTL_UI_DEPS_VALAFLAGS) \
	$(DACTL_COMMON_LIBDACTL_CORE_VALAFLAGS) \
	$(DACTL_COMMON_LIBDACTL_UI_VALAFLAGS) \
	$(DACTL_COMMON_VALAFLAGS) \
	$(PLUGIN_VALAFLAGS)

libdactl_velmex_la_CFLAGS = \
	-DG_LOG_DOMAIN=\"libdactl-velmex\" \
	-DGETTEXT_PACKAGE=\"dactl\" \
	$(DACTL_CLD_DEPS_CFLAGS) \
	$(DACTL_UI_DEPS_CFLAGS) \
	$(DACTL_COMMON_LIBDACTL_CORE_CFLAGS) \
	$(DACTL_COMMON_LIBDACTL_UI_CFLAGS) \
	$(PLUGIN_CFLAGS) \
	-Wno-deprecated-declarations \
	-Wno-discarded-qualifiers \
	-Wno-implicit-function-declaration \
	-Wno-incompatible-pointer-types \
	-Wno-unused-but-set-variable \
	-Wno-unused-label \
	-Wno-unused-function

libdactl_velmex_la_LIBADD = \
	$(DACTL_CLD_DEPS_LIBS) \
	$(DACTL_UI_DEPS_LIBS) \
	$(DACTL_COMMON_LIBDACTL_CORE_LIBS) \
	$(DACTL_COMMON_LIBDACTL_UI_LIBS)

libdactl_velmex_la_LDFLAGS = \
	$(PLUGIN_LDFLAGS)


if ENABLE_WEBKIT
libdactl_velmex_la_VALAFLAGS += --pkg webkit2gtk-4.0
libdactl_velmex_la_CFLAGS += $(WEBKIT_CFLAGS)
libdactl_velmex_la_LIBADD += $(WEBKIT_LIBS)
libdactl_velmex_la_LDFLAGS += $(WEBKIT_LDFLAGS)
endif


MAINTAINERCLEANFILES += $(libdactl_velmex_la_SOURCES:.vala=.c)

EXTRA_DIST = \
	$(gresource_file) \
	$(resource_files) \
	$(plugin_DATA) \
	$(NULL)

endif

-include $(top_srcdir)/git.mk
