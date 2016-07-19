public class Dactl.Log.BackendManager : Dactl.PluginManager {

    public BackendManager () {

        engine = Peas.Engine.get_default ();
        ext = new Dactl.Log.Backend ();
        search_path = Dactl.Config.BACKEND_DIR;

        init ();
        add_extension ();
        load_plugins ();
    }

    protected override void add_extension () {
		// The extension set
        Parameter param = GLib.Parameter ();
        param.value = ext as Dactl.Log.Backend;
        param.name = "object";
        extensions = new Peas.ExtensionSet (engine,
                                            typeof (Peas.Activatable),
                                            "object",
                                            ext,
                                            null);

        extensions.extension_added.connect ((info, extension) => {
            (extension as Dactl.Extension).activate ();
        });

        extensions.extension_removed.connect ((info, extension) => {
            (extension as Dactl.Extension).deactivate ();
        });
    }
}
