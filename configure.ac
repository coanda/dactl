AC_PREREQ([2.69])


dnl ***********************************************************************
dnl Define Versioning Information
dnl ***********************************************************************
m4_define([dactl_major_version],[0])
m4_define([dactl_minor_version],[3])
m4_define([dactl_micro_version],[5])
m4_define([dactl_version],[dactl_major_version.dactl_minor_version.dactl_micro_version])
m4_define([dactl_interface_age],[0])
m4_define([dactl_bugreport_url],
              [https://github.com/coanda/dactl/issues])
m4_define([dactl_debug_default],
                    [m4_if(m4_eval(dactl_minor_version % 2), [1], [yes], [minimum])])


dnl ***********************************************************************
dnl Initialize Autoconf
dnl ***********************************************************************
AC_INIT([dactl],
        [dactl_version],
        [dactl_bugreport_url],
        [dactl],
        [https://github.com/coanda/dactl])
AC_CONFIG_HEADERS([config.h])
AC_CONFIG_SRCDIR([src/dactl/dactl-main.vala])
AC_CONFIG_MACRO_DIR([build/autotools])
AC_CONFIG_AUX_DIR([build])
AC_SUBST(ACLOCAL_AMFLAGS, "-I build/autotools")
AC_CANONICAL_HOST


dnl ***********************************************************************
dnl Make Version Info Available to .in Files
dnl ***********************************************************************
MAJOR_VERSION=dactl_major_version
MINOR_VERSION=dactl_minor_version
MICRO_VERSION=dactl_micro_version
LIBDACTL_CORE_VERSION=dactl_version
LIBDACTL_CLI_VERSION=dactl_version
LIBDACTL_LOG_VERSION=dactl_version
LIBDACTL_NET_VERSION=dactl_version
LIBDACTL_UI_VERSION=dactl_version
AC_SUBST(MAJOR_VERSION)
AC_SUBST(MINOR_VERSION)
AC_SUBST(MICRO_VERSION)
AC_SUBST(LIBDACTL_CORE_VERSION)
AC_SUBST(LIBDACTL_CLI_VERSION)
AC_SUBST(LIBDACTL_LOG_VERSION)
AC_SUBST(LIBDACTL_NET_VERSION)
AC_SUBST(LIBDACTL_UI_VERSION)


dnl ***********************************************************************
dnl Initialize Automake
dnl ***********************************************************************
AM_SILENT_RULES([yes])
AM_INIT_AUTOMAKE([1.11 foreign subdir-objects tar-ustar no-dist-gzip dist-xz])
AM_MAINTAINER_MODE([enable])


dnl ***********************************************************************
dnl Internationalization
dnl ***********************************************************************
AX_REQUIRE_DEFINED([IT_PROG_INTLTOOL])
IT_PROG_INTLTOOL([0.50.1])
GETTEXT_PACKAGE=AC_PACKAGE_TARNAME
AC_DEFINE_UNQUOTED([GETTEXT_PACKAGE], ["$GETTEXT_PACKAGE"], [GETTEXT package name])
AC_SUBST(GETTEXT_PACKAGE)
AM_GLIB_GNU_GETTEXT


dnl ***********************************************************************
dnl Check for Required Programs
dnl ***********************************************************************
AC_PROG_CC
AM_PROG_CC_C_O
AC_PROG_CXX
AM_PROG_VALAC([0.30.0])
AC_PROG_INSTALL
AC_PROG_LN_S
AC_PROG_MAKE_SET
AC_PATH_PROG([GLIB_GENMARSHAL], [glib-genmarshal])
AC_PATH_PROG([GLIB_MKENUMS], [glib-mkenums])
AC_PATH_PROG([GLIB_COMPILE_RESOURCES], [glib-compile-resources])
AC_HEADER_STDC
PKG_PROG_PKG_CONFIG([0.22])
GOBJECT_INTROSPECTION_CHECK([1.42.0])
VAPIGEN_CHECK
GLIB_GSETTINGS
APPSTREAM_XML

AC_ARG_VAR([DESKTOP_FILE_VALIDATE], [the desktop-file-validate program])
AC_PATH_PROG([DESKTOP_FILE_VALIDATE], [desktop-file-validate], [])
if test -z "$DESKTOP_FILE_VALIDATE"; then
	AC_MSG_ERROR([desktop-file-validate not found])
fi


dnl ***********************************************************************
dnl Check for Required Headers
dnl ***********************************************************************
AC_CHECK_HEADERS(stdlib.h)
AC_CHECK_LIB(m, floor, PACKAGE_LIBS="$PACKAGE_LIBS -lm",)


dnl * XXX *****************************************************************
dnl *  - not sure if anything from here

AC_SUBST(abs_top_builddir)
GOBJECT_INTROSPECTION_REQUIRE([0.9.0])
AC_SET_DEFAULT_PATHS_SYSTEM
SYSCONFDIR="$ac_default_prefix/etc"
AC_SUBST(SYSCONFDIR)
dnl Add setup for installation directories
AC_DEFINE_UNQUOTED(DATADIR, "$SYSCONFDIR/$PACKAGE",
                   [Define the architecture-independent data directory.])
AC_DEFINE_UNQUOTED(UI_DIR, "$ac_default_prefix/share/$PACKAGE/ui",
                   [Define the read-only user interface files directory.])

dnl *  - to here is required
dnl * XXX *****************************************************************


dnl ***********************************************************************
dnl Allow user to update application mime type
dnl - always enabling results in slow make install w/ update-mime-database
dnl ***********************************************************************
AC_ARG_ENABLE(mime,
              AS_HELP_STRING([--enable-mime=@<:@no/yes@:>@],
                             [update mime database @<:@default=no@:>@]),
              ,
              enable_mime=no)
AS_IF([test "x$enable_mime" = "xyes"],[enable_mime=yes ENABLE_MIME=1],[ENABLE_MIME=0])
AC_SUBST(ENABLE_MIME)
AM_CONDITIONAL(ENABLE_MIME, test "x$enable_mime" = "xyes")


dnl ***********************************************************************
dnl Setup Debug and Tracing Support
dnl ***********************************************************************
AC_ARG_ENABLE(tracing,
              AS_HELP_STRING([--enable-tracing=@<:@no/yes@:>@],
                             [add extra debugging information @<:@default=no@:>@]),
              ,
              enable_tracing=no)
AS_IF([test "x$enable_tracing" = "xyes"],[enable_debug=yes ENABLE_TRACING=1],[ENABLE_TRACING=0])
AC_SUBST(ENABLE_TRACING)

AC_ARG_ENABLE(debug,
              AS_HELP_STRING([--enable-debug=@<:@no/minimum/yes@:>@],
                             [turn on debugging @<:@default=dactl_debug_default@:>@]),
              ,
              enable_debug=dactl_debug_default)
AS_CASE(["$enable_debug"],
        [yes],[
            DEBUG_CFLAGS="$DEBUG_CFLAGS -O0"
            DEBUG_CFLAGS="$DEBUG_CFLAGS -g"
        ],
        [minimum],[
            DEBUG_CFLAGS="$DEBUG_CFLAGS -DG_DISABLE_CAST_CHECKS"
        ],
        [no],[
            DEBUG_CFLAGS="$DEBUG_CFLAGS -DG_DISABLE_ASSERT"
            DEBUG_CFLAGS="$DEBUG_CFLAGS -DG_DISABLE_CHECKS"
            DEBUG_CFLAGS="$DEBUG_CFLAGS -DG_DISABLE_CAST_CHECKS"
        ],
        [])
AC_SUBST(DEBUG_CFLAGS)

BUGREPORT_URL=dactl_bugreport_url
AC_SUBST(BUGREPORT_URL)


dnl ***********************************************************************
dnl Check for Required Packages
dnl ***********************************************************************
m4_define([glib_required_version], [2.46.0])
m4_define([gee_required_version], [0.18.0])
m4_define([gtk_required_version], [3.18.1])
m4_define([libxml_required_version], [2.9.0])
m4_define([peas_required_version], [1.16.0])
m4_define([cld_required_version], [0.3.0])
m4_define([soup_required_version], [2.4.0])
m4_define([json_required_version], [1.0.0])
m4_define([zmq_required_version], [3.2.0])

PKG_CHECK_MODULES(LIBDACTL_CLI, [glib-2.0 >= glib_required_version
                                 gee-0.8 >= gee_required_version
                                 libxml-2.0 >= libxml_required_version
                                 libpeas-1.0 >= peas_required_version
                                 cld-0.3 >= cld_required_version])
PKG_CHECK_MODULES(LIBDACTL_LOG, [gio-2.0 >= glib_required_version
                                 libzmq >= zmq_required_version])
PKG_CHECK_MODULES(LIBDACTL_NET, [libsoup-2.4 >= soup_required_version
                                 json-glib-1.0 >= json_required_version
                                 libzmq > zmq_required_version])

dnl Library checks
VALAFLAGS="--enable-deprecated --target-glib=2.44 $VALAFLAGS"

dnl Need to work these in to simplify checking
DACTL_BASE_MODULES="gee-0.8 libxml-2.0 libpeas-1.0 libpeas-gtk-1.0"
DACTL_BASE_MODULES_VALAFLAGS="--pkg gee-0.8 --pkg libxml-2.0 --pkg glib-extra --pkg libpeas-1.0 --pkg libpeas-gtk-1.0"

PKG_CHECK_MODULES([LIBDACTL_CORE_DEPS], [$DACTL_BASE_MODULES gio-2.0 gmodule-2.0])
LIBDACTL_CORE_DEPS_VALAFLAGS="$DACTL_BASE_MODULES_VALAFLAGS --pkg gio-2.0 --pkg gmodule-2.0"
AC_SUBST([LIBDACTL_CORE_DEPS_VALAFLAGS])

DACTL_PLUGIN_COMMON_VALAFLAGS="$LIBDACTL_CORE_DEPS_VALAFLAGS"
AC_SUBST([DACTL_PLUGIN_COMMON_VALAFLAGS])

DACTL_COMMON_MODULES="$DACTL_BASE_MODULES"
DACTL_COMMON_MODULES_VALAFLAGS="$DACTL_BASE_MODULES_VALAFLAGS"
AC_SUBST([DACTL_COMMON_MODULES_VALAFLAGS])

PKG_CHECK_MODULES([DACTL_DEPS], [$DACTL_COMMON_MODULES gio-2.0 gmodule-2.0])
DACTL_DEPS_VALAFLAGS="$DACTL_COMMON_MODULES_VALAFLAGS --pkg gio-2.0 --pkg gmodule-2.0"
AC_SUBST([DACTL_DEPS_VALAFLAGS])

PKG_CHECK_MODULES([DACTL_UI_DEPS], [gtk+-3.0 librsvg-2.0 gtksourceview-3.0 libsoup-2.4])
DACTL_UI_MODULES="gtk+-3.0 librsvg-2.0 gtksourceview-3.0 libsoup-2.4"
DACTL_UI_DEPS_VALAFLAGS="--pkg gtk+-3.0 --pkg cogl-1.0 --pkg librsvg-2.0 --pkg gtksourceview-3.0 --pkg libsoup-2.4"
AC_SUBST([DACTL_UI_DEPS_VALAFLAGS])
DACTL_PLUGIN_COMMON_VALAFLAGS="$DACTL_PLUGIN_COMMON_VALAFLAGS $DACTL_UI_DEPS_VALAFLAGS"

PKG_CHECK_MODULES([LIBDACTL_UI_DEPS], [$DACTL_BASE_MODULES $DACTL_UI_MODULES])
LIBDACTL_UI_DEPS_VALAFLAGS="$DACTL_BASE_MODULES_VALAFLAGS $DACTL_UI_DEPS_VALAFLAGS"
AS_IF([test "x$try_cld" = "xyes"], [LIBDACTL_UI_DEPS_VALAFLAGS="$LIBDACTL_UI_DEPS_VALAFLAGS $DACTL_CLD_DEPS_VALAFLAGS"])
AC_SUBST([LIBDACTL_UI_DEPS_VALAFLAGS])

dnl Check if building CLD support was requested
dnl XXX CLD is more of a requirement than an option at this point but the hope
dnl     is that dactl can be more generic and function with it as an engine
AC_ARG_WITH(cld,
    AS_HELP_STRING([--without-cld], [Do not build with CLD support]),
    [try_cld=$withval], [try_cld=yes])

HAVE_CLD=no
AS_IF([test "x$try_cld" = "xyes"],
      [PKG_CHECK_MODULES([DACTL_CLD_DEPS], [cld-0.3 comedi gio-2.0 gsl sqlite3 gee-0.8 libxml-2.0],
	    [
           DACTL_CHECK_PACKAGES([cld-0.3 comedi gio-2.0 gsl sqlite3 gee-0.8 libxml-2.0], [HAVE_CLD=yes])
           DACTL_CLD_DEPS_VALAFLAGS="--pkg cld-0.3 --pkg comedi --pkg gio-2.0 --pkg gsl --pkg sqlite3 --pkg gee-0.8 --pkg libxml-2.0"
	       DACTL_PLUGIN_COMMON_VALAFLAGS="$DACTL_PLUGIN_COMMON_VALAFLAGS $DACTL_CLD_DEPS_VALAFLAGS"
           AC_SUBST([DACTL_CLD_DEPS_VALAFLAGS])
        ],
        [
          AC_MSG_WARN([CLD dependencies not found.])
          AC_MSG_WARN([CLD support will not be built.])
        ])])

AM_CONDITIONAL(USE_CLD, test "x$HAVE_CLD" = "xyes")

dnl XXX slowly switching to this as a simpler more sensible method
m4_define([pygobject_required_version], [3.18.0])

PKG_CHECK_MODULES(PYGOBJECT,[pygobject-3.0 >= pygobject_required_version],
                            [have_pygobject=yes]
                            [have_pygobject=no])

dnl ***********************************************************************
dnl Check if we have WebKit support
dnl ***********************************************************************
m4_define([webkit_required_version], [2.12.0])
AC_ARG_ENABLE([webkit],
              [AS_HELP_STRING([--enable-webkit=@<:@yes/no/auto@:>@],
                              [Build with support for webkit.])],
              [enable_webkit=$enableval],
              [enable_webkit=auto])
AS_IF([test "$enable_webkit" != no],[
	PKG_CHECK_MODULES(WEBKIT,
	                  [webkit2gtk-web-extension-4.0 >= webkit_required_version],
	                  [have_webkit=yes],
	                  [have_webkit=no])

	AS_IF([test "$enable_webkit" = "yes" && "$have_webkit" = "no"],[
	       AC_MSG_ERROR([--enable-webkit requires webkit2gtk-4.0 >= webkit_required_version])
	])

	AC_SUBST([WEB_EXTENSIONS_DIR],[${libdir}/dactl-0.3/extensions])

	enable_webkit=$have_webkit
])
AM_CONDITIONAL(ENABLE_WEBKIT, [test "x$enable_webkit" = "xyes"])


dnl ***********************************************************************
dnl Check for supported plugins
dnl ***********************************************************************
m4_include([src/plugins/brabender/configure.ac])
m4_include([src/plugins/heidolph/configure.ac])
m4_include([src/plugins/licor/configure.ac])
m4_include([src/plugins/parker/configure.ac])
m4_include([src/plugins/velmex/configure.ac])
m4_include([src/plugins/samples/python/configure.ac])
m4_include([src/plugins/samples/vala/configure.ac])

AC_SUBST([DACTL_PLUGIN_LINKER_FLAGS],["-module -avoid-version -Wl,-z,defs"])
AC_SUBST([DACTL_PLUGIN_DIR],[${libdir}/dactl-0.3/plugins])

VALA_REQUIRED=0.22.0
dnl This should be called only after all DACTL_CHECK_VALA() and DACTL_ADD_PLUGIN() calls:
DACTL_CHECK_VALA([$VALA_REQUIRED],)
                 #[cld-0.3
                  #gio-2.0
                  #gee-0.8
                  #posix])


dnl ***********************************************************************
dnl Check for Required Python
dnl ***********************************************************************
enable_python_scripting=no
AS_IF([test "x$have_pygobject" = "xyes"],[
	AM_PATH_PYTHON([3.2.3])
	AC_PATH_TOOL(PYTHON3_CONFIG, "python3-config")
	AS_IF([test -z "${PYTHON3_CONFIG}"],[
		AC_MSG_RESULT([Failed to locate python3-config.])
	],[
		LIBDACTL_CORE_DEPS_CFLAGS="${LIBDACTL_CORE_DEPS_CFLAGS} `${PYTHON3_CONFIG} --includes`"
		LIBDACTL_CORE_DEPS_LIBS="${LIBDACTL_CORE_DEPS_LIBS} `${PYTHON3_CONFIG} --libs`"
		LIBDACTL_CORE_DEPS_LDFLAGS="${LIBDACTL_CORE_DEPS_LDFLAGS} `${PYTHON3_CONFIG} --ldflags`"
		enable_python_scripting=yes
	])

	pyoverridesdir="\$(pyexecdir)/gi/overrides"
	AC_SUBST(pyoverridesdir)
])


dnl ***********************************************************************
dnl Initialize Libtool
dnl ***********************************************************************
LT_PREREQ([2.2])
LT_INIT
LT_LIB_M


dnl ***********************************************************************
dnl Additional C Compiler Flags
dnl ***********************************************************************
AX_CHECK_COMPILE_FLAG([-Werror=unknown-warning-option], [
	ax_compiler_flags_test="-Werror=unknown-warning-option"
], [
	ax_compiler_flags_test=""
])
AX_APPEND_COMPILE_FLAGS([ \
	-Wall \
	-Wcast-align \
	-Wdeclaration-after-statement \
	-Werror=format-security \
	-Werror=format=2 \
	-Wextra \
	-Wmissing-include-dirs \
	-Wnested-externs \
	-Wno-missing-field-initializers \
	-Wno-sign-compare \
	-Wno-strict-aliasing \
	-Wno-uninitialized \
	-Wno-unused-parameter \
	-Wpointer-arith \
	-Wpointer-sign \
	-Wredundant-decls \
	-Wshadow \
	-Wswitch-default \
	-Wswitch-enum \
	-Wundef \
], [], [$ax_compiler_flags_test])
AC_C_CONST


dnl ***********************************************************************
dnl Support for gtk-doc Documentation Engine
dnl ***********************************************************************
AC_ARG_ENABLE(doc,
	AS_HELP_STRING([--enable-doc],
		[Enable documentation generation]), enable_doc=$enableval,
	enable_doc=no)
AM_CONDITIONAL(ENABLE_DOC, test x$enable_doc = xyes)

AS_IF([test "x$enable_doc" != xno],
	[AC_PATH_PROG(VALADOC, valadoc, :)
	 AC_SUBST(VALADOC)
	 AS_IF([test "$VALADOC" = :],
		[AC_MSG_ERROR([valadoc not found])])])


dnl ***********************************************************************
dnl Setup Various Compiler Optimizations
dnl ***********************************************************************
AC_MSG_CHECKING([whether to enable optimized builds])
AC_ARG_ENABLE(optimizations,
              AC_HELP_STRING([--enable-optimizations],
                             [turn on build-time optimizations [default=yes]]),
              [enable_optimizations=$enableval],
              [AS_IF([test "x$enable_debug" = "xyes"],
		     [enable_optimizations="no"],
		     [enable_optimizations="yes"])])
AC_MSG_RESULT([$enable_optimizations])
OPTIMIZE_CFLAGS=""
OPTIMIZE_LDFLAGS=""
# Enable -Bsymbolic
AS_IF([test "$enable_optimizations" != "no"],
      [AX_CHECK_LINK_FLAG([-Wl,-Bsymbolic],
                          [OPTIMIZE_LDFLAGS="$OPTIMIZE_LDFLAGS -Wl,-Bsymbolic"])
       AX_CHECK_LINK_FLAG([-fno-plt],
                          [OPTIMIZE_LDFLAGS="$OPTIMIZE_LDFLAGS -fno-plt"])])
AC_SUBST(OPTIMIZE_CFLAGS)
AC_SUBST(OPTIMIZE_LDFLAGS)


dnl ***********************************************************************
dnl Check if we should instrument our targets
dnl ***********************************************************************
AC_MSG_CHECKING([for --enable-profiling])
AC_ARG_ENABLE(profiling,
              AC_HELP_STRING([--enable-profiling],
                             [turn on runtime instrumentation [default=no]]),
              [enable_profiling=$enableval],
	      [enable_profiling=no])
AS_IF([test "$enable_profiling" = "yes"],[
	ac_save_cflags="$CFLAGS"
	CFLAGS="$CFLAGS -pg"
	AC_LINK_IFELSE([AC_LANG_SOURCE([[int main() { return 0; }]])],
	               [PROFILING_CFLAGS="-pg"],
		       [enable_profiling=no])
	CFLAGS="$ac_save_cflags $PROFILING_CFLAGS"
])
AC_MSG_RESULT([$enable_profiling])


dnl ***********************************************************************
dnl Setup common cflags and ldflags for plugins
dnl ***********************************************************************
PLUGIN_CFLAGS="$PLUGIN_CFLAGS -I\$(top_srcdir)/src/libdactl-core"
PLUGIN_CFLAGS="$PLUGIN_CFLAGS -I\$(top_srcdir)/src/libdactl-net"
PLUGIN_CFLAGS="$PLUGIN_CFLAGS -I\$(top_srcdir)/src/libdactl-ui"
PLUGIN_CFLAGS="$PLUGIN_CFLAGS $LIBDACTL_UI_DEPS_CFLAGS"
PLUGIN_CFLAGS="$PLUGIN_CFLAGS $LIBDACTL_CORE_DEPS_CFLAGS"
PLUGIN_CFLAGS="$PLUGIN_CFLAGS $DEBUG_CFLAGS"
PLUGIN_CFLAGS="$PLUGIN_CFLAGS $OPTIMIZE_CFLAGS"
AC_SUBST(PLUGIN_CFLAGS)

PLUGIN_LDFLAGS="$PLUGIN_LDFLAGS $OPTIMIZE_LDFLAGS"
PLUGIN_LDFLAGS="$PLUGIN_LDFLAGS -avoid-version"
PLUGIN_LDFLAGS="$PLUGIN_LDFLAGS -export-symbols-regex peas_register_types"
PLUGIN_LDFLAGS="$PLUGIN_LDFLAGS -module"
AC_SUBST(PLUGIN_LDFLAGS)

PLUGIN_VALAFLAGS="$PLUGIN_VALAFLAGS --target-glib=2.44"
PLUGIN_VALAFLAGS="$PLUGIN_VALAFLAGS --thread"
PLUGIN_VALAFLAGS="$PLUGIN_VALAFLAGS --vapidir \$(top_builddir)/src/libdactl-core"
PLUGIN_VALAFLAGS="$PLUGIN_VALAFLAGS --vapidir \$(top_builddir)/src/libdactl-net"
PLUGIN_VALAFLAGS="$PLUGIN_VALAFLAGS --vapidir \$(top_builddir)/src/libdactl-ui"
PLUGIN_VALAFLAGS="$PLUGIN_VALAFLAGS --pkg dactl-core-0.3"
PLUGIN_VALAFLAGS="$PLUGIN_VALAFLAGS --pkg dactl-ui-0.3"
PLUGIN_VALAFLAGS="$PLUGIN_VALAFLAGS --pkg libpeas-1.0"
AC_SUBST(PLUGIN_VALAFLAGS)


dnl ***********************************************************************
dnl Process .in Files
dnl ***********************************************************************
AC_CONFIG_FILES([
	Makefile

	build/Makefile
	build/autotools/Makefile

	contrib/Makefile

	data/Makefile
	data/config/Makefile
	data/glade/Makefile
	data/gsettings/Makefile
	data/icons/Makefile
	data/icons/16x16/Makefile
	data/icons/22x22/Makefile
	data/icons/24x24/Makefile
	data/icons/32x32/Makefile
	data/icons/48x48/Makefile
	data/icons/scalable/Makefile
	data/mime/Makefile
	data/org.coanda.Dactl.desktop.in

	data/gsettings/org.coanda.dactl.gschema.xml

	doc/Makefile

	po/Makefile.in

	src/Makefile
	src/dactl/Makefile
	src/dactl-daq/Makefile
	src/dactl-log/Makefile

	src/libdactl-core/Makefile
	src/libdactl-cli/Makefile
	src/libdactl-log/Makefile
	src/libdactl-net/Makefile
	src/libdactl-ui/Makefile
	src/libdactl-ui/extensions/Makefile

	src/plugins/Makefile
	src/plugins/samples/Makefile

	src/devices/Makefile
	src/devices/samples/Makefile

	examples/Makefile

	src/libdactl-core/dactl-core-0.3.pc
	src/libdactl-cli/dactl-cli-0.3.pc
	src/libdactl-log/dactl-log-0.3.pc
	src/libdactl-net/dactl-net-0.3.pc
	src/libdactl-ui/dactl-ui-0.3.pc
])
AC_OUTPUT


AC_MSG_NOTICE([

    ${PACKAGE} ${VERSION}

    Options

     Prefix: ...................................... : ${prefix}
     Libdir: ...................................... : ${libdir}
     Optimized Build .............................. : ${enable_optimizations}
     WebKit ....................................... : ${enable_webkit}

    Development Options

     DAQ support: ................................. : ${with_cld}
     UI support: .................................. : ${with_ui}
     Enable Debug: ................................ : ${enable_debug}
     Enable Tracing ............................... : ${enable_tracing}
     Enable Profiling (-pg) ....................... : ${enable_profiling}
     Build documentation .......................... : ${enable_doc}
     Build API reference .......................... : ${enable_doc}
     Update MIME Database ......................... : ${enable_mime}

    Plugins:

     Brabender: ................................... : ${enable_brabender_plugin}
     Heidolph: .................................... : ${enable_heidolph_plugin}
     Licor: ....................................... : ${enable_licor_plugin}
     Parker: ...................................... : ${enable_parker_plugin}
     Velmex: ...................................... : ${enable_velmex_plugin}

    Example Plugins:

     Example Python: .............................. : ${enable_python_plugin}
     Example Vala: ................................ : ${enable_vala_plugin}

    Languages support:

     Python 3 support: ............................ : ${enable_python_scripting}

    $PACKAGE will be installed in ${bindir}
])
