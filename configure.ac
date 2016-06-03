AC_PREREQ([2.69])


dnl ***********************************************************************
dnl Define Versioning Information
dnl ***********************************************************************
m4_define([dactl_major_version],[0])
m4_define([dactl_minor_version],[3])
m4_define([dactl_micro_version],[2])
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
LIBDACTL_UI_VERSION=dactl_version
AC_SUBST(MAJOR_VERSION)
AC_SUBST(MINOR_VERSION)
AC_SUBST(MICRO_VERSION)
AC_SUBST(LIBDACTL_CORE_VERSION)
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
GLIB_REQUIRED=2.38.0
LIBXML_REQUIRED=2.7
VALA_REQUIRED=0.22.0
VALADOC_REQUIRED=0.2
GEE_REQUIRED=0.8
GTK_REQUIRED=3.0

dnl Library checks
VALAFLAGS="--enable-deprecated --target-glib=2.38 $VALAFLAGS"

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

PKG_CHECK_MODULES([DACTL_UI_DEPS], [gtk+-3.0 librsvg-2.0 gtksourceview-3.0])
DACTL_UI_MODULES="gtk+-3.0 librsvg-2.0 gtksourceview-3.0"
DACTL_UI_DEPS_VALAFLAGS="--pkg gtk+-3.0 --pkg cogl-1.0 --pkg librsvg-2.0 --pkg gtksourceview-3.0"
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
	                  [webkit2gtk-4.0 >= webkit_required_version],
	                  [have_webkit=yes],
	                  [have_webkit=no])

	AS_IF([test "$enable_webkit" = "yes" && "$have_webkit" = "no"],[
	       AC_MSG_ERROR([--enable-webkit requires webkit2gtk-4.0 >= webkit_required_version])
	])

	enable_webkit=$have_webkit
])
AM_CONDITIONAL(ENABLE_WEBKIT, [test "x$enable_webkit" = "xyes"])


dnl ***********************************************************************
dnl Check for supported plugins
dnl ***********************************************************************
#DACTL_ADD_PLUGIN([brabender],[CLD Brabender plugin],[yes])
#AS_IF([test "x$enable_brabender_plugin" = "xyes"],
  #[
    #PKG_CHECK_MODULES([DACTL_PLUGIN_BRABENDER_DEPS],
                      #[$DACTL_COMMON_MODULES cld-0.3])
  #])

DACTL_ADD_PLUGIN([heidolph],[CLD Heidolph plugin],[yes])
AS_IF([test "x$enable_heidolph_plugin" = "xyes"],
  [
    PKG_CHECK_MODULES([DACTL_PLUGIN_HEIDOLPH_DEPS],
                      [$DACTL_COMMON_MODULES cld-0.3])
  ])

DACTL_ADD_PLUGIN([licor],[CLD Licor plugin],[yes])
AS_IF([test "x$enable_licor_plugin" = "xyes"],
  [
    PKG_CHECK_MODULES([DACTL_PLUGIN_LICOR_DEPS],
                      [$DACTL_COMMON_MODULES cld-0.3])
  ])

DACTL_ADD_PLUGIN([parker],[CLD Parker plugin],[yes])
AS_IF([test "x$enable_parker_plugin" = "xyes"],
  [
    PKG_CHECK_MODULES([DACTL_PLUGIN_PARKER_DEPS],
                      [$DACTL_COMMON_MODULES cld-0.3])
  ])

DACTL_ADD_PLUGIN([velmex],[CLD Velmex plugin],[yes])
AS_IF([test "x$enable_velmex_plugin" = "xyes"],
  [
    PKG_CHECK_MODULES([DACTL_PLUGIN_VELMEX_DEPS],
                      [$DACTL_COMMON_MODULES cld-0.3])
  ])

AC_SUBST([DACTL_PLUGIN_LINKER_FLAGS],["-module -avoid-version -Wl,-z,defs"])
AC_SUBST([DACTL_PLUGIN_DIR],[${libdir}/dactl-0.3/plugins])

m4_include([src/plugins/brabender/configure.ac])
m4_include([src/plugins/samples/vala/configure.ac])
m4_include([src/plugins/samples/python/configure.ac])

dnl This should be called only after all DACTL_CHECK_VALA() and DACTL_ADD_PLUGIN() calls:
DACTL_CHECK_VALA([$VALA_REQUIRED],)
                 #[cld-0.3
                  #gio-2.0
                  #gee-0.8
                  #posix])


dnl ***********************************************************************
dnl Lua support for plugins
dnl ***********************************************************************
LUA51_REQUIRED=5.1.0
LUAJIT_REQUIRED=2.0

LGI_MAJOR_VERSION=0
LGI_MINOR_VERSION=9
LGI_MICRO_VERSION=0
LGI_REQUIRED=$LGI_MAJOR_VERSION.$LGI_MINOR_VERSION.$LGI_MICRO_VERSION
AC_DEFINE_UNQUOTED(LGI_MAJOR_VERSION, [$LGI_MAJOR_VERSION], [LGI major version.])
AC_DEFINE_UNQUOTED(LGI_MINOR_VERSION, [$LGI_MINOR_VERSION], [LGI minor version.])
AC_DEFINE_UNQUOTED(LGI_MICRO_VERSION, [$LGI_MICRO_VERSION], [LGI micro version.])

dnl
dnl Test program for LGI version
dnl
m4_define([peas_lgi_version_test], [
#include <lauxlib.h>
#include <lualib.h>

#include "peas-lua-utils.c"

int main(int argc, char **argv)
{
  lua_State *L;
  gboolean success;

  L = luaL_newstate ();
  luaL_openlibs (L);

  success = (peas_lua_utils_require (L, "lgi") &&
             peas_lua_utils_check_version (L,
                                           LGI_MAJOR_VERSION,
                                           LGI_MINOR_VERSION,
                                           LGI_MICRO_VERSION));

  lua_close (L);
  return success ? 0 : 1;
}])

AC_ARG_ENABLE(lua5.1,
              AS_HELP_STRING([--enable-lua5.1],[Enable Lua 5.1 support]),
              [enable_lua51=$enableval],
              [enable_lua51=auto])

AC_ARG_ENABLE(luajit,
              AS_HELP_STRING([--enable-luajit],[Enable LuaJIT for Lua 5.1 support]),
              [enable_luajit=$enableval],
              [enable_luajit=auto])

AC_MSG_CHECKING([for Lua 5.1 availability.])

if test "x$enable_lua51" = "xno"; then
    found_lua51="no (disabled, use --enable-lua5.1 to enable)"
    AC_MSG_RESULT([$found_lua51])
else
    if test "x$enable_luajit" != "xno"; then
        PKG_CHECK_EXISTS([luajit >= $LUAJIT_REQUIRED], [
            found_lua51=yes
            with_lua51=luajit
        ], [
            found_lua51=no
        ])

        if test "x$enable_luajit" = "xyes" -a "x$found_lua51" = "xno"; then
            AC_MSG_ERROR([You need to have LuaJIT >= $LUAJIT_REQUIRED
                          installed to build Lua support for libpeas plugins])
        fi
    fi

    if test "x$found_lua51" != "xyes"; then
        PKG_CHECK_EXISTS([lua5.1 >= $LUA51_REQUIRED], [
            found_lua51=yes
            with_lua51=lua5.1
        ], [
            found_lua51=no
        ])

        if test "x$enable_lua51" = "xyes" -a "x$found_lua51" = "xno"; then
            AC_MSG_ERROR([You need to have Lua 5.1 >= $LUA51_REQUIRED
                          installed to build Lua support for libpeas plugins])
        fi
    fi

    if test "x$found_lua51" != "xyes"; then
        AC_MSG_RESULT([$found_lua51])
    else
        AC_MSG_RESULT([$found_lua51 ($with_lua51)])

        LUA51_CFLAGS=`$PKG_CONFIG --cflags $with_lua51`
        LUA51_LIBS=`$PKG_CONFIG --libs $with_lua51`
        AC_SUBST(LUA51_CFLAGS)
        AC_SUBST(LUA51_LIBS)

        AC_MSG_CHECKING(for LGI availability in Lua 5.1.)

        peas_save_CFLAGS="$CFLAGS"
        peas_save_LIBS="$LIBS"
        CFLAGS="$PEAS_CFLAGS $LUA51_CFLAGS -I${srcdir}/loaders/lua5.1"
        LIBS="$PEAS_LIBS $LUA51_LIBS"
        AC_TRY_RUN(peas_lgi_version_test(0),
                   found_lua51=yes,
                   found_lua51=no,
                   found_lua51=yes)
        CFLAGS="$peas_save_CFLAGS"
        LIBS="$peas_save_LIBS"

        if test "x$enable_lua51" = "xyes" -a "x$found_lua51" = "xno"; then
            AC_MSG_ERROR([You need to have LGI >= $LGI_REQUIRED
                          installed to build Lua support for libpeas plugins])
        fi

        if test "x$found_lua51" = "xyes"; then
            AC_DEFINE(ENABLE_LUA51, 1, [Define to compile with Lua support])
        fi

        AC_MSG_RESULT([$found_lua51])
    fi
fi

AM_CONDITIONAL([ENABLE_LUA51], [test "x$found_lua51" = "xyes"])

dnl ***********************************************************************
dnl Python support for plugins
dnl ***********************************************************************
#PYTHON3_REQUIRED=3.2.0

#dnl Used by the Python loader to check the PyGObject version at runtime
#PYGOBJECT_MAJOR_VERSION=3
#PYGOBJECT_MINOR_VERSION=0
#PYGOBJECT_MICRO_VERSION=0
#PYGOBJECT_REQUIRED=$PYGOBJECT_MAJOR_VERSION.$PYGOBJECT_MINOR_VERSION.$PYGOBJECT_MICRO_VERSION
#AC_DEFINE_UNQUOTED(PYGOBJECT_MAJOR_VERSION,[$PYGOBJECT_MAJOR_VERSION], [PyGObject major version.])
#AC_DEFINE_UNQUOTED(PYGOBJECT_MINOR_VERSION,[$PYGOBJECT_MINOR_VERSION], [PyGObject minor version.])
#AC_DEFINE_UNQUOTED(PYGOBJECT_MICRO_VERSION,[$PYGOBJECT_MICRO_VERSION], [PyGObject micro version.])

#AC_MSG_CHECKING([for Python 3 availability.])

#AC_ARG_ENABLE(python3,
    #AS_HELP_STRING([--enable-python3],[Enable Python 3 support]),
    #[enable_python3=$enableval],
    #[enable_python3=auto])

#if test "x$enable_python3" = "xno"; then
    #found_python3="no (disabled, use --enable-python3 to enable)"
#else
    #AM_PATH_PYTHON($PYTHON3_REQUIRED, [
        #AC_PATH_TOOL(PYTHON3_CONFIG, "python3-config")
        #if test -n "${PYTHON3_CONFIG}"; then
            #PKG_CHECK_MODULES(PYGOBJECT, pygobject-3.0 >= $PYGOBJECT_REQUIRED, [
                #found_python3=yes
                #PYTHON3_CFLAGS=`${PYTHON3_CONFIG} --includes`
                #PYTHON3_LIBS=`${PYTHON3_CONFIG} --libs`
                #PYTHON3_LDFLAGS=`${PYTHON3_CONFIG} --ldflags`
                #PYTHON3_PYEXECDIR="${pyexecdir}"
                #AC_SUBST(PYTHON3_CFLAGS)
                #AC_SUBST(PYTHON3_LIBS)
                #AC_SUBST(PYTHON3_LDFLAGS)
                #AC_SUBST(PYTHON3_PYEXECDIR)
                #AC_DEFINE(ENABLE_PYTHON3, 1, [Define to compile with Python 3 support])
            #], [
                #found_python3="no (PyGObject not found)"
            #])
        #else
            #found_python3="no (python3-config not found)"
        #fi
    #], [
        #found_python3="no (python3 not found)"
    #])
#fi

#if test "x$enable_python3" = "xyes" -a "x$found_python3" != "xyes"; then
    #AC_MSG_ERROR([You need to have Python 3 and PyGObject installed to build Python3 support for libpeas plugins])
#fi
#AC_MSG_RESULT([$found_python3])

#AM_CONDITIONAL([ENABLE_PYTHON3],[test "x$found_python3" = "xyes"])


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

	data/Makefile
	data/config/Makefile
	data/glade/Makefile
	data/icons/Makefile
	data/icons/16x16/Makefile
	data/icons/22x22/Makefile
	data/icons/24x24/Makefile
	data/icons/32x32/Makefile
	data/icons/48x48/Makefile
	data/icons/scalable/Makefile
	data/mime/Makefile
	data/schemas/Makefile
	data/org.coanda.Dactl.desktop.in

	deps/Makefile

	doc/Makefile

	po/Makefile.in

	src/Makefile
	src/dactl/Makefile
	src/libdactl-core/Makefile
	src/libdactl-ui/Makefile
	src/plugins/Makefile
	src/plugins/samples/Makefile

	examples/Makefile

	dactl-core-0.3.pc
	dactl-ui-0.3.pc
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

     CLD support: ................................. : ${with_cld}
     UI support: .................................. : ${with_ui}
     Enable Debug: ................................ : ${enable_debug}
     Enable Tracing ............................... : ${enable_tracing}
     Enable Profiling (-pg)........................ : ${enable_profiling}
     Build API reference .......................... : ${enable_doc}

    Plugins:

     Brabender: ................................... : ${enable_brabender_plugin}
     Heidolph: .................................... : ${enable_heidolph_plugin}
     Licor: ....................................... : ${enable_licor_plugin}
     Parker: ...................................... : ${enable_parker_plugin}
     Velmex: ...................................... : ${enable_velmex_plugin}

    Example Plugins:

     Example Vala: ................................ : ${enable_vala_plugin}
     Example Python: .............................. : ${enable_python_plugin}

    Languages support:

     Lua 5.1 support: ............................. : ${found_lua51}
     Python 3 support: ............................ : ${enable_python_scripting}

    $PACKAGE will be installed in $bindir
])
