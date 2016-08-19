public class Dactl.UI.Plugin : Dactl.Extension, Peas.Activatable {

    public Dactl.ApplicationView view;

    public GLib.Object object { construct; owned get; }

    public Plugin (Dactl.ApplicationView view) {
        this.view = view;
    }

    public void activate () {
        message ("UI extension added");
    }

    public void deactivate () {
        message ("UI extension removed");
    }

    public void update_state () { }
}

public class Dactl.UI.PluginManager : Dactl.PluginManager {

    private Dactl.ApplicationView view;

    public PluginManager (Dactl.ApplicationView view) {
        this.view = view;

        engine = Peas.Engine.get_default ();
        ext = new Dactl.UI.Plugin (view);

        init ();
        add_extension ();
        load_plugins ();
    }

    protected override void add_extension () {
        // The extension set
        extensions = new Peas.ExtensionSet (engine,
                                            typeof (Peas.Activatable),
                                            "widget",
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
