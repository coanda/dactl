AC_DEFUN([CRDC_AUTO_ENABLED], [
	var="enable_$1"
	feature="$2"

	if eval "test x`echo '$'$var` = xauto"; then
		AC_MSG_NOTICE([auto-detected $feature])
		eval "$var=yes"
	fi
])

AC_DEFUN([CRDC_AUTO_DISABLED], [
	var="enable_$1"
	feature="$2"
	msg="$3"

	if eval "test x`echo '$'$var` = xauto"; then
		AC_MSG_WARN([$msg -- disabling $feature])
		eval "$var=no"
	elif eval "test x`echo '$'$var` = xyes"; then
		AC_MSG_ERROR([$feature: $msg])
	fi
])

dnl Check whether a prerequisite for a feature was found.  This is
dnl very similar to CRDC_AUTO_RESULT, but does not finalize the
dnl detection; it assumes that more checks will follow.
AC_DEFUN([CRDC_AUTO_PRE], [
	name="$1"
	var="enable_$1"
	found="found_$name"
	feature="$2"
	msg="$3"

	if eval "test x`echo '$'$var` != xno" && eval "test x`echo '$'$found` = xno"; then
                CRDC_AUTO_DISABLED([$name], [$feature], [$msg])
	fi
])

AC_DEFUN([CRDC_AUTO_RESULT], [
	name="$1"
	var="enable_$1"
	found="found_$name"
	feature="$2"
	msg="$3"

	if eval "test x`echo '$'$var` = xno"; then
		eval "$found=no"
	fi

	if eval "test x`echo '$'$found` = xyes"; then
                CRDC_AUTO_ENABLED([$name], [$feature])
	else
                CRDC_AUTO_DISABLED([$name], [$feature], [$msg])
	fi
])

AC_DEFUN([CRDC_AUTO_PKG], [
	if eval "test x`echo '$'enable_$1` != xno"; then
		PKG_CHECK_MODULES([$2], [$3],
			[eval "found_$1=yes"],
			[eval "found_$1=no"])
	fi

	CRDC_AUTO_RESULT([$1], [$4], [$5])
])
