/**
 * This file is a modified version taken from Rygel.
 */

/**
 * Errors related to plugin types.
 */
public errordomain Dactl.PluginError {
    NO_CONFIGURABLE_SETTINGS,
    CONTROL_NOT_AVAILABLE
}

/**
 * DactlPluginCapabilities is a set of flags that represent various
 * capabilities of plugins.
 */
[Flags]
public enum Dactl.PluginCapabilities {
    NONE = 0,

    /* Supports CLD object access */
    CLD_OBJECT,

    /* Diagnostics (DIAGE) support */
    DIAGNOSTICS,
}

/**
 * This represents a Dactl plugin.
 *
 * Plugin libraries should provide an object of this class or a subclass in
 * their module_init () function.
 */
public class Dactl.Plugin : GLib.Object {

    public PluginCapabilities capabilities { get; construct set; }

    public string name { get; construct; }

    public string title { get; construct set; }

    public string description { get; construct; }

    public bool active { get; set; }

    private bool _has_factory = false;
    public virtual bool has_factory { get { return _has_factory; } }

    public Dactl.Factory factory { get; protected set; }

    /**
     * Create an instance of the plugin.
     *
     * @param name  The non-human-readable name for the plugin, used in the
     *              Dactl configuration file.
     * @param title An optional human-readable name provided by the plugin. If
     *              the title is empty then the name will be used.
     * @param description  An optional human-readable description service
     *                     provided by the plugin.
     * @param capabilities The functionality and services that the plugin
     *                     provides.
     */
    public Plugin (string  name,
                   string? title,
                   string? description = null,
                   PluginCapabilities capabilities = PluginCapabilities.NONE) {
        GLib.Object (name : name,
                     title : title,
                     description : description,
                     capabilities : capabilities);
    }

    public override void constructed () {
        base.constructed ();

        this.active = true;

        if (this.title == null) {
            this.title = this.name;
        }
    }

    /**
     * Performs any post construction configuration if necessary.
     *
     * @param node An XML node containing the configuration settings.
     */
    /*
     *public virtual void post_construction (Xml.Node *node) throws GLib.Error {
     *    throw new PluginError.NO_CONFIGURABLE_SETTINGS
     *                (_("Plugin `%s' contains no configuration settings"), name);
     *}
     */

    /**
     * Return the UI control for this plugin.
     *
     * @return Corresponding Dactl UI control as a Dactl.Object.
     */
    /*
     *public virtual Dactl.Object get_control () throws GLib.Error {
     *    throw new PluginError.CONTROL_NOT_AVAILABLE
     *                (_("Plugin `%s' contains no configuration settings"), name);
     *}
     */
}
