if ENABLE_VALA_PLUGIN

EXTRA_DIST = $(plugin_DATA)

plugindir = $(libdir)/dactl/plugins
plugin_LTLIBRARIES = libdactl-vala.la
dist_plugin_DATA = vala.plugin

BUILT_SOURCES = libdactl_vala_la_vala.stamp

libdactl_vala_la_vala.stamp: $(libdactl_vala_la_VALASOURCES)
	$(AM_V_GEN)$(VALAC) \
		$(libdactl_vala_la_VALAFLAGS) \
		$(addprefix $(srcdir)/,$(libdactl_vala_la_VALASOURCES)) \
		--ccode \
		&& touch $@

libdactl_vala_la_VALASOURCES = \
	dactl-vala-plugin.vala \
	$(NULL)

EXTRA_DIST += $(libdactl_vala_la_VALASOURCES)

nodist_libdactl_vala_la_SOURCES = \
	dactl-vala-plugin.c \
	$(NULL)

CLEANFILES = $(BUILT_SOURCES) $(nodist_libdactl_vala_la_SOURCES)

libdactl_vala_la_VALAFLAGS = \
	$(PLUGIN_VALAFLAGS)

libdactl_vala_la_CFLAGS = \
	-DVALA_VERSION=\""$(VALA_VERSION)"\" \
	-DPACKAGE_DATADIR=\""$(datadir)/dactl-0.4"\" \
	-DG_LOG_DOMAIN=\"vala-plugin\" \
	-DGETTEXT_PACKAGE=\"dactl\" \
	$(PLUGIN_CFLAGS) \
	$(VALA_CFLAGS) \
	-Wno-deprecated-declarations \
	-Wno-discarded-qualifiers \
	-Wno-implicit-function-declaration \
	-Wno-incompatible-pointer-types \
	-Wno-unused-but-set-variable \
	-Wno-unused-label \
	-Wno-unused-function

libdactl_vala_la_LIBADD = $(VALA_LIBS)
libdactl_vala_la_LDFLAGS = $(PLUGIN_LDFLAGS)

if ENABLE_WEBKIT
libdactl_vala_la_VALAFLAGS += --pkg webkit2gtk-4.0
libdactl_vala_la_CFLAGS += $(WEBKIT_CFLAGS)
libdactl_vala_la_LIBADD += $(WEBKIT_LIBS)
libdactl_vala_la_LDFLAGS += $(WEBKIT_LDFLAGS)
endif

include $(top_srcdir)/src/plugins/Makefile.plugin

endif

-include $(top_srcdir)/git.mk
