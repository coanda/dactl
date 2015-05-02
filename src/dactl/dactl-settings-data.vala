public class Dactl.SettingsData : Gee.HashMap<string, Dactl.SettingValues> {

    public string uri_selected { private get; set; }

    public signal void new_data (string uri, GLib.ParamSpec spec, GLib.Value value);

    public bool admin = false;

    construct {

    }

    public SettingsData.from_object (Cld.Object object) {
        var app = Dactl.UI.Application.get_default ();
        admin = app.model.admin;
        copy_settings (object);
    }

    public void copy_settings (Cld.Object object) {
        GLib.Type type = object.get_type ();
        GLib.ObjectClass ocl = (GLib.ObjectClass)type.class_ref ();
        Dactl.SettingValues svalues = new SettingValues ();
        set (object.uri, svalues);
        foreach (var spec in ocl.list_properties ()) {
            bool writable = (spec.flags & GLib.ParamFlags.WRITABLE) ==
                                                       GLib.ParamFlags.WRITABLE;
            if (writable || admin) {
                Value value = Value (spec.value_type);//returns the default value for this type

                object.get_property (spec.get_name (), ref value);
                Dactl.SettingValue val = new Dactl.SettingValue (value);
                svalues.set (spec, val);
            }
        }

        if (object is Cld.Container) {
            foreach (var obj in (object as Cld.Container).get_objects ().values)
                copy_settings (obj);
        }
    }

    public void set_value (GLib.ParamSpec spec, GLib.Value value) {
        var svalues = get (uri_selected);
        Dactl.SettingValue val = new Dactl.SettingValue (value);
        svalues.set (spec, val);
        new_data (uri_selected, spec, value);
    }
}

public class Dactl.SettingValues : Gee.HashMap<GLib.ParamSpec, Dactl.SettingValue> {
}

public class Dactl.SettingValue : GLib.Object {
    public GLib.Value value;

    public SettingValue (GLib.Value value) {
        this.value = value;
    }
}


