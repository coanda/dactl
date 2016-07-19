public class Dactl.DAQ.Extension : GLib.Object, Dactl.Extension {

    public virtual void activate () {
        message ("DAQ extension added");
    }

    public virtual void deactivate () {
        message ("DAQ extension removed");
    }
}

public class Dactl.DAQ.DeviceManager : Dactl.PluginManager {

    public DeviceManager () {

        engine = Peas.Engine.get_default ();
        ext = new Dactl.DAQ.Extension ();
        search_path = Dactl.Config.DEVICE_DIR;

        init ();
        add_extension ();
        load_plugins ();
    }

    protected override void add_extension () {
        // The extension set
        Parameter param = GLib.Parameter ();
        param.value = ext as Dactl.DAQ.Extension;
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
