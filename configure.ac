dnl Process this file with autoconf to produce a configure script.
AC_PREREQ([2.64])
AC_INIT([dactl], m4_esyscmd([build-aux/git-version-gen .tarball-version]))

AC_CONFIG_AUX_DIR([build-aux])
AC_CONFIG_SRCDIR([src/libdactl-core/dactl-object.vala])
AC_CONFIG_HEADERS([config.h])
AC_CONFIG_MACRO_DIR([m4])

AC_PROG_CC
AM_PROG_CC_STDC
AM_PROG_VALAC([0.22.0])
AC_PROG_INSTALL
AC_PROG_LN_S
AC_PROG_MAKE_SET
AC_HEADER_STDC

AC_SUBST(abs_top_builddir)
AC_SUBST(VERSION)

# Initialize automake
AM_INIT_AUTOMAKE([1.11.1 foreign no-dist-gzip dist-xz -Wno-portability])
AM_MAINTAINER_MODE([enable])

dnl Initialize libtool
dnl Disable the generation of static libraries
LT_PREREQ([2.2.6])
LT_INIT([dlopen disable-static])

GOBJECT_INTROSPECTION_REQUIRE([1.33.4])

dnl Enable silent rules is available
m4_ifdef([AM_SILENT_RULES], [AM_SILENT_RULES([yes])])

# GResource
AC_PATH_PROG(GLIB_COMPILE_RESOURCES, glib-compile-resources)

dnl Support GSettings
GLIB_GSETTINGS

AC_SUBST(VERSION)

AC_SET_DEFAULT_PATHS_SYSTEM

PREFIX=$prefix
AC_SUBST(PREFIX)

SYSCONFDIR="$ac_default_prefix/etc"
AC_SUBST(SYSCONFDIR)

dnl Add setup for installation directories
AC_DEFINE_UNQUOTED(DATADIR, "$SYSCONFDIR/$PACKAGE",
                   [Define the architecture-independent data directory.])

AC_DEFINE_UNQUOTED(UI_DIR, "$ac_default_prefix/share/$PACKAGE/ui",
                   [Define the read-only user interface files directory.])

dnl Library checks
VALAFLAGS="--enable-deprecated --target-glib=2.38 $VALAFLAGS"

dnl Need to work these in to simplify checking
DACTL_BASE_MODULES="gee-0.8 libxml-2.0"
DACTL_BASE_MODULES_VALAFLAGS="--pkg gee-0.8 --pkg libxml-2.0"

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

dnl Header checks
AC_CHECK_HEADERS(stdlib.h)
AC_CHECK_LIB(m, floor, PACKAGE_LIBS="$PACKAGE_LIBS -lm",)

dnl Check if building CLD support was requested
dnl XXX CLD is more of a requirement than an option at this point but the hope
dnl     is that dactl can be more generic and function with it as an engine
AC_ARG_WITH(cld,
    AS_HELP_STRING([--without-cld], [Do not build with CLD support]),
    [try_cld=$withval], [try_cld=yes])

HAVE_CLD=no
AS_IF([test "x$try_cld" = "xyes"],
      [PKG_CHECK_MODULES([DACTL_CLD_DEPS], [cld-0.2 comedi gsl sqlite3],
	    [
           DACTL_CHECK_PACKAGES([cld-0.2 comedi gsl sqlite3], [HAVE_CLD=yes])
           DACTL_CLD_DEPS_VALAFLAGS="--pkg cld-0.2 --pkg comedi --pkg gsl --pkg sqlite3"
	       DACTL_PLUGIN_COMMON_VALAFLAGS="$DACTL_PLUGIN_COMMON_VALAFLAGS $DACTL_CLD_DEPS_VALAFLAGS"
           AC_SUBST([DACTL_CLD_DEPS_VALAFLAGS])
        ],
        [
          AC_MSG_WARN([CLD dependencies not found.])
          AC_MSG_WARN([CLD support will not be built.])
        ])])

AM_CONDITIONAL(USE_CLD, test "x$HAVE_CLD" = "xyes")

dnl Check if building UI support was requested
dnl XXX considering dactl is a UI application this seems unnecessary, really
dnl     just carry over from an idea
AC_ARG_WITH(ui,
    AS_HELP_STRING([--without-ui], [Do not build in UI support]),
    [try_ui=$withval], [try_ui=yes])

HAVE_CLUTTER_GTK=no
AS_IF([test "x$try_ui" = "xyes"],
      [PKG_CHECK_MODULES([DACTL_UI_DEPS], [gtk+-3.0 clutter-1.0 clutter-gtk-1.0 librsvg-2.0],
	    [
           DACTL_UI_MODULES="gtk+-3.0 clutter-1.0 clutter-gtk-1.0 librsvg-2.0"
           DACTL_UI_DEPS_VALAFLAGS="--pkg gtk+-3.0 --pkg clutter-1.0 --pkg clutter-gtk-1.0 --pkg cogl-1.0 --pkg librsvg-2.0"
           AC_SUBST([DACTL_UI_DEPS_VALAFLAGS])
           DACTL_CHECK_PACKAGES([$DACTL_UI_MODULES], [HAVE_CLUTTER_GTK=yes])
	       DACTL_PLUGIN_COMMON_VALAFLAGS="$DACTL_PLUGIN_COMMON_VALAFLAGS $DACTL_UI_DEPS_VALAFLAGS"

           PKG_CHECK_MODULES([LIBDACTL_UI_DEPS], [$DACTL_BASE_MODULES $DACTL_UI_MODULES])
           LIBDACTL_UI_DEPS_VALAFLAGS="$DACTL_BASE_MODULES_VALAFLAGS $DACTL_UI_DEPS_VALAFLAGS"
           AS_IF([test "x$try_cld" = "xyes"], [LIBDACTL_UI_DEPS_VALAFLAGS="$LIBDACTL_UI_DEPS_VALAFLAGS $DACTL_CLD_DEPS_VALAFLAGS"])
           AC_SUBST([LIBDACTL_UI_DEPS_VALAFLAGS])
        ],
        [
          AC_MSG_WARN([UI dependencies not found.])
          AC_MSG_WARN([UI support will not be built.])
        ])])

AM_CONDITIONAL(BUILD_UI, test "x$HAVE_CLUTTER_GTK" = "xyes")

dnl Build plugin support
DACTL_ADD_PLUGIN([brabender],[CLD Brabender plugin],[yes])
AS_IF([test "x$enable_brabender_plugin" = "xyes"],
  [
    PKG_CHECK_MODULES([DACTL_PLUGIN_BRABENDER_DEPS],
                      [$DACTL_COMMON_MODULES cld-0.2])
  ])

DACTL_ADD_PLUGIN([heidolph],[CLD Heidolph plugin],[yes])
AS_IF([test "x$enable_heidolph_plugin" = "xyes"],
  [
    PKG_CHECK_MODULES([DACTL_PLUGIN_HEIDOLPH_DEPS],
                      [$DACTL_COMMON_MODULES cld-0.2])
  ])

DACTL_ADD_PLUGIN([licor],[CLD Licor plugin],[yes])
AS_IF([test "x$enable_licor_plugin" = "xyes"],
  [
    PKG_CHECK_MODULES([DACTL_PLUGIN_LICOR_DEPS],
                      [$DACTL_COMMON_MODULES cld-0.2])
  ])

DACTL_ADD_PLUGIN([parker],[CLD Parker plugin],[yes])
AS_IF([test "x$enable_parker_plugin" = "xyes"],
  [
    PKG_CHECK_MODULES([DACTL_PLUGIN_PARKER_DEPS],
                      [$DACTL_COMMON_MODULES cld-0.2])
  ])

DACTL_ADD_PLUGIN([velmex],[CLD Velmex plugin],[yes])
AS_IF([test "x$enable_velmex_plugin" = "xyes"],
  [
    PKG_CHECK_MODULES([DACTL_PLUGIN_VELMEX_DEPS],
                      [$DACTL_COMMON_MODULES cld-0.2])
  ])

dnl Build Options
AC_ARG_ENABLE(debug,
    AS_HELP_STRING([--enable-debug],[Enable debugging (default: disabled)]),,
        [enable_debug=no])
AS_IF([test "x$enable_debug" != "xno"],
      [AC_DEFINE(DEBUG, [1], ["Enable debugging support"])]
      [CFLAGS="$CFLAGS -O0 -g"]
      [DACTL_DEBUG_VALAFLAGS="-g -DDEBUG"]
      [AS_IF([test "x$GCC" = xyes],
             [CC_CHECK_FLAG([-g])])])

AC_SUBST(DACTL_DEBUG_VALAFLAGS)

dnl Build flags
AS_IF([test "x$GCC" != "xno"],
      [CC_CHECK_FLAG([-Wall])]
      [CC_CHECK_FLAG([-Wextra])]
      [CC_CHECK_FLAG([-Wno-deprecated-declarations])]
      [CC_CHECK_FLAG([-Wmissing-prototypes])]
      [CC_CHECK_FLAG([-Wshadow])]
      [CC_CHECK_FLAG([-Wpointer-arith])]
      [CC_CHECK_FLAG([-Wstrict-prototypes])]
      [CC_CHECK_FLAG([-Wcast-qual])]
      [CC_CHECK_FLAG([-Wwrite-strings])]
      [CC_CHECK_FLAG([-pedantic])])

dnl GOptions requires gettext for i18n
ALL_LINGUAS=""
GETTEXT_PACKAGE=dactl
AC_SUBST(GETTEXT_PACKAGE)
AC_DEFINE_UNQUOTED(GETTEXT_PACKAGE, "$GETTEXT_PACKAGE", [Gettext package.])

AM_GLIB_GNU_GETTEXT
IT_PROG_INTLTOOL([0.40.0])

AC_SUBST([DACTL_PLUGIN_LINKER_FLAGS],["-module -avoid-version -Wl,-z,defs"])
AC_SUBST([DACTL_PLUGIN_DIR],[${libdir}/dactl-0.3/plugins])

dnl Configuration
AC_SUBST([pkgconfigdir])

AC_CONFIG_FILES([
	Makefile
	data/dactl.desktop
	data/Makefile
    data/config/Makefile
	data/icons/Makefile
	data/icons/16x16/Makefile
	data/icons/22x22/Makefile
	data/icons/24x24/Makefile
	data/icons/32x32/Makefile
	data/icons/48x48/Makefile
	data/icons/scalable/Makefile
	data/mime/Makefile
	data/schemas/Makefile
	data/ui/Makefile
	po/Makefile.in
	src/Makefile
	src/dactl/Makefile
	src/libdactl-core/Makefile
	src/libdactl-ui/Makefile
	src/plugins/Makefile
	dactl-core-0.3.pc
])
AC_OUTPUT

dnl Generate build report
AC_MSG_NOTICE([

    $PACKAGE $VERSION
    ===========================

    Prefix:                         ${ac_default_prefix}
    Source code location:           ${srcdir}
    System configuration:           ${sysconfdir}
    Data directory:                 ${datadir}
    UI directory:                   ${ui_dir}
    Package directory:              ${pkgconfigdir}
    Compiler:                       ${CC}
    CFLAGS:                         ${CFLAGS}
    VALAFLAGS:                      ${VALAFLAGS}

    CLD support:                    $with_cld
    UI support:                     $with_ui
    Debugging enabled:              $enable_debug

    Plugins:

    Brabender:                      $enable_brabender_plugin
    Heidolph:                       $enable_heidolph_plugin
    Licor:                          $enable_licor_plugin
    Parker:                         $enable_parker_plugin
    Velmex:                         $enable_velmex_plugin

    $PACKAGE will be installed in $bindir
])
