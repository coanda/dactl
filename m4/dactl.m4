dnl dactl.m4
dnl
dnl Copyright 2014 Geoff Johnson
dnl
dnl Useful macros borrowed from rygel.

AC_DEFUN([DACTL_ADD_STAMP], [
    dactl_stamp_files="$dactl_stamp_files $srcdir/$1"
])

AC_DEFUN([DACTL_ADD_VALAFLAGS], [
    VALAFLAGS="${VALAFLAGS:+$VALAFLAGS }$1"
])

dnl DACTL_CHECK_PACKAGES(LIST-OF-PACKAGES,
dnl   ACTION-IF-FOUND)
dnl ---------------------------------------
dnl Version of VALA_CHECK_PACKAGES that will only run if vala support is
dnl enabled. Otherwise ACTION-IF-FOUND will be run.
AC_DEFUN([DACTL_CHECK_PACKAGES], [
    AS_IF([test "x$enable_vala" = "xyes"],
          [VALA_CHECK_PACKAGES([$1],[$2])],
          [$2])
])

dnl _DACTL_ADD_PLUGIN_INTERNAL(NAME-OF-PLUGIN,
dnl   NAME-OF-PLUGIN-WITH-UNDERSCORES,
dnl   NAME-OF-PLUGIN-FOR-HELP,
dnl   DEFAULT-FOR-ENABLE)
dnl --------------------------------------
dnl Add an --enable-plugin option, add its Makefile to AC_OUTPUT and set the
dnl conditional
AC_DEFUN([_DACTL_ADD_PLUGIN_INTERNAL], [
    AC_ARG_ENABLE([$1-plugin],
        AS_HELP_STRING([--enable-$1-plugin],[Enable the $3 plugin]),,
        enable_$2_plugin=$4)
    AC_CONFIG_FILES([src/plugins/$1/Makefile])
    AM_CONDITIONAL(m4_toupper(build_$2_plugin), test "x$[]enable_$2_plugin" = "xyes")
    DACTL_ADD_STAMP([src/plugins/$1/libdactl_$2_la_vala.stamp])
    AC_CONFIG_FILES([src/plugins/$1/$1.plugin])
])

dnl DACTL_ADD_PLUGIN(NAME-OF-PLUGIN,
dnl   NAME-OF-PLUGIN-FOR-HELP,
dnl   DEFAULT-FOR-ENABLE)
dnl --------------------------------------
dnl Hands off to internal m4.
AC_DEFUN([DACTL_ADD_PLUGIN], [
    _DACTL_ADD_PLUGIN_INTERNAL([$1],
        m4_translit([$1],[-],[_]),
        [$2],
        [$3])
])

dnl _DACTL_DISABLE_PLUGIN_INTERNAL(NAME-OF-PLUGIN)
dnl --------------------------------------
dnl Unset the conditional for building the plugin.
AC_DEFUN([_DACTL_DISABLE_PLUGIN_INTERNAL], [
    AM_CONDITIONAL(m4_toupper(build_$1_plugin), false)
    enable_$1_plugin="n/a"
])

dnl DACTL_DISABLE_PLUGIN(NAME-OF-PLUGIN)
dnl --------------------------------------
dnl Hands off to internal m4.
AC_DEFUN([DACTL_DISABLE_PLUGIN], [
    _DACTL_DISABLE_PLUGIN_INTERNAL(m4_translit([$1],[-],[_]))
])
