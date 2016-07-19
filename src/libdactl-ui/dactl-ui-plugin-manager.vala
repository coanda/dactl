public class Dactl.UI.Extension : GLib.Object, Dactl.Extension {

    public Dactl.Widget widget { get; construct set; }

    public virtual void activate () {
        message ("UI extension added");
    }

    public virtual void deactivate () {
        message ("UI extension removed");
    }
}

public class Dactl.UI.PluginManager : Dactl.PluginManager {

    public PluginManager () {
        engine = Peas.Engine.get_default ();
        ext = new Dactl.UI.Extension ();

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
            (extension as Dactl.UI.Extension).activate ();
        });

        extensions.extension_removed.connect ((info, extension) => {
            (extension as Dactl.UI.Extension).deactivate ();
        });
    }
}
