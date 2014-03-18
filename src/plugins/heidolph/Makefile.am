include $(top_srcdir)/common.am

plugin_LTLIBRARIES = libdactl-heidolph.la
plugin_DATA = heidolph.plugin

gresource_file = heidolph.gresource.xml
resource_files = $(shell $(GLIB_COMPILE_RESOURCES) --generate-dependencies $(gresource_file))
resources.c: $(gresource_file) $(resource_files)
	$(AM_V_GEN) $(GLIB_COMPILE_RESOURCES) --target=$@ --sourcedir=. --generate-source $<

BUILT_SOURCES = resources.c

libdactl_heidolph_la_SOURCES = \
	$(BUILT_SOURCES) \
	dactl-heidolph-box.vala

libdactl_heidolph_la_VALAFLAGS = \
	--gresources $(gresource_file) \
	--pkg posix \
	$(DACTL_PLUGIN_COMMON_VALAFLAGS) \
	$(DACTL_UI_DEPS_VALAFLAGS) \
	$(DACTL_COMMON_VALAFLAGS)

libdactl_heidolph_la_CFLAGS = \
	$(DACTL_PLUGIN_HEIDOLPH_DEPS_CFLAGS) \
	$(DACTL_UI_DEPS_CFLAGS) \
	-DG_LOG_DOMAIN='"Heidolph"'

libdactl_heidolph_la_LIBADD = \
	$(DACTL_PLUGIN_HEIDOLPH_DEPS_LIBS) \
	$(DACTL_UI_DEPS_LIBS)

libdactl_heidolph_la_LDFLAGS = \
	$(DACTL_PLUGIN_LINKER_FLAGS)

MAINTAINERCLEANFILES += $(libdactl_brabender_la_SOURCES:.vala=.c)

EXTRA_DIST = \
	$(gresource_file) \
	$(resource_files) \
	heidolph.plugin.in
