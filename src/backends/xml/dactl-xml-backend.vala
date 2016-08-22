public class Dactl.Log.Xml.Backend : Peas.ExtensionBase, Peas.Activatable, Dactl.Log.Backend {
//public class Dactl.Log.Xml.Backend : Dactl.Log.AbstractBackend, Peas.Activatable {

    private Dactl.Log.BackendProxy proxy;

    public GLib.Object object { construct; owned get; }

    public Backend (Dactl.Net.ZmqService zmq_service) {
        debug ("XML backend constructor");
    }

    /**
     * Opens a new XML document.
     */
    public void open () throws GLib.Error {
    }

    /**
     * Closes the currently open XML document.
     */
    public void close () throws GLib.Error {
    }

    /**
     * Executed when the plugin is loaded by the manager class.
     */
    public void activate () {
        debug ("XML backend activated");
        proxy = (Dactl.Log.BackendProxy) object;
        proxy.zmq_client.data_received.connect ((data) => {
            debug ((string) data);
        });
    }

    public void deactivate () { }

    public void update_state () { }
}

[ModuleInit]
public void peas_register_types (GLib.TypeModule module) {
    var objmodule = module as Peas.ObjectModule;
    objmodule.register_extension_type (typeof (Peas.Activatable),
                                       typeof (Dactl.Log.Xml.Backend));
}
