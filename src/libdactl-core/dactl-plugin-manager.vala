/**
 * Based off of the example at - https://github.com/voldyman/plugin-app
 */

public class Dactl.PluginAPI : GLib.Object {
    public PluginAPI () {
        /* Nothing yet */
    }
}

public class Dactl.PluginManager {

    /* FIXME: Should load controller as API from the app, later. */

    Peas.Engine engine;
    Peas.ExtensionSet exts;

    public Dactl.PluginAPI plugin_iface { private set; public get; }

    public PluginManager () {

        plugin_iface = new Dactl.PluginAPI ();

        engine = Peas.Engine.get_default ();

        GLib.Environment.set_variable ("PEAS_ALLOW_ALL_LOADERS", "1", true);
        engine.enable_loader ("python3");
        engine.enable_loader ("lua5.1");

        message ("Loading peas plugins from: %s", Config.PLUGIN_DIR);
        engine.add_search_path (Config.PLUGIN_DIR, null);

        /* Our extension set */
        Parameter param = GLib.Parameter ();
        param.value = plugin_iface;
        param.name = "object";
        exts = new Peas.ExtensionSet (engine,
                                      typeof (Peas.Activatable),
                                      "object",
                                      plugin_iface,
                                      null);

        // Load all the plugins found
        foreach (var plug in engine.get_plugin_list ()) {
            if (engine.try_load_plugin (plug)) {
                warning ("Plugin Loaded: " + plug.get_name ());
            } else {
                warning ("Could not load plugin: " + plug.get_name ());
            }
        }

        exts.extension_removed.connect (on_extension_removed);
        exts.foreach (extension_foreach);

    }

    void extension_foreach (Peas.ExtensionSet set,
                            Peas.PluginInfo info,
                            Peas.Extension extension) {
        debug ("Extension added");
        ((Peas.Activatable) extension).activate ();
    }

    void on_extension_removed (Peas.PluginInfo info, GLib.Object extension) {
        ((Peas.Activatable) extension).deactivate ();
    }
}
