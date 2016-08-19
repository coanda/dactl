public class Dactl.Log.Backend : Dactl.Extension, Peas.Activatable {

    public GLib.Object object { construct; owned get; }

    public void activate () {
        message ("Log extension added");
    }

    public void deactivate () {
        message ("Log extension removed");
    }

    public void update_state () { }
}
