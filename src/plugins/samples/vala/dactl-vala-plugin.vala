/**
 * Sample plugin using libpeas.
 */
public class Dactl.Sample.Plugin : Peas.ExtensionBase, Peas.Activatable, PeasGtk.Configurable {

    private Dactl.UI.Plugin plugin;

    public GLib.Object object { owned get; construct; }

    public Plugin (Dactl.ApplicationView view) {
        debug ("UI Plugin constructor");
    }

    public void activate () {
        debug ("Sample Vala plugin activated.");
        plugin = (Dactl.UI.Plugin) object;
    }

    public void deactivate () {
        debug ("Sample vala lugin deactivated.");
    }

    public void update_state () { }

    public Gtk.Widget create_configure_widget () {
        var label = new Gtk.Label ("Sample plugin configuration.");
        return label;
    }
}

[ModuleInit]
public void peas_register_types (GLib.TypeModule module) {
    var objmodule = module as Peas.ObjectModule;
    objmodule.register_extension_type (typeof (Peas.Activatable),
                                       typeof (Dactl.Sample.Plugin));
    objmodule.register_extension_type (typeof (PeasGtk.Configurable),
                                       typeof (Dactl.Sample.Plugin));
}
