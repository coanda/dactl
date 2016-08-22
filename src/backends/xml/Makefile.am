if ENABLE_XML_BACKEND

EXTRA_DIST = $(plugin_DATA)

plugindir = $(libdir)/dactl/backends
plugin_LTLIBRARIES = libdactl-backend-xml.la
dist_plugin_DATA = xml.plugin

BUILT_SOURCES = libdactl_backend_xml_la_vala.stamp

libdactl_backend_xml_la_vala.stamp: $(libdactl_backend_xml_la_VALASOURCES)
	$(AM_V_GEN)$(VALAC) \
		$(libdactl_backend_xml_la_VALAFLAGS) \
		$(addprefix $(srcdir)/,$(libdactl_backend_xml_la_VALASOURCES)) \
		--ccode \
		&& touch $@

libdactl_backend_xml_la_VALASOURCES = \
	dactl-xml-backend.vala \
	$(NULL)

EXTRA_DIST += $(libdactl_backend_xml_la_VALASOURCES)

nodist_libdactl_backend_xml_la_SOURCES = \
	dactl-xml-backend.c \
	$(NULL)

CLEANFILES = $(BUILT_SOURCES) $(nodist_libdactl_backend_xml_la_SOURCES)

libdactl_backend_xml_la_VALAFLAGS = \
	$(BACKEND_VALAFLAGS) \
	$(NULL)

libdactl_backend_xml_la_CFLAGS = \
	-DVALA_VERSION=\""$(VALA_VERSION)"\" \
	-DPACKAGE_DATADIR=\""$(datadir)/dactl-0.4"\" \
	-DG_LOG_DOMAIN=\"xml-backend\" \
	-DGETTEXT_PACKAGE=\"dactl\" \
	$(BACKEND_CFLAGS) \
	$(LIBDACTL_LOG_CFLAGS) \
	-Wno-deprecated-declarations \
	-Wno-discarded-qualifiers \
	-Wno-implicit-function-declaration \
	-Wno-incompatible-pointer-types \
	-Wno-unused-but-set-variable \
	-Wno-unused-label \
	-Wno-unused-function \
	$(NULL)

libdactl_backend_xml_la_LIBADD = $(BACKEND_LIBS)

libdactl_backend_xml_la_LDFLAGS = \
	$(BACKEND_LDFLAGS) \
	$(LIBDACTL_LOG_LDFLAGS) \
	$(NULL)

include $(top_srcdir)/src/backends/Makefile.backend

endif

-include $(top_srcdir)/git.mk
