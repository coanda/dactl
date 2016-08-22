CLEANFILES =
DISTCLEANFILES =
BUILT_SOURCES =
EXTRA_DIST =

include $(top_srcdir)/common.am

pkglibdir = $(libdir)/dactl
pkglib_LTLIBRARIES = libdactl-log-0.4.la

headersdir = $(includedir)/dactl-@VERSION@/libdactl-log
nobase_headers_DATA =

pkgconfig_DATA = dactl-log-0.4.pc
pkgconfigdir = $(libdir)/pkgconfig

EXTRA_DIST += \
	dactl-log-0.4.pc.in \
	$(NULL)

LIBDACTL_LOG_VERSION=0:4:0

libdactl_log_0_4_la_public_headers = \
	$(NULL)

libdactl_log_0_4_la_public_sources = \
	dactl-log-backend.c \
	dactl-log-backend-manager.c \
	dactl-log-factory.c \
	$(NULL)

libdactl_log_0_4_la_VALASOURCES = \
	dactl-log-backend.vala \
	dactl-log-backend-manager.vala \
	dactl-log-factory.vala \
	$(NULL)

libdactl_log_0_4_la_SOURCES = \
	$(libdactl_log_0_4_la_VALASOURCES) \
	$(NULL)

libdactl_log_0_4_la_includes = \
	$(DEBUG_CFLAGS) \
	-DPACKAGE_DATADIR="\"${datadir}\"" \
	-DPACKAGE_LOCALE_DIR=\""${datadir}/locale"\" \
	-DPACKAGE_LIBDIR=\""${libdir}"\" \
	-DBUILDDIR=\""${abs_top_builddir}"\" \
	-DSRCDIR=\""${abs_top_srcdir}"\" \
	-I$(top_srcdir)/src/libdactl-core \
	-I$(top_srcdir)/src/libdactl-net \
	$(NULL)

libdactl_log_0_4_la_VALAFLAGS = \
	-H dactl-log.h -C \
	--library=dactl-log-0.4 \
	--gir=Dactl-0.4.gir \
	--vapidir=$(top_srcdir)/vapi \
	--vapidir=$(top_srcdir)/src/libdactl-core \
	--vapidir=$(top_srcdir)/src/libdactl-net \
	--pkg posix \
	--pkg gio-2.0 \
	--pkg gee-0.8 \
	--pkg json-glib-1.0 \
	--pkg libpeas-1.0 \
	--pkg libsoup-2.4 \
	--pkg libzmq \
	--pkg dactl-core-0.4 \
	--pkg dactl-net-0.4 \
	--pkg dactl-config \
	$(NULL)

libdactl_log_0_4_la_CFLAGS = \
	-DG_LOG_DOMAIN=\"libdactl-log\" \
	-DGETTEXT_PACKAGE=\"dactl\" \
	-DBACKEND_DIR=\""$(backenddir)"\" \
	$(AM_CFLAGS) \
	$(LIBDACTL_CFLAGS) \
	$(LIBDACTL_LOG_CFLAGS) \
	$(LIBDACTL_NET_CFLAGS) \
	$(OPTIMIZE_CFLAGS) \
	$(DEBUG_CFLAGS) \
	$(libdactl_log_0_4_la_includes) \
	-Wno-deprecated-declarations \
	-Wno-discarded-qualifiers \
	-Wno-implicit-function-declaration \
	-Wno-incompatible-pointer-types \
	-Wno-unused-but-set-variable \
	-Wno-unused-label \
	-Wno-unused-function \
	$(NULL)

libdactl_log_0_4_la_LDFLAGS = \
	$(OPTIMIZE_LDFLAGS) \
	-version-info $(LIBDACTL_LOG_VERSION) \
	$(NULL)

libdactl_log_0_4_la_LIBADD = \
	$(LIBDACTL_LIBS) \
	$(LIBDACTL_LOG_LIBS) \
	$(LIBDACTL_NET_LIBS) \
	$(NULL)


if HAVE_INTROSPECTION
-include $(INTROSPECTION_MAKEFILE)

INTROSPECTION_GIRS =
INTROSPECTION_SCANNER_ARGS = --add-include-path=$(srcdir) --warn-all
INTROSPECTION_COMPILER_ARGS = \
	-l libdactl-log-0.4.so.0 \
	--includedir=$(builddir)/../libdactl-core \
	--includedir=$(srcdir)/../libdactl-core
$(builddir)/DactlLog-0.4.gir: $(srcdir)/Dactl-0.4.gir
	$(AM_V_GEN)$(SED) \
		-e 's,Dactl\.,DactlLog.,g' \
		-e 's,namespace name="Dactl",namespace name="DactlLog",g' \
		-e 's,DactlLog\.Extension,DactlCore.Extension,g' \
		-e 's,<package name="dactl-log-0.4"/>,<include name="DactlCore" version="0.4"/>\n<package name="dactl-log-0.4"/>,' \
		$< >$@
GIRS = DactlLog-0.4.gir

girdir = $(datadir)/dactl/gir-1.0
gir_DATA = $(GIRS)

typelibdir = $(pkglibdir)/girepository-1.0
typelib_DATA = $(GIRS:.gir=.typelib)

CLEANFILES += $(gir_DATA) $(typelib_DATA)
endif


libdactl_log_0_4_vapi_DEPS = \
	posix \
	gee-0.8 \
	gio-2.0 \
	json-glib-1.0

dactl-log-0.4.deps: Makefile
	$(AM_V_GEN) echo $(libdactl_log_0_4_vapi_DEPS) | tr ' ' '\n' > $@

VAPI_FILES = dactl-log-0.4.vapi
DEPS_FILES = dactl-log-0.4.deps

vapidir = $(VAPIDIR)
vapi_DATA = $(VAPI_FILES) $(DEPS_FILES)
dactl-log.h dactl-log-0.4.vapi Dactl-0.4.gir: libdactl_log_0_4_la_vala.stamp

BUILT_SOURCES += \
	dactl-log.h \
	$(VAPI_FILES) \
	$(DEPS_FILES) \
	DactlLog-0.4.gir \
	Dactl-0.4.gir \
	$(NULL)

-include $(top_srcdir)/git.mk
