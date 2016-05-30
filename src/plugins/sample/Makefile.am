include $(top_srcdir)/common.am

plugin_LTLIBRARIES = libdactl-sample.la
plugin_DATA = sample.plugin

libdactl_sample_la_SOURCES = \
	$(BUILT_SOURCES) \
	dactl-sample-plugin.vala

libdactl_sample_la_VALAFLAGS = \
	--target-glib=2.38 \
	--vapidir=$(top_srcdir)/vapi \
	$(DACTL_PLUGIN_COMMON_VALAFLAGS) \
	$(DACTL_UI_DEPS_VALAFLAGS) \
	$(DACTL_COMMON_LIBDACTL_CORE_VALAFLAGS) \
	$(DACTL_COMMON_LIBDACTL_UI_VALAFLAGS) \
	$(DACTL_COMMON_VALAFLAGS)

libdactl_sample_la_CFLAGS = \
	-DG_LOG_DOMAIN='"Sample"' \
	$(DACTL_PLUGIN_SAMPLE_DEPS_CFLAGS) \
	$(DACTL_UI_DEPS_CFLAGS) \
	$(DACTL_COMMON_LIBDACTL_CORE_CFLAGS) \
	$(DACTL_COMMON_LIBDACTL_UI_CFLAGS)

libdactl_sample_la_LIBADD = \
	$(DACTL_PLUGIN_SAMPLE_DEPS_LIBS) \
	$(DACTL_UI_DEPS_LIBS) \
	$(DACTL_COMMON_LIBDACTL_CORE_LIBS) \
	$(DACTL_COMMON_LIBDACTL_UI_LIBS)

libdactl_sample_la_LDFLAGS = \
	$(DACTL_PLUGIN_LINKER_FLAGS)

MAINTAINERCLEANFILES += $(libdactl_sample_la_SOURCES:.vala=.c)

EXTRA_DIST = \
	sample.plugin.in
