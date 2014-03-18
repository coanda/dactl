/*
 * This file is a modified version taken from Rygel.
 */

using Gee;

/**
 * DactlPluginCapabilities is a set of flags that represent various
 * capabilities of plugins.
 */
[Flags]
public enum Dactl.PluginCapabilities {
    NONE = 0,

    /// Supports CLD object access
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

    // Path to description document
    public string desc_path { get; construct; }

    public bool active { get; set; }

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
        GLib.Object (desc_path : desc_path,
                     name : name,
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
}
