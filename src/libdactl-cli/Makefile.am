CLEANFILES =
DISTCLEANFILES =
BUILT_SOURCES =
EXTRA_DIST =

pkglibdir = $(libdir)/dactl
pkglib_LTLIBRARIES = libdactl-cli-0.4.la

headersdir = $(includedir)/dactl-@VERSION@/libdactl-cli
nobase_headers_DATA =

pkgconfig_DATA = dactl-cli-0.4.pc
pkgconfigdir = $(libdir)/pkgconfig

EXTRA_DIST += \
	dactl-cli-0.4.pc.in \
	$(NULL)

LIBDACTL_CLI_VERSION=0:4:0

libdactl_cli_0_4_la_public_headers = \
	$(NULL)

libdactl_cli_0_4_la_public_sources = \
	dactl-cli-application.c \
	dactl-cli-factory.c \
	$(NULL)

libdactl_cli_0_4_la_VALASOURCES = \
	dactl-cli-application.vala \
	dactl-cli-factory.vala \
	$(NULL)

libdactl_cli_0_4_la_SOURCES = \
	$(libdactl_cli_0_4_la_VALASOURCES) \
	$(NULL)

libdactl_cli_0_4_la_includes = \
	$(DEBUG_CFLAGS) \
	-DPACKAGE_DATADIR="\"${datadir}\"" \
	-DPACKAGE_LOCALE_DIR=\""${datadir}/locale"\" \
	-DPACKAGE_LIBDIR=\""${libdir}"\" \
	-DBUILDDIR=\""${abs_top_builddir}"\" \
	-DSRCDIR=\""${abs_top_srcdir}"\" \
	-I$(top_srcdir)/src/libdactl-core \
	$(NULL)

libdactl_cli_0_4_la_VALAFLAGS = \
	-H dactl-cli.h -C \
	--library=dactl-cli-0.4 \
	--gir=Dactl-0.4.gir \
	--vapidir=$(top_srcdir)/vapi \
	--vapidir=$(top_srcdir)/src/libdactl-core \
	--pkg posix \
	--pkg gio-2.0 \
	--pkg gee-0.8 \
	--pkg dactl-core-0.4 \
	$(NULL)

libdactl_cli_0_4_la_CFLAGS = \
	-DG_LOG_DOMAIN=\"libdactl-cli\" \
	-DGETTEXT_PACKAGE=\"dactl\" \
	$(AM_CFLAGS) \
	$(LIBDACTL_CFLAGS) \
	$(LIBDACTL_CLI_CFLAGS) \
	$(OPTIMIZE_CFLAGS) \
	$(DEBUG_CFLAGS) \
	$(libdactl_cli_0_4_la_includes) \
	-Wno-deprecated-declarations \
	-Wno-discarded-qualifiers \
	-Wno-implicit-function-declaration \
	-Wno-incompatible-pointer-types \
	-Wno-unused-but-set-variable \
	-Wno-unused-label \
	-Wno-unused-function \
	$(NULL)

libdactl_cli_0_4_la_LDFLAGS = \
	$(OPTIMIZE_LDFLAGS) \
	-version-info $(LIBDACTL_CLI_VERSION) \
	$(NULL)

libdactl_cli_0_4_la_LIBADD = \
	$(LIBDACTL_LIBS) \
	$(LIBDACTL_CLI_LIBS) \
	$(NULL)


if HAVE_INTROSPECTION
-include $(INTROSPECTION_MAKEFILE)

INTROSPECTION_GIRS =
INTROSPECTION_SCANNER_ARGS = --add-include-path=$(srcdir) --warn-all
INTROSPECTION_COMPILER_ARGS = \
	-l libdactl-cli-0.4.so.0 \
	--includedir=$(builddir)/../libdactl-core \
	--includedir=$(srcdir)/../libdactl-core
$(builddir)/DactlCLI-0.4.gir: $(srcdir)/Dactl-0.4.gir
	$(AM_V_GEN)$(SED) \
		-e 's,Dactl\.,DactlCLI.,g' \
		-e 's,namespace name="Dactl",namespace name="DactlCLI",g' \
		-e 's,<package name="dactl-cli-0.4"/>,<include name="DactlCore" version="0.4"/>\n<package name="dactl-cli-0.4"/>,' \
		$< >$@
GIRS = DactlCLI-0.4.gir

girdir = $(datadir)/dactl/gir-1.0
gir_DATA = $(GIRS)

typelibdir = $(pkglibdir)/girepository-1.0
typelib_DATA = $(GIRS:.gir=.typelib)

CLEANFILES += $(gir_DATA) $(typelib_DATA)
endif


libdactl_cli_0_4_vapi_DEPS = \
	gio-2.0 \
	libpeas-1.0

dactl-cli-0.4.deps: Makefile
	$(AM_V_GEN) echo $(libdactl_cli_0_4_vapi_DEPS) | tr ' ' '\n' > $@

VAPI_FILES = dactl-cli-0.4.vapi
DEPS_FILES = dactl-cli-0.4.deps

vapidir = $(VAPIDIR)
vapi_DATA = $(VAPI_FILES) $(DEPS_FILES)
dactl-cli.h dactl-cli-0.4.vapi Dactl-0.4.gir: libdactl_cli_0_4_la_vala.stamp

BUILT_SOURCES += \
	dactl-cli.h \
	$(VAPI_FILES) \
	$(DEPS_FILES) \
	DactlCLI-0.4.gir \
	Dactl-0.4.gir \
	$(NULL)

-include $(top_srcdir)/git.mk
