[GtkTemplate (ui = "/org/coanda/dactl/ui/application-toolbar.ui")]
private class Dactl.ApplicationToolbar : Gtk.HeaderBar {

    [GtkChild]
    private Gtk.MenuButton btn_settings;

    construct {
        var app = Dactl.UI.Application.get_default ();
        var model = app.model;

        title = "Data Acquisition and Control";
        subtitle = model.config_filename;

        btn_settings.menu_model = (GLib.MenuModel) Dactl.load_ui ("application-menu.ui")
                                                        .get_object ("app-menu");

        btn_settings.use_popover = true;
        btn_settings.relief = Gtk.ReliefStyle.NONE;
        btn_settings.show ();
    }
}
