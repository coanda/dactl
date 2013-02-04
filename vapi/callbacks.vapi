[CCode (cprefix = "Callbacks", lower_case_cprefix = "cb_", cheader_filename = "callbacks.h")]
namespace Callbacks {
    [Compact]
    [CCode (cname = "mnu_item_help_about_activate")]
    public bool mnu_item_help_about_activate (Gtk.Widget widget,
                                             GLib.Object? data = null);

    [CCode (cname = "mnu_item_edit_pref_activate")]
    public bool mnu_item_edit_pref_activate (Gtk.Widget widget,
                                             GLib.Object? data = null);

    [CCode (cname = "mnu_item_edit_chan_activate")]
    public bool mnu_item_edit_chan_activate (Gtk.Widget widget,
                                             GLib.Object? data = null);

    [CCode (cname = "mnu_item_file_quit_activate")]
    public bool mnu_item_file_quit_activate (Gtk.Widget widget,
                                             GLib.Object? data = null);

    [CCode (cname = "btn_quit_clicked")]
    public bool btn_quit_clicked (Gtk.Widget widget, GLib.Object? data = null);

    [CCode (cname = "btn_pref_clicked")]
    public bool btn_pref_clicked (Gtk.Widget widget, GLib.Object? data = null);

    [CCode (cname = "btn_save_clicked")]
    public bool btn_save_clicked (Gtk.Widget widget, GLib.Object? data = null);

    [CCode (cname = "btn_log_toggled")]
    public bool btn_log_toggled (Gtk.Widget widget, GLib.Object? data = null);

    [CCode (cname = "btn_def_toggled")]
    public bool btn_def_toggled (Gtk.Widget widget, GLib.Object? data = null);
}
