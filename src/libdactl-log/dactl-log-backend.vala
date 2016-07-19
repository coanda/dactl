public class Dactl.Log.Backend : GLib.Object, Dactl.Extension {

    public virtual void activate () {
        message ("Log extension added");
    }

    public virtual void deactivate () {
        message ("Log extension removed");
    }
}
