public class Dactl.DAQ.MccUsb.Device : Peas.ExtensionBase, Peas.Activatable {

    private Dactl.DAQ.Device device;

    public GLib.Object object { construct; owned get; }

    public Device (Dactl.Net.ZmqService zmq_service) {
        debug ("Measurement Computing USB device constructor");
    }

    public void activate () {
        debug ("Measurement Computing USB device activated");
        device = (Dactl.DAQ.Device) object;
        debug (device.zmq_service.to_string ());
        device.zmq_service.data_published.connect ((data) => {
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
                                       typeof (Dactl.DAQ.MccUsb.Device));
}

