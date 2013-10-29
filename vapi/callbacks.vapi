[CCode (cprefix = "Callbacks", lower_case_cprefix = "cb_", cheader_filename = "callbacks.h")]
namespace Callbacks {
    [Compact]
    [CCode (cname = "btn_quit_clicked")]
    public bool btn_quit_clicked (Gtk.Widget widget, GLib.Object? data = null);

//    [CCode (cname = "btn_pref_clicked")]
//    public bool btn_pref_clicked (Gtk.Widget widget, GLib.Object? data = null);

    [CCode (cname = "btn_save_clicked")]
    public bool btn_save_clicked (Gtk.Widget widget, GLib.Object? data = null);

    [CCode (cname = "btn_log_toggled")]
    public bool btn_log_toggled (Gtk.Widget widget, GLib.Object? data = null);

    [CCode (cname = "btn_def_toggled")]
    public bool btn_def_toggled (Gtk.Widget widget, GLib.Object? data = null);
}
