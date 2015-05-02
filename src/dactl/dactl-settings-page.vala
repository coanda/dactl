[GtkTemplate (ui = "/org/coanda/dactl/ui/settings-page.ui")]
public class Dactl.SettingsPage : Gtk.Box {
    protected Dactl.SettingsTreeView treeview;
    protected Dactl.SettingsListBox listbox;
    protected Cld.Context cld_ctx;
    public Dactl.SettingsData data;

    [GtkChild]
    protected Gtk.Box box_treeview;

    [GtkChild]
    protected Gtk.Box box_listbox;

    construct {
        cld_ctx = Dactl.UI.Application.get_default ().model.ctx;
        treeview = new Dactl.SettingsTreeView ();
        box_treeview.pack_start (treeview);

        listbox = new Dactl.SettingsListBox ();
        box_listbox.pack_start (listbox);

        treeview.select.connect ((uri) => {
            listbox.populate (data.get (uri));
            data.uri_selected = uri;
        });

        listbox.request_choices.connect ((source, box, type) => {
            if (type.is_a (typeof (Cld.Object))) {
                var map = cld_ctx.get_object_map_from_uri (type);
                box.set_cld_object_choices (map);
            }
        });

        listbox.new_data.connect ((source, spec, value) => {
            data.set_value (spec, value);
        });
    }
}

public class Dactl.AcquisitionSettings : Dactl.SettingsPage {

    construct {
        Cld.AcquisitionController acq = null;

        var acquisition_controllers = cld_ctx.
                   get_object_map_from_uri (typeof (Cld.AcquisitionController));
        /* Choose the last one. There should only be one */
        foreach (var ctrl in acquisition_controllers.values)
            acq = ctrl as Cld.AcquisitionController;

        treeview.generate (acq, 0);
        data = new Dactl.SettingsData.from_object (acq);

        /* Add the data series to this page */
        var ds_map = cld_ctx.get_object_map_from_uri (typeof (Cld.DataSeries));
        foreach (var ds in ds_map.values) {
            treeview.generate (ds, 0);
            data.copy_settings (ds);
        }

        var math_map = cld_ctx.get_object_map_from_uri (typeof (Cld.MathChannel));
        foreach (var mc in math_map.values) {
            treeview.generate (mc, 0);
            data.copy_settings (mc);
        }

        show_all ();
    }
}

public class Dactl.LogSettings : Dactl.SettingsPage {

    construct {
        Cld.LogController log_ctrl = null;
        var log_controllers = cld_ctx.
                   get_object_map_from_uri (typeof (Cld.LogController));
        /* Choose the last one. There should only be one */
        foreach (var ctrl in log_controllers.values)
            log_ctrl = ctrl as Cld.LogController;

        treeview.generate (log_ctrl, 0);
        data = new Dactl.SettingsData.from_object (log_ctrl);

        show_all ();
    }
}

public class Dactl.ControlSettings : Dactl.SettingsPage {

    construct {
        Cld.AutomationController auto_ctrl = null;
        var automation_controllers = cld_ctx.
                   get_object_map_from_uri (typeof (Cld.AutomationController));
        /* Choose the last one. There should only be one */
        foreach (var ctrl in automation_controllers.values)
            auto_ctrl = ctrl as Cld.AutomationController;

        treeview.generate (auto_ctrl, 0);
        data = new Dactl.SettingsData.from_object (auto_ctrl);

        show_all ();
    }
}

public class Dactl.PluginSettings : Dactl.SettingsPage {

    construct {
        var module_map = cld_ctx.get_object_map_from_uri (typeof (Cld.Module));
        foreach (var module in module_map.values) {
            treeview.generate (module, 0);
            if (data == null)
                data = new Dactl.SettingsData.from_object (module);
            else
                data.copy_settings (module);
        }

        show_all ();
    }
}
