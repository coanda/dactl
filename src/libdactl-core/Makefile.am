include $(top_srcdir)/common.am
include $(srcdir)/filelist.am

libdactlincdir = $(includedir)/dactl-0.3

libdactlinc_HEADERS = dactl-core.h

lib_LTLIBRARIES = libdactl-core-0.3.la

libdactl_core_0_3_la_SOURCES = \
	$(LIBDACTL_CORE_VAPI_SOURCE_FILES) \
	$(LIBDACTL_CORE_NONVAPI_SOURCE_FILES) \
	$(NULL)

libdactl_core_0_3_la_VALAFLAGS = \
	-H dactl-core.h -C --library=dactl-core-0.3 \
	--gir=Dactl-0.3.gir \
	--vapidir=$(top_srcdir)/vapi \
	--pkg posix \
	--pkg linux \
	$(LIBDACTL_CORE_DEPS_VALAFLAGS) \
	$(DACTL_CLD_DEPS_VALAFLAGS) \
	$(DACTL_COMMON_VALAFLAGS) \
	$(NULL)

libdactl_core_0_3_la_CFLAGS = \
	-include config.h \
	-DPLUGIN_DIR=\""$(plugindir)"\" \
	-DSMALL_ICON_DIR=\""$(smallicondir)"\" \
	-DBIG_ICON_DIR=\""$(bigicondir)"\" \
	-DG_LOG_DOMAIN=\"libdactl-core\" \
	-DGETTEXT_PACKAGE=\"dactl\" \
	$(DACTL_COMMON_DEFINES_CFLAGS) \
	$(DACTL_CLD_DEPS_CFLAGS) \
	$(LIBDACTL_CORE_DEPS_CFLAGS) \
	-Wno-deprecated-declarations \
	-Wno-discarded-qualifiers \
	-Wno-implicit-function-declaration \
	-Wno-incompatible-pointer-types \
	-Wno-unused-but-set-variable \
	-Wno-unused-label \
	-Wno-unused-function \
	$(NULL)

libdactl_core_0_3_la_LIBADD = \
	-lm \
	$(DACTL_CLD_DEPS_LIBS) \
	$(LIBDACTL_CORE_DEPS_LIBS) \
	$(NULL)

DACTL_CORE_VERSION=0:3:0
libdactl_core_0_3_la_LDFLAGS = \
	$(DACTL_DATA_DIR_DEFINES) \
	-version-info $(DACTL_CORE_VERSION) \
	$(NULL)

BUILT_SOURCES = \
	Dactl-0.3.gir \
	dactl-core-0.3.vapi \
	dactl-core.h \
	$(NULL)

VAPI_FILES = dactl-core-0.3.vapi
DEPS_FILES = dactl-core-0.3.deps

vapidir = $(VAPIDIR)
vapi_DATA = $(VAPI_FILES) $(DEPS_FILES)
dactl-core-0.3.vapi dactl-core.h Dactl-0.3.gir: libdactl_core_0_3_la_vala.stamp

if HAVE_INTROSPECTION
-include $(INTROSPECTION_MAKEFILE)
INTROSPECTION_GIRS =
INTROSPECTION_SCANNER_ARGS =
INTROSPECTION_COMPILER_ARGS = -l libdactl-core-0.3.so.0
$(builddir)/DactlCore-0.3.gir: $(srcdir)/Dactl-0.3.gir
	$(AM_V_GEN)$(SED) -e 's,Dactl\.,DactlCore.,g' -e \
        's,namespace name="Dactl",namespace name="DactlCore",g' \
        $< >$@
GIRS = DactlCore-0.3.gir

girdir = $(datadir)/gir-1.0
gir_DATA = $(GIRS)

typelibdir = $(libdir)/girepository-1.0
typelib_DATA = $(GIRS:.gir=.typelib)

CLEANFILES = $(gir_DATA) $(typelib_DATA)
endif

MAINTAINERCLEANFILES += $(BUILT_SOURCES)

EXTRA_DIST = \
	dactl-config.vapi \
	$(VAPI_FILES) \
	$(DEPS_FILES) \
	$(BUILT_SOURCES) \
	DactlCore-0.3.gir \
	Dactl-0.3.gir \
	$(NULL)

-include $(top_srcdir)/git.mk
