[GtkTemplate (ui = "/org/coanda/dactl/ui/settings-headerbar.ui")]
//private class Dactl.SettingsHeaderBar : Gtk.HeaderBar {
private class Dactl.SettingsHeaderBar : Gtk.Box {

    [GtkChild]
    private Gtk.Button btn_ok;

    public string subtitle = "(subtitle)";

    construct {
        /*
         *set_title ("Settings");
         *set_subtitle ("%s".printf (subtitle));
         */
        btn_ok.set_sensitive (true);
        btn_ok.clicked.connect (() => {
            message ("Ouch!");
        });
    }
}
