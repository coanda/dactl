[GtkTemplate (ui = "/org/coanda/dactl/ui/loader-toolbar.ui")]
private class Dactl.LoaderToolbar : Gtk.HeaderBar {

    [GtkChild]
    private Gtk.Button back_button;

    [GtkChild]
    private Gtk.Image back_image;

    construct {
        title = "File Loader";

        back_image.icon_name = "go-previous-symbolic";
    }
}
