[GtkTemplate (ui = "/org/coanda/dactl/ui/general-settings.ui")]
public class Dactl.GeneralSettings : Gtk.Box {

    [GtkChild]
    private Gtk.Switch switch_dark_theme;

    [GtkChild]
    private Gtk.ComboBoxText comboboxtext_startup_page;

    [GtkChild]
    private Gtk.Switch switch_admin;

    [GtkChild]
    private Gtk.Entry entry_name;

    private Gtk.StackSwitcher switcher;

    private Dactl.UI.Application app;

    construct {
        app = Dactl.UI.Application.get_default ();
        var model = app.model as Dactl.UI.ApplicationModel;
        var pages = model.get_object_map (typeof (Dactl.Page));

        entry_name.set_text (model.name);
        comboboxtext_startup_page.remove_all ();
        foreach (var page in pages.values) {
            comboboxtext_startup_page.append (page.id, (page as Dactl.Page).title);
        }
        comboboxtext_startup_page.set_active_id (model.startup_page);

        switch_dark_theme.set_active (model.dark_theme);
        switch_dark_theme.notify["active"].connect ((s, p) => {
            GLib.message ("Activate dark theme: %s", switch_dark_theme.get_active ().to_string ());
        });

        switch_admin.set_active (model.admin);
        switch_admin.notify["active"].connect ((s, p) => {
            GLib.message ("Activate administrator mode: %s", switch_admin.get_active ().to_string ());
        });
    }

    public void update_preferences () {
        var model = app.model as Dactl.UI.ApplicationModel;
        model.dark_theme = switch_dark_theme.get_active ();
        model.admin = switch_admin.get_active ();
        model.name = entry_name.get_text ();
        model.startup_page = comboboxtext_startup_page.get_active_id ();
    }
}
