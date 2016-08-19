/*
 *public abstract class Dactl.Extension : Peas.ExtensionBase, Peas.Activatable {
 *
 *    public abstract GLib.Object object { construct; owned get; }
 *
 *    [> Plugin construction <]
 *    public abstract void activate ();
 *
 *    [> Plugin deconstruction <]
 *    public abstract void deactivate ();
 *
 *    public abstract void update_state ();
 *}
 */

public abstract class Dactl.Extension : Peas.ExtensionBase {

}

public class Dactl.PluginExtension : Dactl.Extension, Peas.Activatable {

    public GLib.Object object { construct; owned get; }

    public void activate () {
        message ("Extension added");
    }

    public void deactivate () {
        message ("Extension removed");
    }

    public void update_state () { }
}

public abstract class Dactl.PluginManager {

    /* FIXME: Should load controller as API from the app, later. */

    protected Peas.Engine engine;
    protected Peas.ExtensionSet extensions;
    protected string search_path = Config.PLUGIN_DIR;

    public Dactl.Extension ext { protected set; public get; }

    protected virtual void init () {
		GLib.Environment.set_variable ("PEAS_ALLOW_ALL_LOADERS", "1", true);
		engine.enable_loader ("python3");

		message ("Loading peas plugins from: %s", search_path);
		engine.add_search_path (search_path, null);
    }

    protected abstract void add_extension ();

    protected virtual void load_plugins () {
        foreach (var plug in engine.get_plugin_list ()) {
            if (engine.try_load_plugin (plug)) {
                debug (_("Plugin loaded: " + plug.get_name ()));
            }
        }
    }
}
