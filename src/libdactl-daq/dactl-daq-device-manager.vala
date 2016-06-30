public class Dactl.DAQ.DeviceExtension : GLib.Object, Dactl.Extension {

    public virtual void activate () {
        message ("Extension added");
    }

    public virtual void deactivate () {
        message ("Extension removed");
    }
}

public class Dactl.DAQ.DeviceManager : Dactl.PluginManager {

    public Dactl.DAQ.DeviceExtension device_ext { private set; public get; }

    public DeviceManager () {

        device_ext = new Dactl.DAQ.DeviceExtension ();
        search_path = Dactl.Config.DEVICE_DIR;

        init ();
    }
}
