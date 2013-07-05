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

dnl Set install paths
if test "x$prefix" = "xNONE" ; then
	prefix="/usr/local"
fi

if test "x$exec_prefix" = "xNONE" ; then
	exec_prefix=$prefix
fi

if test "x$sysconfdir" = "xNONE" ; then
	sysconfdir="$prefix/etc"
fi

PREFIX=$prefix
AC_SUBST(PREFIX)

SYSCONFDIR="$prefix/etc"
AC_SUBST(SYSCONFDIR)

dnl Add setup for installation directories
AC_DEFINE_UNQUOTED(DATADIR, "$SYSCONFDIR/$PACKAGE", [
	Define the read-only architecture-independent data directory.
	])

dnl Library checks
VALA_PACKAGES=""

PKG_CHECK_MODULES([GLIB], [glib-2.0 >= 2.6 gthread-2.0 gmodule-2.0 gobject-2.0],,
	[AC_MSG_ERROR([glib-2.6 is required])])

PKG_CHECK_MODULES([GTK], [gtk+-3.0 clutter-1.0],
	[VALA_PACKAGES="$VALA_PACKAGES --pkg gtk+-3.0 --pkg clutter-1.0"],
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

dnl Package setup for Vala files
AC_SUBST(VALA_PACKAGES)

dnl Header checks
AC_HEADER_STDC
AC_CHECK_HEADERS(stdlib.h)
AC_CHECK_LIB(m, floor, PACKAGE_LIBS="$PACKAGE_LIBS -lm",)

dnl Build flags
if test x$GCC = xyes
then
	CRDC_CHECK_FLAG([-Wall])
	CRDC_CHECK_FLAG([-Wextra])
	CRDC_CHECK_FLAG([-Wno-deprecated-declarations])
	CRDC_CHECK_FLAG([-Wmissing-prototypes])
	CRDC_CHECK_FLAG([-Wshadow])
	CRDC_CHECK_FLAG([-Wpointer-arith])
	CRDC_CHECK_FLAG([-Wstrict-prototypes])
	CRDC_CHECK_FLAG([-Wcast-qual])
	CRDC_CHECK_FLAG([-Wwrite-strings])
	CRDC_CHECK_FLAG([-pedantic])
fi

dnl Comedi
AC_ARG_WITH(comedi,
[  --with-comedi         Use Comedi drivers],
	[use_comedi=$withval],
	[use_comedi=no])
AC_MSG_RESULT(checking whether Comedi drivers were selected... $use_comedi)

if test "x$use_comedi" != "xno" ; then
	PKG_CHECK_MODULES([COMEDI], [comedi],
		[VALA_PACKAGES="$VALA_PACKAGES --pkg comedi"],
		[AC_MSG_ERROR([Comedi is required])])
	AC_DEFINE(USE_COMEDI, [1], ["Comedi Drivers"])
fi

dnl Build Options
AC_ARG_ENABLE(debug,
	AS_HELP_STRING([--enable-debug],
		[enable debugging (default: disabled)]),,
	enable_debug=no)

dnl TODO fix this, there's better ways of setting build flags
if test "x$enable_debug" != "xno"; then
	AM_CFLAGS="$AM_CFLAGS -DDEBUG"
	if test x$GCC = xyes
	then
		CRDC_CHECK_FLAG([-g])
	fi
fi

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
echo "Prefix....................... : $prefix"
echo "System configuration......... : $sysconfdir"
echo "Data directory............... : $datadir"
echo "Package configuration........ : $pkgconfigdir"
echo
echo "----------------------------------------------------------------"
echo
echo "Debugging enabled............ : $enable_debug"
echo
echo "----------------------------------------------------------------"
echo
echo "Comedi support............... : $use_comedi"
echo "MCCUSB support............... : $use_mccusb"
echo "TS4700 support............... : $use_ts4700"
echo "TS4800 support............... : $use_ts4800"
echo
echo "----------------------------------------------------------------"
echo
eval eval echo $PACKAGE will be installed in $bindir
echo
echo configure complete, now type \'make\'
