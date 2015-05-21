/**
 *
 * A container for property values that are within the Cld namespace
 *
 */
public class Dactl.CldSettingsData : Gee.HashMap<string, Dactl.SettingValues> {
    public string uri_selected { private get; set; }

    public signal void new_data (string uri, GLib.ParamSpec spec, GLib.Value value);

    public bool admin = false;

    public CldSettingsData.from_object (Cld.Object object) {
        var app = Dactl.UI.Application.get_default ();
        admin = app.model.admin;
        copy_settings (object);
    }

    /**
     * Recursively copies properties from a Cld.Object to this
     *
     * @param object The object that is to have its properties copied
     *
     */
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

    /**
     * Sets a single value in this that corresponds to a property value
     * of a Cld.Object
     *
     * @param spec specifies the parameter to be set
     * @param value the value to be set
     */
    public void set_value (GLib.ParamSpec spec, GLib.Value value) {
        var svalues = get (uri_selected);
        Dactl.SettingValue val = new Dactl.SettingValue (value);
        svalues.set (spec, val);
        new_data (uri_selected, spec, value);
    }
}

/**
 *
 * A container for property values that are within the Dactl namespace
 *
 */
public class Dactl.NativeSettingsData : Gee.HashMap<Dactl.Object, Dactl.SettingValues>  {
    public Dactl.Object object_selected { private get; set; }

    public signal void new_data (Dactl.Object object, GLib.ParamSpec spec, GLib.Value value);

    public bool admin = false;

    public NativeSettingsData.from_map (Gee.Map<string, Dactl.Object> map) {
        var app = Dactl.UI.Application.get_default ();
        admin = app.model.admin;
        foreach (var object in map.values) {
            copy_settings (object);
        }
    }

    /**
     * Recursively copies properties from a Dactl.Object to this
     *
     * @param object The object that is to have its properties copied
     *
     */
    public void copy_settings (Dactl.Object object) {
        GLib.Type type = object.get_type ();
        GLib.ObjectClass ocl = (GLib.ObjectClass)type.class_ref ();
        Dactl.SettingValues svalues = new SettingValues ();
        set (object, svalues);
        foreach (var spec in ocl.list_properties ()) {
            bool writable = (spec.flags & GLib.ParamFlags.WRITABLE) ==
                                                       GLib.ParamFlags.WRITABLE;
            bool readable = (spec.flags & GLib.ParamFlags.READABLE) ==
                                                       GLib.ParamFlags.READABLE;
            if (readable) {
                if (writable || admin) {
                    Value value = Value (spec.value_type);//returns the default value for this type

                    object.get_property (spec.get_name (), ref value);
                    Dactl.SettingValue val = new Dactl.SettingValue (value);
                    svalues.set (spec, val);
                }
            }
        }

        if (object is Dactl.Container) {
            foreach (var obj in (object as Dactl.Container).objects.values)
                copy_settings (obj);
        }
    }

    /**
     * Sets a single value in this that corresponds to a property value
     * of a Dactl.Object
     *
     * @param spec specifies the parameter to be set
     * @param value the value to be set
     */
    public void set_value (GLib.ParamSpec spec, GLib.Value value) {
        var svalues = get (object_selected);
        Dactl.SettingValue val = new Dactl.SettingValue (value);
        svalues.set (spec, val);
        new_data (object_selected, spec, value);
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
