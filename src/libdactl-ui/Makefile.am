CLEANFILES =
DISTCLEANFILES =
BUILT_SOURCES =
EXTRA_DIST =

SUBDIRS = extensions

include $(top_srcdir)/common.am
include $(srcdir)/filelist.am

pkglibdir = $(libdir)/dactl
pkglib_LTLIBRARIES = libdactl-ui-0.4.la

headersdir = $(includedir)/dactl-0.4
nobase_headers_DATA =

pkgconfig_DATA = dactl-ui-0.4.pc
pkgconfigdir = $(libdir)/pkgconfig

EXTRA_DIST += \
	dactl-ui-0.4.pc.in \
	$(NULL)

LIBDACTL_UI_VERSION=0:4:0

gresource_file = libdactl-ui.gresource.xml
resource_files = $(shell $(GLIB_COMPILE_RESOURCES) --generate-dependencies $(gresource_file))
resources.c: $(gresource_file) $(resource_files)
	$(AM_V_GEN) $(GLIB_COMPILE_RESOURCES) --target=$@ --sourcedir=. --generate-source $<

BUILT_SOURCES += \
	resources.c \
	$(gresource_file) \
	$(NULL)

libdactl_ui_0_4_la_public_headers = \
	$(NULL)

libdactl_ui_0_4_la_public_sources = \
	resources.c \
	$(NULL)

libdactl_ui_0_4_la_SOURCES = \
	$(libdactl_ui_0_4_la_public_sources) \
	$(LIBDACTL_UI_VAPI_SOURCE_FILES) \
	$(LIBDACTL_UI_NONVAPI_SOURCE_FILES)

libdactl_ui_0_4_la_includes = \
	$(DEBUG_CFLAGS) \
	-I$(top_srcdir)/src/libdactl-core \
	-I$(top_srcdir)/src/libdactl-net \
	$(NULL)

libdactl_ui_0_4_la_VALAFLAGS = \
	--target-glib=2.44 \
	--thread \
	-H dactl-ui.h -C \
	--library=dactl-ui-0.4 \
	--gir=Dactl-0.4.gir \
	--gresources $(gresource_file) \
	--vapidir=$(top_srcdir)/vapi \
	--pkg posix \
	--pkg gee-0.8 \
	--pkg glib-2.0 \
	--pkg gio-2.0 \
	--pkg gtk+-3.0 \
	--pkg gtksourceview-3.0 \
	--pkg cld-0.3 \
	--pkg libxml-2.0 \
	--pkg libpeas-1.0 \
	--pkg libpeas-gtk-1.0 \
	--pkg libsoup-2.4 \
	--pkg librsvg-2.0 \
	$(DACTL_CLD_DEPS_VALAFLAGS) \
	$(DACTL_COMMON_LIBDACTL_CORE_VALAFLAGS) \
	$(DACTL_COMMON_VALAFLAGS)

libdactl_ui_0_4_la_CFLAGS = \
	-DWEB_EXTENSION_DIR=\""$(extensiondir)"\" \
	-DG_LOG_DOMAIN=\"libdactl-ui\" \
	-DGETTEXT_PACKAGE=\"dactl\" \
	$(AM_CFLAGS) \
	$(LIBDACTL_CFLAGS) \
	$(LIBDACTL_UI_CFLAGS) \
	$(DACTL_CLD_DEPS_CFLAGS) \
	$(DACTL_COMMON_LIBDACTL_CORE_CFLAGS) \
	$(OPTIMIZE_CFLAGS) \
	$(libdactl_ui_0_4_la_includes) \
	-Wno-deprecated-declarations \
	-Wno-discarded-qualifiers \
	-Wno-implicit-function-declaration \
	-Wno-incompatible-pointer-types \
	-Wno-unused-but-set-variable \
	-Wno-unused-label \
	-Wno-unused-function

libdactl_ui_0_4_la_LDFLAGS = \
	$(OPTIMIZE_LDFLAGS) \
	$(DACTL_DATA_DIR_DEFINES) \
	-version-info $(LIBDACTL_UI_VERSION)

libdactl_ui_0_4_la_LIBADD = \
	$(LIBDACTL_LIBS) \
	$(LIBDACTL_UI_LIBS) \
	$(DACTL_CLD_DEPS_LIBS) \
	$(DACTL_COMMON_LIBDACTL_CORE_LIBS)


if ENABLE_WEBKIT
libdactl_ui_0_4_la_SOURCES += \
	dactl-ui-webkit-widget.vala \
	dactl-ui-rich-content.vala \
	$(NULL)
libdactl_ui_0_4_la_VALAFLAGS += --pkg webkit2gtk-4.0
libdactl_ui_0_4_la_CFLAGS += $(WEBKIT_CFLAGS)
libdactl_ui_0_4_la_LIBADD += $(WEBKIT_LIBS)
libdactl_ui_0_4_la_LDFLAGS += $(WEBKIT_LDFLAGS)
endif


if HAVE_INTROSPECTION
-include $(INTROSPECTION_MAKEFILE)

INTROSPECTION_GIRS =
INTROSPECTION_SCANNER_ARGS = --add-include-path=$(srcdir) --warn-all
INTROSPECTION_COMPILER_ARGS = \
	-l libdactl-ui-0.4.so.0 \
	--includedir=$(builddir)/../libdactl-core \
	--includedir=$(srcdir)/../libdactl-core
$(builddir)/DactlUI-0.4.gir: $(srcdir)/Dactl-0.4.gir
	$(AM_V_GEN)$(SED) \
		-e 's,Dactl\.,DactlUI.,g' \
		-e 's,namespace name="Dactl",namespace name="DactlUI",g' \
		-e 's,DactlUI\.Object,DactlCore.Object,g' \
		-e 's,DactlUI\.Buildable,DactlCore.Buildable,g' \
		-e 's,DactlUI\.Container,DactlCore.Container,g' \
		-e 's,DactlUI\.CldAdapter,DactlCore.CldAdapter,g' \
		-e 's,DactlUI\.Extension,DactlCore.Extension,g' \
		-e 's,DactlUI\.Factory,DactlCore.Factory,g' \
		-e 's,<package name="dactl-ui-0.4"/>,<include name="DactlCore" version="0.4"/>\n<package name="dactl-ui-0.4"/>,' \
		$< >$@
GIRS = DactlUI-0.4.gir

girdir = $(datadir)/gir-1.0
gir_DATA = $(GIRS)

typelibdir = $(libdir)/girepository-1.0
typelib_DATA = $(GIRS:.gir=.typelib)

CLEANFILES += $(gir_DATA) $(typelib_DATA)
endif


libdactl_ui_0_4_vapi_DEPS = \
	gee-0.8 \
	gio-2.0 \
	gtk+-3.0 \
	libpeas-1.0 \
	librsvg-2.0 \
	libxml-2.0

dactl-ui-0.4.deps: Makefile
	$(AM_V_GEN) echo $(libdactl_ui_0_4_vapi_DEPS) | tr ' ' '\n' > $@

VAPI_FILES = dactl-ui-0.4.vapi
DEPS_FILES = dactl-ui-0.4.deps

vapidir = $(VAPIDIR)
vapi_DATA = $(VAPI_FILES) $(DEPS_FILES)
dactl-ui.h dactl-cli-0.4.vapi: libdactl_ui_0_4_la_vala.stamp

BUILT_SOURCES += \
	dactl-ui.h \
	$(VAPI_FILES) \
	$(DEPS_FILES) \
	DactlUI-0.4.gir \
	Dactl-0.4.gir \
	$(NULL)

-include $(top_srcdir)/git.mk
