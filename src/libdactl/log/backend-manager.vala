public class Dactl.Log.BackendManager : Dactl.PluginManager {

    private Dactl.Net.ZmqClient zmq_client;

    public Dactl.Log.BackendProxy ext { get; set; }

    public BackendManager (Dactl.Net.ZmqClient zmq_client) {
        this.zmq_client = zmq_client;

        engine = Peas.Engine.get_default ();
        ext = new Dactl.Log.BackendProxy (zmq_client);
        search_path = Dactl.Config.BACKEND_DIR;

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
