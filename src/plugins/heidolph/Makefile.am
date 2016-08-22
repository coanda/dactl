if ENABLE_HEIDOLPH_PLUGIN

include $(top_srcdir)/common.am

plugin_LTLIBRARIES = libdactl-heidolph.la
dist_plugin_DATA = heidolph.plugin

gresource_file = heidolph.gresource.xml
resource_files = $(shell $(GLIB_COMPILE_RESOURCES) --generate-dependencies $(gresource_file))
resources.c: $(gresource_file) $(resource_files)
	$(AM_V_GEN) $(GLIB_COMPILE_RESOURCES) --target=$@ --sourcedir=. --generate-source $<

BUILT_SOURCES = resources.c

libdactl_heidolph_la_SOURCES = \
	$(BUILT_SOURCES) \
	dactl-heidolph-plugin.vala \
	dactl-heidolph-box.vala \
	$(NULL)

libdactl_heidolph_la_VALAFLAGS = \
	--gresources $(gresource_file) \
	--vapidir=$(top_srcdir)/vapi \
	--pkg posix \
	$(DACTL_PLUGIN_COMMON_VALAFLAGS) \
	$(DACTL_CLD_DEPS_VALAFLAGS) \
	$(DACTL_UI_DEPS_VALAFLAGS) \
	$(DACTL_COMMON_LIBDACTL_CORE_VALAFLAGS) \
	$(DACTL_COMMON_LIBDACTL_UI_VALAFLAGS) \
	$(DACTL_COMMON_VALAFLAGS) \
	$(PLUGIN_VALAFLAGS)

libdactl_heidolph_la_CFLAGS = \
	-DG_LOG_DOMAIN=\"libdactl-heidolph\" \
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

libdactl_heidolph_la_LIBADD = \
	$(DACTL_CLD_DEPS_LIBS) \
	$(DACTL_UI_DEPS_LIBS) \
	$(DACTL_COMMON_LIBDACTL_CORE_LIBS) \
	$(DACTL_COMMON_LIBDACTL_UI_LIBS)

libdactl_heidolph_la_LDFLAGS = \
	$(PLUGIN_LDFLAGS)


if ENABLE_WEBKIT
libdactl_heidolph_la_VALAFLAGS += --pkg webkit2gtk-4.0
libdactl_heidolph_la_CFLAGS += $(WEBKIT_CFLAGS)
libdactl_heidolph_la_LIBADD += $(WEBKIT_LIBS)
libdactl_heidolph_la_LDFLAGS += $(WEBKIT_LDFLAGS)
endif


MAINTAINERCLEANFILES += $(libdactl_heidolph_la_SOURCES:.vala=.c)

EXTRA_DIST = \
	$(gresource_file) \
	$(resource_files) \
	$(plugin_DATA) \
	$(NULL)

endif

-include $(top_srcdir)/git.mk
