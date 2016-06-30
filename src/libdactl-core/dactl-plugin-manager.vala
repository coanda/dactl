/**
 * Based off of the example at - https://github.com/voldyman/plugin-app
 */

public interface Dactl.Extension : GLib.Object {

    /* Plugin construction */
    public abstract void activate ();

    /* Plugin deconstruction */
    public abstract void deactivate ();
}

public class Dactl.PluginExtension : GLib.Object, Dactl.Extension {

    public virtual void activate () {
        message ("Extension added");
    }

    public virtual void deactivate () {
        message ("Extension removed");
    }
}

public class Dactl.PluginManager {

    /* FIXME: Should load controller as API from the app, later. */

    protected Peas.Engine engine;
    protected Peas.ExtensionSet extensions;
    protected string search_path = Config.PLUGIN_DIR;

    public Dactl.PluginExtension plugin_ext { private set; public get; }

    public PluginManager () {
        plugin_ext = new Dactl.PluginExtension ();
        engine = Peas.Engine.get_default ();
        init ();
    }

    protected void init () {
        GLib.Environment.set_variable ("PEAS_ALLOW_ALL_LOADERS", "1", true);
        engine.enable_loader ("python3");

        message ("Loading peas plugins from: %s", search_path);
        engine.add_search_path (search_path, null);

        /* Our extension set */
        Parameter param = GLib.Parameter ();
        param.value = plugin_ext;
        param.name = "object";
        extensions = new Peas.ExtensionSet (engine,
                                            typeof (Peas.Activatable),
                                            "object",
                                            plugin_ext,
                                            null);

        extensions.extension_added.connect((info, extension) => {
            (extension as Dactl.Extension).activate();
        });

        extensions.extension_removed.connect((info, extension) => {
            (extension as Dactl.Extension).deactivate();
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
