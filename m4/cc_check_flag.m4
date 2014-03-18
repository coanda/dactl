AC_DEFUN([CC_CHECK_FLAG],[
    var=`echo "$1" | tr "=-" "__"`
    AC_CACHE_CHECK([whether the C compiler accepts $1],
        [cc_check_cflag_$var],[
            save_CFLAGS="$CFLAGS"
            CFLAGS="$CFLAGS $1"
            AC_COMPILE_IFELSE([AC_LANG_SOURCE([int main(void) { return 0; }])],
                [eval "cc_check_cflag_$var=yes"],
                [eval "cc_check_cflag_$var=no"])
            CFLAGS="$save_CFLAGS"
    ])

    check="x`echo '$cc_check_cflag_'$var`"
    AS_IF([test "$check" = "xyes"],[
        AM_CFLAGS="$AM_CFLAGS $1"
    ])
])
