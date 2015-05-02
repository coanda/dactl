[GtkTemplate (ui = "/org/coanda/dactl/ui/settings-dialog.ui")]
public class Dactl.SettingsDialog : Gtk.Window {

    private Dactl.Settings stack_settings;

    [GtkChild]
    private Gtk.ListBox listbox_settings;

    [GtkChild]
    private Gtk.Box box1;

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

    private Cld.Context cld_ctx;

    private Dactl.SettingsData data;

    construct {
        cld_ctx = Dactl.UI.Application.get_default ().model.ctx;
        data = new Dactl.SettingsData.from_object (cld_ctx);
        stack_settings = new Dactl.Settings ();
        Gee.ArrayList<Dactl.SettingsData> list = new Gee.ArrayList<Dactl.SettingsData> ();
        //list.add (stack_settings.general.data);
        list.add (stack_settings.acquisition.data);
        list.add (stack_settings.control.data);
        list.add (stack_settings.log.data);
        //list.add (stack_settings.plugin.data);

        foreach (var page_data in list) {
            page_data.new_data.connect ((source, uri, spec, value) => {
                data.uri_selected = uri;
                data.set_value (spec, value);
            });
        }

        var header = new Dactl.SettingsHeaderBar ();
        box1.pack_start (header);
        box3.pack_end (stack_settings, true, true, 0);
        //listbox_settings.set_header_func (_update_header);

        /* XXX FIXME There are no separators visible in the ListBox */
        int n = 0;
        foreach (var row in listbox_settings.get_children ()) {
            var sep = new Gtk.Separator (Gtk.Orientation.VERTICAL);
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
            stack_settings.page = Dactl.SettingsStackPage.GENERAL;
        } else if (row == listboxrow_acquisition) {
            message ("ACQ");
            stack_settings.page = Dactl.SettingsStackPage.ACQUISITION;
        } else if (row == listboxrow_control) {
            message ("CONTROL");
            stack_settings.page = Dactl.SettingsStackPage.CONTROL;
        } else if (row == listboxrow_log) {
            message ("LOG");
            stack_settings.page = Dactl.SettingsStackPage.LOG;
        }else if (row == listboxrow_plugin) {
            message ("PLUGIN");
            stack_settings.page = Dactl.SettingsStackPage.PLUGIN;
        } else {
            message ("Unexpected row selection");
        }
    }

    [GtkCallback]
    private void btn_ok_clicked_cb () {
        /* Copy settings values to objects in the Cld context */
        foreach (var uri in data.keys) {
            var object = cld_ctx.get_object_from_uri (uri);
            if (object != null) {
                var svalues = data.get (uri);
                foreach (var spec in svalues.keys) {
                    var name = spec.get_name ();
                    var value = svalues.get (spec).value;
                    bool writable = (spec.flags & GLib.ParamFlags.WRITABLE) ==
                                                       GLib.ParamFlags.WRITABLE;
                    bool is_cld_object = value.type ().is_a (Type.from_name ("CldObject"));
                    if (writable && !is_cld_object) {
                        /*
                         *message (
                         *        "%s:%s  %s:%s",
                         *        uri,
                         *        object.get_type ().name (),
                         *        name,
                         *        value.type ().name ()
                         *        );
                         */
                        object.set_property (name, value);
                    } else if (!writable) {
                        /*
                         *message (
                         *        "%s:%s  %s:%s is not writable",
                         *        uri,
                         *        object.get_type ().name (),
                         *        name,
                         *        value.type ().name ()
                         *        );
                         */
                    } else if (writable && is_cld_object) {
                        object.set_object_property (name, (Cld.Object)value);
                    }
                }
            }
        }
        stack_settings.general.update_preferences ();

        destroy ();
    }

    [GtkCallback]
    private void btn_cancel_clicked_cb () {
        close ();
    }
}

