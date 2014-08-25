include $(top_srcdir)/common.am
include $(srcdir)/filelist.am

libdactlincdir = $(includedir)/dactl-0.3

libdactlinc_HEADERS = dactl-core.h

lib_LTLIBRARIES = libdactl-core-0.3.la

libdactl_core_0_3_la_SOURCES = \
	$(LIBDACTL_CORE_VAPI_SOURCE_FILES) \
	$(LIBDACTL_CORE_NONVAPI_SOURCE_FILES)

libdactl_core_0_3_la_VALAFLAGS = \
	-H dactl-core.h -C --library=dactl-core-0.3 \
	--gir=Dactl-0.3.gir \
	--vapidir=$(srcdir) \
	--pkg posix \
	$(LIBDACTL_CORE_DEPS_VALAFLAGS) \
	$(DACTL_CLD_DEPS_VALAFLAGS) \
	$(DACTL_COMMON_VALAFLAGS)

libdactl_core_0_3_la_CFLAGS = \
	$(DACTL_COMMON_DEFINES_CFLAGS) \
	$(DACTL_CLD_DEPS_CFLAGS) \
	$(LIBDACTL_CORE_DEPS_CFLAGS) \
	-DPLUGIN_DIR='"$(plugindir)"' \
	-DSMALL_ICON_DIR='"$(smallicondir)"' \
	-DBIG_ICON_DIR='"$(bigicondir)"' \
	-include config.h \
	-DG_LOG_DOMAIN='"Dactl"'

libdactl_core_0_3_la_LIBADD = \
	$(DACTL_CLD_DEPS_LIBS) \
	$(LIBDACTL_CORE_DEPS_LIBS) \
	-lm

DACTL_CORE_VERSION=0:3:0
libdactl_core_0_3_la_LDFLAGS = \
	$(DACTL_DATA_DIR_DEFINES) \
	-version-info $(DACTL_CORE_VERSION)

BUILT_SOURCES = \
	dactl-core-0.3.vapi \
	dactl-core.h

VAPI_FILES = dactl-core-0.3.vapi
DEPS_FILES = dactl-core-0.3.deps

vapidir = $(VAPIDIR)
vapi_DATA = $(VAPI_FILES) $(DEPS_FILES)
dactl-core-0.3.vapi dactl-core.h Dactl-0.3.gir: libdactl_core_0_3_la_vala.stamp

-include $(INTROSPECTION_MAKEFILE)
INTROSPECTION_GIRS=
INTROSPECTION_SCANNER_ARGS=
INTROSPECTION_COMPILER_ARGS= -l libdactl-core-0.3.so.2
$(builddir)/DactlCore-0.3.gir: $(srcdir)/Dactl-0.3.gir
	$(AM_V_GEN)$(SED) -e 's,Dactl\.,DactlCore.,g' -e 's,namespace name="Dactl",namespace name="DactlCore",g' $< >$@
GIRS = DactlCore-0.3.gir

girdir=$(datadir)/gir-1.0
dist_gir_DATA = $(GIRS)

typelibdir = $(libdir)/girepository-1.0
nodist_typelib_DATA = $(GIRS:.gir=.typelib)

DISTCLEANFILES = DactlCore-0.3.typelib

MAINTAINERCLEANFILES += $(BUILT_SOURCES)

EXTRA_DIST = \
	dactl-config.vapi \
	$(VAPI_FILES) \
	$(DEPS_FILES) \
	$(BUILT_SOURCES) \
	DactlCore-0.3.gir \
	Dactl-0.3.gir
