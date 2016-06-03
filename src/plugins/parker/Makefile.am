if ENABLE_PARKER_PLUGIN

include $(top_srcdir)/common.am

plugin_LTLIBRARIES = libdactl-parker.la
dist_plugin_DATA = parker.plugin

gresource_file = parker.gresource.xml
resource_files = $(shell $(GLIB_COMPILE_RESOURCES) --generate-dependencies $(gresource_file))
resources.c: $(gresource_file) $(resource_files)
	$(AM_V_GEN) $(GLIB_COMPILE_RESOURCES) --target=$@ --sourcedir=. --generate-source $<

BUILT_SOURCES = resources.c

libdactl_parker_la_SOURCES = \
	$(BUILT_SOURCES) \
	dactl-parker-plugin.vala \
	dactl-parker-box.vala \
	dactl-parker-settings-box.vala

libdactl_parker_la_VALAFLAGS = \
	--target-glib=2.38 \
	--gresources $(gresource_file) \
	--vapidir=$(top_srcdir)/vapi \
	$(DACTL_PLUGIN_COMMON_VALAFLAGS) \
	$(DACTL_CLD_DEPS_VALAFLAGS) \
	$(DACTL_UI_DEPS_VALAFLAGS) \
	$(DACTL_COMMON_LIBDACTL_CORE_VALAFLAGS) \
	$(DACTL_COMMON_LIBDACTL_UI_VALAFLAGS) \
	$(DACTL_COMMON_VALAFLAGS)

libdactl_parker_la_CFLAGS = \
	-DG_LOG_DOMAIN='"Parker"' \
	$(DACTL_PLUGIN_PARKER_DEPS_CFLAGS) \
	$(DACTL_CLD_DEPS_CFLAGS) \
	$(DACTL_UI_DEPS_CFLAGS) \
	$(DACTL_COMMON_LIBDACTL_CORE_CFLAGS) \
	$(DACTL_COMMON_LIBDACTL_UI_CFLAGS)

libdactl_parker_la_LIBADD = \
	$(DACTL_PLUGIN_PARKER_DEPS_LIBS) \
	$(DACTL_CLD_DEPS_LIBS) \
	$(DACTL_UI_DEPS_LIBS) \
	$(DACTL_COMMON_LIBDACTL_CORE_LIBS) \
	$(DACTL_COMMON_LIBDACTL_UI_LIBS)

libdactl_parker_la_LDFLAGS = \
	$(DACTL_PLUGIN_LINKER_FLAGS)

MAINTAINERCLEANFILES += $(libdactl_brabender_la_SOURCES:.vala=.c)

EXTRA_DIST = \
	$(gresource_file) \
	$(resource_files) \
	$(plugin_DATA) \
	$(NULL)

endif

-include $(top_srcdir)/git.mk
