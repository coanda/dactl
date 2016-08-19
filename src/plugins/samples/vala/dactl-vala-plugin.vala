/**
 * Sample plugin using libpeas.
 */
public class Dactl.Sample.Plugin : Dactl.UI.Plugin, PeasGtk.Configurable {

    public GLib.Object object { owned get; construct; }

    public Plugin (Dactl.ApplicationView view) {
        base (view);
    }

    public void activate () {
        GLib.message ("Dactl.Sample.Plugin activated.");
    }

    public void deactivate () {
        GLib.message ("Dactl.Sample.Plugin deactivated.");
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
