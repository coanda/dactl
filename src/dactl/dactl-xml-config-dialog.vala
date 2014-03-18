[GtkTemplate (ui = "/org/coanda/dactl/ui/xml_config_dialog.ui")]
public class Dactl.XmlConfigDialog : Gtk.Dialog {

    [GtkChild]
    private Gtk.TextBuffer config_buffer;

    /**
     * Default construction.
     */
    public XmlConfigDialog (string filename) {
        try {
            string text;
            FileUtils.get_contents (filename, out text);
            config_buffer.text = text;
        } catch (GLib.Error e) {
            stderr.printf ("Error: %s\n", e.message);
        }

        (this as Gtk.Window).set_decorated (true);
        show_all ();
    }

    [GtkCallback]
    private void response_cb (Gtk.Dialog source, int id) {
        switch (id) {
            case Gtk.ResponseType.CLOSE:
                GLib.message ("Closing XML config dialog.");
                destroy ();
                break;
            default:
                break;
        }
    }
}
