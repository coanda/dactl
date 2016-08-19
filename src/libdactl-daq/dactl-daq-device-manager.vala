public class Dactl.DAQ.Device : Dactl.Extension, Peas.Activatable {

    public Dactl.Net.ZmqService zmq_service;

    public GLib.Object object { construct; owned get; }

    public Device (Dactl.Net.ZmqService zmq_service) {
        this.zmq_service = zmq_service;
    }

    public void activate () {
        message ("DAQ extension added");
    }

    public void deactivate () {
        message ("DAQ extension removed");
    }

    public void update_state () { }
}

public class Dactl.DAQ.DeviceManager : Dactl.PluginManager {

    private Dactl.Net.ZmqService zmq_service;

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
        Parameter param = GLib.Parameter ();
        param.value = ext as Dactl.DAQ.Device;
        param.name = "object";
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
