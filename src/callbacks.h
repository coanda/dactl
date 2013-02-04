#ifndef __CALLBACKS_H__
#define __CALLBACKS_H__

#include "common.h"

BEGIN_C_DECLS

/* menubar */
gboolean cb_mnu_item_help_about_activate (GtkWidget *widget, gpointer data);
gboolean cb_mnu_item_edit_pref_activate (GtkWidget *widget, gpointer data);
gboolean cb_mnu_item_edit_chan_activate (GtkWidget *widget, gpointer data);
gboolean cb_mnu_item_file_quit_activate (GtkWidget *widget, gpointer data);

/* toolbar */
gboolean cb_btn_quit_clicked (GtkWidget *widget, gpointer data);
gboolean cb_btn_pref_clicked (GtkWidget *widget, gpointer data);
gboolean cb_btn_save_clicked (GtkWidget *widget, gpointer data);
gboolean cb_btn_chan_clicked (GtkWidget *widget, gpointer data);
//gboolean cb_btn_log_toggled (GtkWidget *widget, gpointer data);
gboolean cb_btn_def_toggled (GtkWidget *widget, gpointer data);

END_C_DECLS

#endif /* !__CALLBACKS_H__ */
