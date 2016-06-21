CLEANFILES =
DISTCLEANFILES =
BUILT_SOURCES =
EXTRA_DIST =

SUBDIRS = extensions

include $(top_srcdir)/common.am
include $(srcdir)/filelist.am

libdactl_ui_includedir = $(includedir)/dactl-0.3
libdactl_ui_include_HEADERS = dactl-ui.h

lib_LTLIBRARIES = libdactl-ui-0.3.la

LIBDACTL_UI_VERSION=0:3:0

gresource_file = libdactl-ui.gresource.xml
resource_files = $(shell $(GLIB_COMPILE_RESOURCES) --generate-dependencies $(gresource_file))
resources.c: $(gresource_file) $(resource_files)
	$(AM_V_GEN) $(GLIB_COMPILE_RESOURCES) --target=$@ --sourcedir=. --generate-source $<

BUILT_SOURCES += \
	resources.c \
	$(gresource_file) \
	$(NULL)

libdactl_ui_0_3_la_SOURCES = \
	$(BUILT_SOURCES) \
	$(LIBDACTL_UI_VAPI_SOURCE_FILES) \
	$(LIBDACTL_UI_NONVAPI_SOURCE_FILES) \
	$(NULL)

libdactl_ui_0_3_la_VALAFLAGS = \
	--vapidir=$(top_srcdir)/vapi \
	-H dactl-ui.h -C --library=dactl-ui-0.3 \
	--gir=Dactl-0.3.gir --pkg posix \
	--gresources $(gresource_file) \
	$(LIBDACTL_UI_DEPS_VALAFLAGS) \
	$(DACTL_CLD_DEPS_VALAFLAGS) \
	$(DACTL_COMMON_LIBDACTL_CORE_VALAFLAGS) \
	$(DACTL_COMMON_VALAFLAGS) \
	$(NULL)

libdactl_ui_0_3_la_CFLAGS = \
	-DWEB_EXTENSIONS_DIR=\""$(extensionsdir)"\" \
	-DG_LOG_DOMAIN=\"libdactl-ui\" \
	-DGETTEXT_PACKAGE=\"dactl\" \
	$(LIBDACTL_UI_DEPS_CFLAGS) \
	$(DACTL_CLD_DEPS_CFLAGS) \
	$(DACTL_COMMON_LIBDACTL_CORE_CFLAGS) \
	-Wno-deprecated-declarations \
	-Wno-discarded-qualifiers \
	-Wno-implicit-function-declaration \
	-Wno-incompatible-pointer-types \
	-Wno-unused-but-set-variable \
	-Wno-unused-label \
	-Wno-unused-function \
	$(NULL)

libdactl_ui_0_3_la_LIBADD = \
	$(LIBDACTL_UI_DEPS_LIBS) \
	$(DACTL_CLD_DEPS_LIBS) \
	$(DACTL_COMMON_LIBDACTL_CORE_LIBS) \
	$(NULL)

libdactl_ui_0_3_la_LDFLAGS = \
	$(DACTL_DATA_DIR_DEFINES) \
	-version-info $(LIBDACTL_UI_VERSION) \
	$(NULL)


if ENABLE_WEBKIT
libdactl_ui_0_3_la_SOURCES += \
	dactl-webkit-widget.vala \
	dactl-rich-content.vala \
	$(NULL)
libdactl_ui_0_3_la_VALAFLAGS += --pkg webkit2gtk-4.0
libdactl_ui_0_3_la_CFLAGS += $(WEBKIT_CFLAGS)
libdactl_ui_0_3_la_LIBADD += $(WEBKIT_LIBS)
endif


if HAVE_INTROSPECTION
-include $(INTROSPECTION_MAKEFILE)
INTROSPECTION_GIRS =
INTROSPECTION_SCANNER_ARGS =
INTROSPECTION_COMPILER_ARGS = \
	-l libdactl-ui-0.3.so.0 \
	--includedir=$(builddir)/../libdactl-core \
	--includedir=$(srcdir)/../libdactl-core
$(builddir)/DactlUI-0.3.gir: $(srcdir)/Dactl-0.3.gir
	$(AM_V_GEN)$(SED) -e 's,Dactl\.,DactlUI.,g' \
		-e 's,namespace name="Dactl",namespace name="DactlUI",g' \
		-e 's,DactlUI\.Object,DactlCore.Object,g' \
		-e 's,DactlUI\.Buildable,DactlCore.Buildable,g' \
		-e 's,DactlUI\.Container,DactlCore.Container,g' \
		-e 's,DactlUI\.CldAdapter,DactlCore.CldAdapter,g' \
		-e 's,DactlUI\.Factory,DactlCore.Factory,g' \
		-e 's,<package name="dactl-ui-0.3"/>,<include name="DactlCore" version="0.3"/>\n<package name="dactl-ui-0.3"/>,' \
		$< >$@
GIRS = DactlUI-0.3.gir

girdir = $(datadir)/gir-1.0
gir_DATA = $(GIRS)

typelibdir = $(libdir)/girepository-1.0
typelib_DATA = $(GIRS:.gir=.typelib)

CLEANFILES += $(gir_DATA) $(typelib_DATA)
endif


VAPI_FILES = dactl-ui-0.3.vapi
DEPS_FILES = dactl-ui-0.3.deps

vapidir = $(VAPIDIR)
vapi_DATA = $(VAPI_FILES) $(DEPS_FILES)
dactl-ui.h dactl-ui-0.3.vapi Dactl-0.3.gir: libdactl_ui_0_3_la_vala.stamp

BUILT_SOURCES += \
	dactl-ui.h \
	$(VAPI_FILES) \
	$(DEPS_FILES) \
	DactlUI-0.3.gir \
	Dactl-0.3.gir \
	$(NULL)

-include $(top_srcdir)/git.mk
