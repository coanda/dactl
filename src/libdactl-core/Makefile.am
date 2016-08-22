CLEANFILES =
DISTCLEANFILES =
BUILT_SOURCES =
EXTRA_DIST =

include $(top_srcdir)/common.am
include $(srcdir)/filelist.am

libdactlincdir = $(includedir)/dactl-0.4

libdactlinc_HEADERS = dactl-core.h

lib_LTLIBRARIES = libdactl-core-0.4.la

pkgconfig_DATA = dactl-core-0.4.pc
pkgconfigdir = $(libdir)/pkgconfig

EXTRA_DIST += \
	dactl-core-0.4.pc.in \
	$(NULL)

LIBDACTL_CORE_VERSION=0:4:0

libdactl_core_0_4_la_SOURCES = \
	$(LIBDACTL_CORE_VAPI_SOURCE_FILES) \
	$(LIBDACTL_CORE_NONVAPI_SOURCE_FILES) \
	$(NULL)

libdactl_core_0_4_la_includes = \
	$(DEBUG_CFLAGS) \
	-DPLUGIN_DIR=\""$(plugindir)"\" \
	-DSMALL_ICON_DIR=\""$(smallicondir)"\" \
	-DBIG_ICON_DIR=\""$(bigicondir)"\" \
	$(NULL)

libdactl_core_0_4_la_VALAFLAGS = \
	-H dactl-core.h -C \
	--library=dactl-core-0.4 \
	--gir=Dactl-0.4.gir \
	--vapidir=$(top_srcdir)/vapi \
	--pkg posix \
	--pkg linux \
	--pkg cld-0.3 \
	--pkg comedi \
	--pkg gee-0.8 \
	--pkg gio-2.0 \
	--pkg gmodule-2.0 \
	--pkg libxml-2.0 \
	--pkg libpeas-1.0 \
	$(DACTL_CLD_DEPS_VALAFLAGS) \
	$(DACTL_COMMON_VALAFLAGS) \
	$(NULL)

libdactl_core_0_4_la_CFLAGS = \
	-DG_LOG_DOMAIN=\"libdactl-core\" \
	-DGETTEXT_PACKAGE=\"dactl\" \
	$(AM_CFLAGS) \
	$(LIBDACTL_CORE_CFLAGS) \
	$(DACTL_CLD_DEPS_CFLAGS) \
	$(DACTL_COMMON_DEFINES_CFLAGS) \
	$(OPTIMIZE_CFLAGS) \
	$(libdactl_core_0_4_la_includes) \
	-Wno-deprecated-declarations \
	-Wno-discarded-qualifiers \
	-Wno-implicit-function-declaration \
	-Wno-incompatible-pointer-types \
	-Wno-unused-but-set-variable \
	-Wno-unused-label \
	-Wno-unused-function \
	$(NULL)

libdactl_core_0_4_la_LDFLAGS = \
	$(OPTIMIZE_LDFLAGS) \
	$(DACTL_DATA_DIR_DEFINES) \
	-version-info $(LIBDACTL_CORE_VERSION) \
	$(NULL)

libdactl_core_0_4_la_LIBADD = \
	-lm \
	$(LIBDACTL_CORE_LIBS) \
	$(DACTL_CLD_DEPS_LIBS) \
	$(NULL)

if HAVE_INTROSPECTION
-include $(INTROSPECTION_MAKEFILE)

INTROSPECTION_GIRS =
INTROSPECTION_SCANNER_ARGS = --add-include-path=$(srcdir) --warn-all
INTROSPECTION_COMPILER_ARGS = -l libdactl-core-0.4.so.0
$(builddir)/DactlCore-0.4.gir: $(srcdir)/Dactl-0.4.gir
	$(AM_V_GEN)$(SED) -e 's,Dactl\.,DactlCore.,g' -e \
        's,namespace name="Dactl",namespace name="DactlCore",g' \
        $< >$@
GIRS = DactlCore-0.4.gir

girdir = $(datadir)/gir-1.0
gir_DATA = $(GIRS)

typelibdir = $(libdir)/girepository-1.0
typelib_DATA = $(GIRS:.gir=.typelib)

CLEANFILES += $(gir_DATA) $(typelib_DATA)
endif


libdactl_core_0_4_vapi_DEPS = \
	posix \
	linux \
	cld-0.3 \
	comedi \
	gio-2.0 \
	gee-0.8 \
	libxml-2.0 \
	libpeas-1.0

dactl-core-0.4.deps: Makefile
	$(AM_V_GEN) echo $(libdactl_core_0_4_vapi_DEPS) | tr ' ' '\n' > $@

VAPI_FILES = dactl-core-0.4.vapi
DEPS_FILES = dactl-core-0.4.deps

vapidir = $(VAPIDIR)
vapi_DATA = $(VAPI_FILES) $(DEPS_FILES)
dactl-core.h dactl-core-0.4.vapi Dactl-0.4.gir: libdactl_core_0_4_la_vala.stamp

BUILT_SOURCES += \
	dactl-core.h \
	$(VAPI_FILES) \
	$(DEPS_FILES) \
	dactl-config.vapi \
	DactlCore-0.4.gir \
	Dactl-0.4.gir \
	$(NULL)

-include $(top_srcdir)/git.mk
