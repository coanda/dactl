public class Dactl.UI.Plugin : GLib.Object {

    public Dactl.ApplicationView view { get; construct set; }

    public Plugin (Dactl.ApplicationView view) {
        debug ("UI Plugin constructor");
        this.view = view;
    }
}

public class Dactl.UI.PluginManager : Dactl.PluginManager {

    private Dactl.ApplicationView view;

    public Dactl.UI.Plugin ext { get; set; }

    public PluginManager (Dactl.ApplicationView view) {
        this.view = view;

        engine = Peas.Engine.get_default ();
        ext = new Dactl.UI.Plugin (view);
        // XXX UI plugins are installed to the default location - change???

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
