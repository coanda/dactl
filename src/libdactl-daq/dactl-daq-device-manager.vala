public class Dactl.DAQ.Device : GLib.Object {

    public Dactl.Net.ZmqService zmq_service { get; construct set; }

    public Device (Dactl.Net.ZmqService zmq_service) {
        debug ("Device constructor");
        this.zmq_service = zmq_service;
    }
}

public class Dactl.DAQ.DeviceManager : Dactl.PluginManager {

    private Dactl.Net.ZmqService zmq_service;

    public Dactl.DAQ.Device ext { get; set; }

    public DeviceManager (Dactl.Net.ZmqService zmq_service) {
        this.zmq_service = zmq_service;

        engine = Peas.Engine.get_default ();
        ext = new Dactl.DAQ.Device (zmq_service);
        search_path = Dactl.Config.DEVICE_DIR;

        init ();
        add_extension ();
        load_plugins ();
    }

    protected override void add_extension () {
        // The extension set
        extensions = new Peas.ExtensionSet (engine,
                                            typeof (Peas.Activatable),
                                            "object",
                                            ext,
                                            null);

        extensions.extension_added.connect ((info, extension) => {
            (extension as Peas.Activatable).activate ();
        });

        extensions.extension_removed.connect ((info, extension) => {
            (extension as Peas.Activatable).deactivate ();
        });
    }
}
