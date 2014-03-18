[DBus (name = "org.gnome.Dactl")]
public interface Dactl.DBusInterface : GLib.Object {
    public const string SERVICE_NAME = "org.gnome.Dactl";
    public const string OBJECT_PATH = "/org/gnome/Dactl";

    public abstract void shutdown () throws IOError;
}
