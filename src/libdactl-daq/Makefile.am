CLEANFILES =
DISTCLEANFILES =
BUILT_SOURCES =
EXTRA_DIST =

include $(top_srcdir)/common.am

pkglibdir = $(libdir)/dactl
pkglib_LTLIBRARIES = libdactl-daq-0.3.la

headersdir = $(includedir)/dactl-@VERSION@/libdactl-daq
nobase_headers_DATA =

pkgconfig_DATA = dactl-daq-0.3.pc
pkgconfigdir = $(libdir)/pkgconfig

EXTRA_DIST += \
	dactl-daq-0.3.pc.in \
	$(NULL)

LIBDACTL_DAQ_VERSION=0:3:0

libdactl_daq_0_3_la_public_headers = \
	$(NULL)

libdactl_daq_0_3_la_public_sources = \
	dactl-daq-channel.c \
	dactl-daq-device-manager.c \
	dactl-daq-factory.c \
	$(NULL)

libdactl_daq_0_3_la_VALASOURCES = \
	dactl-daq-channel.vala \
	dactl-daq-device-manager.vala \
	dactl-daq-factory.vala \
	$(NULL)

libdactl_daq_0_3_la_SOURCES = \
	$(libdactl_daq_0_3_la_VALASOURCES) \
	$(NULL)

libdactl_daq_0_3_la_includes = \
	$(DEBUG_CFLAGS) \
	-DPACKAGE_DATADIR="\"${datadir}\"" \
	-DPACKAGE_LOCALE_DIR=\""${datadir}/locale"\" \
	-DPACKAGE_LIBDIR=\""${libdir}"\" \
	-DBUILDDIR=\""${abs_top_builddir}"\" \
	-DSRCDIR=\""${abs_top_srcdir}"\" \
	-I$(top_srcdir)/src/libdactl-core \
	$(NULL)

libdactl_daq_0_3_la_VALAFLAGS = \
	-H dactl-daq.h -C \
	--library=dactl-daq-0.3 \
	--gir=Dactl-0.3.gir \
	--vapidir=$(top_srcdir)/vapi \
	--vapidir=$(top_srcdir)/src/libdactl-core \
	--pkg posix \
	--pkg gio-2.0 \
	--pkg gee-0.8 \
	--pkg json-glib-1.0 \
	--pkg libpeas-1.0 \
	--pkg dactl-core-0.3 \
	--pkg dactl-config \
	$(NULL)

libdactl_daq_0_3_la_CFLAGS = \
	-DG_LOG_DOMAIN=\"libdactl-daq\" \
	-DGETTEXT_PACKAGE=\"dactl\" \
	-DDEVICE_DIR=\""$(devicedir)"\" \
	$(AM_CFLAGS) \
	$(LIBDACTL_CFLAGS) \
	$(LIBDACTL_DAQ_CFLAGS) \
	$(OPTIMIZE_CFLAGS) \
	$(libdactl_daq_0_3_la_includes) \
	-Wno-deprecated-declarations \
	-Wno-discarded-qualifiers \
	-Wno-implicit-function-declaration \
	-Wno-incompatible-pointer-types \
	-Wno-unused-but-set-variable \
	-Wno-unused-label \
	-Wno-unused-function \
	$(NULL)

libdactl_daq_0_3_la_LDFLAGS = \
	$(OPTIMIZE_LDFLAGS) \
	-version-info $(LIBDACTL_DAQ_VERSION) \
	$(NULL)

libdactl_daq_0_3_la_LIBADD = \
	$(LIBDACTL_LIBS) \
	$(LIBDACTL_DAQ_LIBS) \
	$(NULL)


if HAVE_INTROSPECTION
-include $(INTROSPECTION_MAKEFILE)

INTROSPECTION_GIRS =
INTROSPECTION_SCANNER_ARGS = --add-include-path=$(srcdir) --warn-all
INTROSPECTION_COMPILER_ARGS = \
	-l libdactl-daq-0.3.so.0 \
	--includedir=$(builddir)/../libdactl-core \
	--includedir=$(srcdir)/../libdactl-core
$(builddir)/DactlDAQ-0.3.gir: $(srcdir)/Dactl-0.3.gir
	$(AM_V_GEN)$(SED) \
		-e 's,Dactl\.,DactlDAQ.,g' \
		-e 's,namespace name="Dactl",namespace name="DactlDAQ",g' \
		-e 's,<package name="dactl-daq-0.3"/>,<include name="DactlCore" version="0.3"/>\n<package name="dactl-daq-0.3"/>,' \
		$< >$@
GIRS = DactlDAQ-0.3.gir

girdir = $(datadir)/dactl/gir-1.0
gir_DATA = $(GIRS)

typelibdir = $(pkglibdir)/girepository-1.0
typelib_DATA = $(GIRS:.gir=.typelib)

CLEANFILES += $(gir_DATA) $(typelib_DATA)
endif


libdactl_daq_0_3_vapi_DEPS = \
	posix \
	gio-2.0 \
	gee-0.8 \
	json-glib-1.0

dactl-daq-0.3.deps: Makefile
	$(AM_V_GEN) echo $(libdactl_daq_0_3_vapi_DEPS) | tr ' ' '\n' > $@

VAPI_FILES = dactl-daq-0.3.vapi
DEPS_FILES = dactl-daq-0.3.deps

vapidir = $(VAPIDIR)
vapi_DATA = $(VAPI_FILES) $(DEPS_FILES)
dactl-daq.h dactl-daq-0.3.vapi Dactl-0.3.gir: libdactl_daq_0_3_la_vala.stamp

BUILT_SOURCES += \
	dactl-daq.h \
	$(VAPI_FILES) \
	$(DEPS_FILES) \
	DactlDAQ-0.3.gir \
	Dactl-0.3.gir \
	$(NULL)

-include $(top_srcdir)/git.mk
