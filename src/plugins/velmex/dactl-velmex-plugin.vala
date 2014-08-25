/*
 * This file is a modified version taken from Rygel.
 */

public void module_init (Dactl.PluginLoader loader) {
    try {
        // Instantiate the plugin object
        var plugin = new Dactl.Velmex.Plugin ();
        plugin.active = true;

        loader.add_plugin (plugin);
    } catch (Error error) {
        warning ("Failed to load %s: %s",
                 Dactl.Velmex.Plugin.NAME,
                 error.message);
    }
}

public class Dactl.Velmex.Plugin : Dactl.Plugin, Dactl.CldAdapter {

    public const string NAME = "velmex";

    private Dactl.Velmex.Control control;

    public string mod_ref { get; set; }

    private weak Cld.Module _module;

    public Cld.Module module {
        get { return _module; }
        set {
            if ((value as Cld.Object).uri == mod_ref) {
                _module = value;
                module_isset = true;
            }
        }
    }

    private bool module_isset { get; private set; default = false; }

    /**
     * {@inheritDoc}
     */
    protected bool satisfied { get; set; default = false; }

    public signal void cld_object_added ();

    /**
     * Instantiate the plugin.
     */
    public Plugin () {
        // Call the base constructor,
        base (NAME, null, null, Dactl.PluginCapabilities.CLD_OBJECT);
    }

    /**
     * {@inheritDoc}
     */
    public void offer_cld_object (Cld.Object object) {
        if (object.uri == mod_ref) {
            module = (object as Cld.Module);
            satisfied = true;
        }
    }

    /**
     * {@inheritDoc}
     */
    protected async void request_data () {
        while (!satisfied) {
            request_object (mod_ref);
            // Try again in a second
            yield nap (1000);
        }
        cld_object_added ();
    }

    /**
     * {@inheritDoc}
     */
    public override void post_construction (Xml.Node *node) {
        if (node->type == Xml.ElementType.ELEMENT_NODE &&
            node->type != Xml.ElementType.COMMENT_NODE) {
            mod_ref = node->get_prop ("ref");
        }

        // Request CLD data
        request_data.begin ();
    }

    /**
     * {@inheritDoc}
     */
    public override Dactl.Object get_control () {
        if (control == null) {
            control = new Dactl.Velmex.Control (this);
        }
        return control;
    }
}
