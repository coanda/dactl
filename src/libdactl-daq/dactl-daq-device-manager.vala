public class Dactl.DAQ.Extension : GLib.Object, Dactl.Extension {

    public virtual void activate () {
        message ("Extension added");
    }

    public virtual void deactivate () {
        message ("Extension removed");
    }
}

public class Dactl.DAQ.DeviceManager : Dactl.PluginManager {

    public DeviceManager () {

        engine = Peas.Engine.get_default ();
        ext = new Dactl.DAQ.Extension ();
        search_path = Dactl.Config.DEVICE_DIR;

        init ();
    }

    protected override void init () {
        GLib.Environment.set_variable ("PEAS_ALLOW_ALL_LOADERS", "1", true);
        engine.enable_loader ("python3");

        message ("Loading peas plugins from: %s", search_path);
        engine.add_search_path (search_path, null);

        /* Our extension set */
        Parameter param = GLib.Parameter ();
        param.value = ext as Dactl.DAQ.Extension;
        param.name = "object";
        extensions = new Peas.ExtensionSet (engine,
                                            typeof (Peas.Activatable),
                                            "object",
                                            ext,
                                            null);

        extensions.extension_added.connect ((info, extension) => {
            (extension as Dactl.Extension).activate ();
        });

        extensions.extension_removed.connect ((info, extension) => {
            (extension as Dactl.Extension).deactivate ();
        });

        // Load all the plugins found
        foreach (var plug in engine.get_plugin_list ()) {
            if (engine.try_load_plugin (plug)) {
                warning ("Plugin Loaded: " + plug.get_name ());
            } else {
                warning ("Could not load plugin: " + plug.get_name ());
            }
        }
    }
}
