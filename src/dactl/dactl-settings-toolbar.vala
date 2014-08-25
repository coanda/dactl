[GtkTemplate (ui = "/org/coanda/dactl/ui/settings-toolbar.ui")]
private class Dactl.SettingsToolbar : Gtk.HeaderBar {

    [GtkChild]
    private Gtk.Button back_button;

    [GtkChild]
    private Gtk.Image back_image;

    construct {
        title = "Settings";

        back_image.icon_name = "go-previous-symbolic";
    }
}
