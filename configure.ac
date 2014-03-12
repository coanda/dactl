dnl Process this file with autoconf to produce a configure script.
AC_INIT([dactl], [0.3])
AC_CONFIG_MACRO_DIR([m4])
AC_CONFIG_SRCDIR([src/main.vala])

AM_INIT_AUTOMAKE([foreign no-dist-gzip dist-xz])
AC_CONFIG_HEADERS([config.h])
AM_MAINTAINER_MODE

dnl Enable silent rules is available
m4_ifdef([AM_SILENT_RULES], [AM_SILENT_RULES([yes])])

dnl Support GSettings
GLIB_GSETTINGS

AC_DEFINE(VERSION, "0.3", "dactl")

dnl Programs
AC_PROG_CC
AM_PROG_CC_STDC
AM_PROG_VALAC([0.12.0])
AC_PROG_INSTALL
AC_PROG_LN_S
AC_PROG_MAKE_SET

dnl Declare Variables
AC_SUBST(PACKAGE_CFLAGS)
AC_SUBST(PACKAGE_LIBS)
PACKAGE_CFLAGS=""
PACKAGE_LIBS=""

AC_SET_DEFAULT_PATHS_SYSTEM

PREFIX=$prefix
AC_SUBST(PREFIX)

SYSCONFDIR="$ac_default_prefix/etc"
AC_SUBST(SYSCONFDIR)

dnl Add setup for installation directories
AC_DEFINE_UNQUOTED(DATADIR, "$SYSCONFDIR/$PACKAGE",
                   [Define the architecture-independent data directory.])

#UI_DIR="$ac_default_prefix/share/$PACKAGE/ui"
#AC_SUBST(UI_DIR)
AC_DEFINE_UNQUOTED(UI_DIR, "$ac_default_prefix/share/$PACKAGE/ui",
                   [Define the read-only user interface files directory.])

dnl Library checks
VALA_PACKAGES=""

PKG_CHECK_MODULES([GLIB], [glib-2.0 gthread-2.0 gmodule-2.0 gobject-2.0],,
	[AC_MSG_ERROR([glib2 is required])])

PKG_CHECK_MODULES([GTK], [gtk+-3.0],
	[VALA_PACKAGES="$VALA_PACKAGES --pkg gtk+-3.0"],
	[AC_MSG_ERROR([gtk3 is required])])

PKG_CHECK_MODULES([GEE], [gee-1.0],
	[VALA_PACKAGES="$VALA_PACKAGES --pkg gee-1.0"],
	[AC_MSG_ERROR([gee is required])])

PKG_CHECK_MODULES([GSL], [gsl],
	[VALA_PACKAGES="$VALA_PACKAGES --pkg gsl"],
	[AC_MSG_ERROR([gsl is required])])

PKG_CHECK_MODULES([XML], [libxml-2.0],
	[VALA_PACKAGES="$VALA_PACKAGES --pkg libxml-2.0"],
	[AC_MSG_ERROR([libxml-2.0 is required])])

PKG_CHECK_MODULES([CLD], [cld-0.2],
	[VALA_PACKAGES="$VALA_PACKAGES --pkg cld-0.2"],
	[AC_MSG_ERROR([cld-0.2 is required])])

PKG_CHECK_MODULES([SQLITE], sqlite3,
    [VALA_PACKAGES="$VALA_PACKAGES --pkg sqlite3"],
	[AC_MSG_ERROR(sqlite3 is required)])

dnl Package setup for Vala files
AC_SUBST(VALA_PACKAGES)

dnl Header checks
AC_HEADER_STDC
AC_CHECK_HEADERS(stdlib.h)
AC_CHECK_LIB(m, floor, PACKAGE_LIBS="$PACKAGE_LIBS -lm",)

dnl Comedi
AC_ARG_ENABLE(comedi, AS_HELP_STRING([--enable-comedi],
                                     [Use Comedi drivers]),
                [enable_comedi=yes], [enable_comedi=no])
AS_IF([test "x$enable_comedi" != "xno"],
      [AC_DEFINE(USE_COMEDI, [1], ["Comedi drivers"])]
      [PKG_CHECK_MODULES([COMEDI], [comedi],
	                     [VALA_PACKAGES="$VALA_PACKAGES --pkg comedi"],
                         [AC_MSG_ERROR([Comedi is required])])])

dnl Build Options
AC_ARG_ENABLE(debug, AS_HELP_STRING([--enable-debug],
                                    [Enable debugging (default: disabled)]),,
                [enable_debug=no])
AS_IF([test "x$enable_debug" != "xno"],
      [AC_DEFINE(DEBUG, [1], ["Enable debugging support"])]
         [AM_CFLAGS="$AM_CFLAGS -DDEBUG"]
         [AS_IF([test "x$GCC" = "xyes"],
             [CC_CHECK_FLAG([-g])])])

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
	src/Makefile
	vapi/Makefile
])
AC_OUTPUT

dnl Generate build report
echo
echo "$PACKAGE ($VERSION)"
echo
echo "----------------------------------------------------------------"
echo
echo "Prefix....................... : $ac_default_prefix"
echo "System configuration......... : $sysconfdir"
echo "Data directory............... : $datadir"
echo "UI directory................. : $ui_dir"
echo "Package directory............ : $pkgconfigdir"
echo
echo "----------------------------------------------------------------"
echo
echo "Comedi support............... : $enable_comedi"
echo "Debugging enabled............ : $enable_debug"
echo
echo "----------------------------------------------------------------"
echo
echo "// placeholder for --with-plugin"
echo
echo "----------------------------------------------------------------"
echo
eval eval echo $PACKAGE will be installed in $bindir
echo
echo configure complete, now type \'make\'
