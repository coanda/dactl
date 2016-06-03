if ENABLE_VALA_PLUGIN

EXTRA_DIST = \
	$(plugin_DATA) \
	vala.plugin.in

plugindir = $(libdir)/dactl-0.3/plugins
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
	$(PLUGIN_VALAFLAGS) \
	--pkg libpeas-gtk-1.0 \
	$(NULL)

libdactl_vala_la_CFLAGS = \
	-DVALA_VERSION=\""$(VALA_VERSION)"\" \
	-DPACKAGE_DATADIR=\""$(datadir)/dactl-0.3"\" \
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
	-Wno-unused-function \
	$(NULL)

#libdactl_sample_la_VALAFLAGS = \
	#--target-glib=2.38 \
	#--vapidir=$(top_srcdir)/vapi \
	#$(DACTL_PLUGIN_COMMON_VALAFLAGS) \
	#$(DACTL_UI_DEPS_VALAFLAGS) \
	#$(DACTL_COMMON_LIBDACTL_CORE_VALAFLAGS) \
	#$(DACTL_COMMON_LIBDACTL_UI_VALAFLAGS) \
	#$(DACTL_COMMON_VALAFLAGS)

#libdactl_sample_la_CFLAGS = \
	#-DG_LOG_DOMAIN='"Sample"' \
	#$(DACTL_PLUGIN_SAMPLE_DEPS_CFLAGS) \
	#$(DACTL_UI_DEPS_CFLAGS) \
	#$(DACTL_COMMON_LIBDACTL_CORE_CFLAGS) \
	#$(DACTL_COMMON_LIBDACTL_UI_CFLAGS)

#libdactl_sample_la_LIBADD = \
	#$(DACTL_PLUGIN_SAMPLE_DEPS_LIBS) \
	#$(DACTL_UI_DEPS_LIBS) \
	#$(DACTL_COMMON_LIBDACTL_CORE_LIBS) \
	#$(DACTL_COMMON_LIBDACTL_UI_LIBS)

#libdactl_sample_la_LDFLAGS = \
	#$(DACTL_PLUGIN_LINKER_FLAGS)

libdactl_vala_la_LIBADD = $(VALA_LIBS)
libdactl_vala_la_LDFLAGS = $(PLUGIN_LDFLAGS)

include $(top_srcdir)/src/plugins/Makefile.plugin

endif

-include $(top_srcdir)/git.mk
