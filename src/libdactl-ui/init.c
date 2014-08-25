#include <unistd.h>
#include <stdlib.h>
#include <string.h>

#include <glib.h>
#include <clutter-gtk/clutter-gtk.h>

static void __attribute__ ((constructor)) \
    lib_init (void);

static void lib_init (void) {
    gchar **args1 = NULL;
    gchar **args2 = NULL;
    gint args2_length = 0;

    args1 = g_new0 (gchar*, 0 + 1);
    args2 = args1;

    gtk_clutter_init (&args2_length, &args2);

    g_free (args1);

    return;
}
