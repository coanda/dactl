[GtkTemplate (ui = "/org/coanda/dactl/ui/settings-dialog.ui")]
public class Dactl.SettingsDialog : Gtk.Window {

    private Dactl.Settings stack_settings;

    [GtkChild]
    private Gtk.ListBox listbox_settings;

    [GtkChild]
    private Gtk.Box box3;

    [GtkChild]
    private Gtk.ListBoxRow listboxrow_general;

    [GtkChild]
    private Gtk.ListBoxRow listboxrow_acquisition;

    [GtkChild]
    private Gtk.ListBoxRow listboxrow_control;

    [GtkChild]
    private Gtk.ListBoxRow listboxrow_log;

    [GtkChild]
    private Gtk.ListBoxRow listboxrow_plugin;

    construct {
        stack_settings = new Dactl.Settings ();
        box3.pack_end (stack_settings, true, true, 0);
        //listbox_settings.set_header_func (_update_header);

        /* XXX FIXME There are no separators visible in the ListBox */
        int n = 0;
        foreach (var row in listbox_settings.get_children ()) {
            var sep = new Gtk.Separator (Gtk.Orientation.HORIZONTAL);
            //row.set_header (separator);
            sep.set_visible (true);
            var color = new Gdk.RGBA ();
            color.red = 255;
            color.green = 255;
            color.blue = 255;
            color.alpha = 1.0;
            sep.override_color (Gtk.StateFlags.NORMAL, color);
            listbox_settings.insert (sep, 2 * n + 1);
            n++;
        }

        /*
         *headerbar_right = new Dactl.SettingsHeaderBarRight ();
         *grid.attach (headerbar_right, 0, 0, 1, 1);
         */
        /*
         *headerbar_left = new Dactl.SettingsHeaderBarLeft ();
         *grid.attach (headerbar_left, 0, 1, 1, 1);
         */
    }

    [GtkCallback]
    private void listbox_settings_row_activated_cb (Gtk.ListBoxRow row) {
        if (row == listboxrow_general) {
            message ("GENERAL");
            stack_settings.page = Dactl.SettingsPage.GENERAL;
        } else if (row == listboxrow_acquisition) {
            message ("ACQ");
            stack_settings.page = Dactl.SettingsPage.ACQUISITION;
        } else if (row == listboxrow_control) {
            message ("CONTROL");
            stack_settings.page = Dactl.SettingsPage.CONTROL;
        } else if (row == listboxrow_log) {
            message ("LOG");
            stack_settings.page = Dactl.SettingsPage.LOG;
        }else if (row == listboxrow_plugin) {
            message ("PLUGIN");
            stack_settings.page = Dactl.SettingsPage.PLUGIN;
        } else {
            message ("Unexpected row selection");
        }
    }

    [GtkCallback]
    private void btn_ok_clicked_cb () {
        stack_settings.update_preferences ();
        close ();
    }

    [GtkCallback]
    private void btn_cancel_clicked_cb () {
        close ();
    }
}

