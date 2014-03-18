/**
 * Empty class just for testing right now.
 */
public class Dactl.WidgetInformation : GLib.Object {
    public string name { get; construct; }

    private WidgetInformation (string name) {
        GLib.Object (name : name);
    }
}
