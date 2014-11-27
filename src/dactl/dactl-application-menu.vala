private class Dactl.ApplicationMenu : GLib.MenuModel {

    /* Singleton */
    private static Dactl.ApplicationMenu menu;

    public bool show_admin { get; set; default = false; }

    public static Dactl.ApplicationMenu get_default () {
        if (menu == null) {
            menu = new Dactl.ApplicationMenu ();
        }
        return menu;
    }

    internal ApplicationMenu () {
        /* Add some actions to the app menu */
        var file_menu = new GLib.Menu ();
        file_menu.append ("Save", "app.save");
        file_menu.append ("Export", "app.export");

        var view_menu = new GLib.Menu ();
        view_menu.append ("Data", "app.data");
        view_menu.append ("Configuration", "app.configuration");
        //view_menu.append ("Recent", "app.recent");
        //view_menu.append ("Digital I/O", "app.digio");

        //var settings_menu = new GLib.Menu ();
        //settings_menu.append ("Settings", "app.settings");

        (this as GLib.Menu).append_submenu ("File", file_menu);
        (this as GLib.Menu).append_submenu ("View", view_menu);

        //menu.append_section (null, settings_menu);
        (this as GLib.Menu).append ("Help", "app.help");
        (this as GLib.Menu).append ("About Dactl", "app.about");
        (this as GLib.Menu).append ("Quit", "app.quit");

        this.notify["show_admin"].connect (() => {
            if (show_admin) {
                message ("Adding a menu for admin functionality");
                var admin_menu = new GLib.Menu ();
                admin_menu.append ("Defaults", "app.defaults");
                (this as GLib.Menu).insert_submenu (2, "Admin", admin_menu);
            }
        });
    }
}
