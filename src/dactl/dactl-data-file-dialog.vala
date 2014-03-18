[GtkTemplate (ui = "/org/coanda/dactl/ui/data_file_dialog.ui")]
public class Dactl.DataFileDialog : Gtk.Dialog {

    [GtkChild]
    private Gtk.TextBuffer data_buffer;

    public DataFileDialog (string filename) {
        try {
            string text;
            FileUtils.get_contents (filename, out text);
            data_buffer.text = text;
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
                GLib.message ("Closing data file dialog.");
                destroy ();
                break;
            default:
                break;
        }
    }
}
