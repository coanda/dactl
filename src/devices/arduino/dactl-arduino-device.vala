public class Dactl.DAQ.Arduino.Device : Dactl.Extension, Peas.Activatable {

    public Dactl.Net.ZmqService zmq_service;

    public GLib.Object object { owned get; construct; }

    public Device (Dactl.Net.ZmqService zmq_service) {
        //base (zmq_service);
        this.zmq_service = zmq_service;
    }

    public void activate () {
        stdout.printf ("Arduino device activated");
        zmq_service.data_published.connect ((data) => {
            stdout.write (data);
        });
    }

    public void deactivate () { }

    public void update_state () { }
}

[ModuleInit]
public void peas_register_types (GLib.TypeModule module) {
    var objmodule = module as Peas.ObjectModule;
    objmodule.register_extension_type (typeof (Peas.Activatable),
                                       typeof (Dactl.DAQ.Arduino.Device));
}
