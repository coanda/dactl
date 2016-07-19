[DBus (name = "org.coanda.Dactl")]
public interface Dactl.DBusInterface : GLib.Object {
    public const string SERVICE_NAME = "org.coanda.Dactl";
    public const string OBJECT_PATH = "/org/coanda/Dactl";

    public abstract void shutdown () throws IOError;
}
