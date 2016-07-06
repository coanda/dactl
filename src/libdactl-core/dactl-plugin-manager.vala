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

public abstract class Dactl.PluginManager {

    /* FIXME: Should load controller as API from the app, later. */

    protected Peas.Engine engine;
    protected Peas.ExtensionSet extensions;
    protected string search_path = Config.PLUGIN_DIR;

    public Dactl.Extension ext { protected set; public get; }

    protected abstract void init ();
}
