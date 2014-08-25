[GtkTemplate (ui = "/org/coanda/dactl/ui/application-toolbar.ui")]
private class Dactl.ApplicationToolbar : Gtk.HeaderBar {

    /*
     *[GtkChild]
     *private Gtk.Button btn_log;
     */

    [GtkChild]
    private Gtk.Button btn_settings;

    [GtkChild]
    private Gtk.Button btn_previous;

    [GtkChild]
    private Gtk.Button btn_next;

    /*
     *[GtkChild]
     *private Gtk.Image img_log;
     */

    [GtkChild]
    private Gtk.Image img_settings;

    [GtkChild]
    private Gtk.Image img_previous;

    [GtkChild]
    private Gtk.Image img_next;

    construct {
        title = "Dactl";
    }

    /*
     *public void set_log_state (bool state) {
     *    if (state) {
     *        img_log.icon_name = "media-playback-stop-symbolic";
     *    } else {
     *        img_log.icon_name = "media-record-symbolic";
     *    }
     *}
     */
}
