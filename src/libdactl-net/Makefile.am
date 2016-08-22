CLEANFILES =
DISTCLEANFILES =
BUILT_SOURCES =
EXTRA_DIST =

pkglibdir = $(libdir)/dactl
pkglib_LTLIBRARIES = libdactl-net-0.4.la

headersdir = $(includedir)/dactl-@VERSION@/libdactl-net
nobase_headers_DATA =

pkgconfig_DATA = dactl-net-0.4.pc
pkgconfigdir = $(libdir)/pkgconfig

EXTRA_DIST += \
	dactl-net-0.4.pc.in \
	$(NULL)

LIBDACTL_NET_VERSION=0:4:0

libdactl_net_0_4_la_public_headers = \
	$(NULL)

libdactl_net_0_4_la_public_sources = \
	dactl-net-enum.c \
	dactl-net-factory.c \
	dactl-net-rest-service.c \
	dactl-net-zmq-service.c \
	dactl-net-zmq-client.c \
	$(NULL)

libdactl_net_0_4_la_VALASOURCES = \
	dactl-net-enum.vala \
	dactl-net-factory.vala \
	dactl-net-rest-service.vala \
	dactl-net-zmq-service.vala \
	dactl-net-zmq-client.vala \
	$(NULL)

libdactl_net_0_4_la_SOURCES = \
	$(libdactl_net_0_4_la_VALASOURCES) \
	$(NULL)

libdactl_net_0_4_la_includes = \
	$(DEBUG_CFLAGS) \
	-DPACKAGE_DATADIR="\"${datadir}\"" \
	-DPACKAGE_LOCALE_DIR=\""${datadir}/locale"\" \
	-DPACKAGE_LIBDIR=\""${libdir}"\" \
	-DBUILDDIR=\""${abs_top_builddir}"\" \
	-DSRCDIR=\""${abs_top_srcdir}"\" \
	-I$(top_srcdir)/src/libdactl-core \
	$(NULL)

libdactl_net_0_4_la_VALAFLAGS = \
	-H dactl-net.h -C \
	--library=dactl-net-0.4 \
	--gir=Dactl-0.4.gir \
	--vapidir=$(top_srcdir)/vapi \
	--vapidir=$(top_srcdir)/src/libdactl-core \
	--pkg posix \
	--pkg gio-2.0 \
	--pkg gee-0.8 \
	--pkg json-glib-1.0 \
	--pkg libsoup-2.4 \
	--pkg libzmq \
	--pkg dactl-core-0.4 \
	$(NULL)

libdactl_net_0_4_la_CFLAGS = \
	-DG_LOG_DOMAIN=\"libdactl-net\" \
	-DGETTEXT_PACKAGE=\"dactl\" \
	$(AM_CFLAGS) \
	$(LIBDACTL_CFLAGS) \
	$(LIBDACTL_NET_CFLAGS) \
	$(OPTIMIZE_CFLAGS) \
	$(libdactl_net_0_4_la_includes) \
	-Wno-deprecated-declarations \
	-Wno-discarded-qualifiers \
	-Wno-implicit-function-declaration \
	-Wno-incompatible-pointer-types \
	-Wno-unused-but-set-variable \
	-Wno-unused-label \
	-Wno-unused-function \
	$(NULL)

libdactl_net_0_4_la_LDFLAGS = \
	$(OPTIMIZE_LDFLAGS) \
	-version-info $(LIBDACTL_NET_VERSION) \
	$(NULL)

libdactl_net_0_4_la_LIBADD = \
	$(LIBDACTL_LIBS) \
	$(LIBDACTL_NET_LIBS) \
	$(NULL)


if HAVE_INTROSPECTION
-include $(INTROSPECTION_MAKEFILE)

INTROSPECTION_GIRS =
INTROSPECTION_SCANNER_ARGS = --add-include-path=$(srcdir) --warn-all
INTROSPECTION_COMPILER_ARGS = \
	-l libdactl-net-0.4.so.0 \
	--includedir=$(builddir)/../libdactl-core \
	--includedir=$(srcdir)/../libdactl-core
$(builddir)/DactlNet-0.4.gir: $(srcdir)/Dactl-0.4.gir
	$(AM_V_GEN)$(SED) \
		-e 's,Dactl\.,DactlNet.,g' \
		-e 's,namespace name="Dactl",namespace name="DactlNet",g' \
		-e 's,<package name="dactl-net-0.4"/>,<include name="DactlCore" version="0.4"/>\n<package name="dactl-net-0.4"/>,' \
		$< >$@
GIRS = DactlNet-0.4.gir

girdir = $(datadir)/dactl/gir-1.0
gir_DATA = $(GIRS)

typelibdir = $(pkglibdir)/girepository-1.0
typelib_DATA = $(GIRS:.gir=.typelib)

CLEANFILES += $(gir_DATA) $(typelib_DATA)
endif


libdactl_net_0_4_vapi_DEPS = \
	posix \
	json-glib-1.0 \
	libsoup-2.4 \
	libzmq

dactl-net-0.4.deps: Makefile
	$(AM_V_GEN) echo $(libdactl_net_0_4_vapi_DEPS) | tr ' ' '\n' > $@

VAPI_FILES = dactl-net-0.4.vapi
DEPS_FILES = dactl-net-0.4.deps

vapidir = $(VAPIDIR)
vapi_DATA = $(VAPI_FILES) $(DEPS_FILES)
dactl-net.h dactl-net-0.4.vapi Dactl-0.4.gir: libdactl_net_0_4_la_vala.stamp

BUILT_SOURCES += \
	dactl-net.h \
	$(VAPI_FILES) \
	$(DEPS_FILES) \
	DactlNet-0.4.gir \
	Dactl-0.4.gir \
	$(NULL)

-include $(top_srcdir)/git.mk
