#ifndef __COMMON_H__
#define __COMMON_H__

#ifdef __cplusplus
#  define BEGIN_C_DECLS extern "C" {
#  define END_C_DECLS   }
#else /* !__cplusplus */
#  define BEGIN_C_DECLS
#  define END_C_DECLS
#endif /* __cplusplus */

#ifdef HAVE_CONFIG_H
#  include <config.h>
#endif

#include <asm/types.h>
#include <sys/types.h>
#include <sys/mman.h>
#include <sys/stat.h>
#include <sys/stat.h>
#include <sys/un.h>
#include <sys/time.h>

#ifdef STDC_HEADERS
#  include <stdio.h>
#  include <stdlib.h>
#  include <stdarg.h>
#  include <stdbool.h>
#  include <string.h>
#endif

#ifdef HAVE_UNISTD_H
#  include <unistd.h>
#endif

#include <signal.h>
#include <assert.h>
#include <errno.h>
#include <fcntl.h>
#include <time.h>
#include <glib.h>
#include <glib-object.h>
#include <gtk/gtk.h>
//#include <gsl/gsl.h>

#ifdef USE_COMEDI
#  include <comedilib.h>
#endif

#include <cld-0.2/cld.h>

#ifndef EXIT_SUCCESS
#  define EXIT_SUCCESS  0
#  define EXIT_FAILURE  1
#endif

#endif
