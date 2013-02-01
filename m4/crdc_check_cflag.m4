AC_DEFUN([CRDC_CHECK_FLAG],[
  var=`echo "$1" | tr "=-" "__"`
  AC_CACHE_CHECK([whether the C compiler accepts $1],
    [crdc_check_cflag_$var],[
    save_CFLAGS="$CFLAGS"
    CFLAGS="$CFLAGS $1"
    AC_COMPILE_IFELSE([
     int main(void) { return 0; }
     ], [ eval "crdc_check_cflag_$var=yes"
     ], [ eval "crdc_check_cflag_$var=no" ])
    CFLAGS="$save_CFLAGS"
  ])
  if eval "test x`echo '$crdc_check_cflag_'$var` = xyes"
  then
    AM_CFLAGS="$AM_CFLAGS $1"
  fi
  ])
])
