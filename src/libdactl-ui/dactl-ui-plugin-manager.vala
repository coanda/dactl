public class Dactl.UI.Extension : GLib.Object, Dactl.Extension {

    public Dactl.Widget widget { get; construct set; }

    public virtual void activate () {
        message ("UI Extension added");
    }

    public virtual void deactivate () {
        message ("UI Extension removed");
    }
}

public class Dactl.UI.PluginManager : Dactl.PluginManager {

    public PluginManager () {
        engine = Peas.Engine.get_default ();
        ext = new Dactl.UI.Extension ();

        init ();
    }

    protected override void init () {
        GLib.Environment.set_variable ("PEAS_ALLOW_ALL_LOADERS", "1", true);
        engine.enable_loader ("python3");

        // Use default search path for plugins
        message ("Loading peas plugins from: %s", search_path);
        engine.add_search_path (search_path, null);

        // The extension set
        extensions = new Peas.ExtensionSet (engine,
                                            typeof (Peas.Activatable),
                                            "widget",
                                            ext,
                                            null);

        // The old extension set
        // XXX here just as reference in case widget set is wrong
        /*
         *Parameter param = GLib.Parameter ();
         *param.value = plugin_ext;
         *param.name = "object";
         *extensions = new Peas.ExtensionSet (engine,
         *                                    typeof (Peas.Activatable),
         *                                    "object",
         *                                    plugin_ext,
         *                                    null);
         */

        extensions.extension_added.connect ((info, extension) => {
            (extension as Dactl.UI.Extension).activate ();
        });

        extensions.extension_removed.connect ((info, extension) => {
            (extension as Dactl.UI.Extension).deactivate ();
        });

        // Load all the plugins found
        foreach (var plug in engine.get_plugin_list ()) {
            if (engine.try_load_plugin (plug)) {
                warning ("Plugin loaded: " + plug.get_name ());
            } else {
                warning ("Failed to load plugin: " + plug.get_name ());
            }
        }
    }
}
