[GtkTemplate (ui = "/org/coanda/dactl/ui/recent_files_dialog.ui")]
public class Dactl.RecentFilesDialog : Gtk.FileChooserDialog {

    [GtkChild]
    private Gtk.RecentManager recent_manager;

    /**
     * Default construction.
     */
    public RecentFilesDialog () {
        set_decorated (true);
        set_modal (true);
        set_transient_for (this);
        set_type_hint (Gdk.WindowTypeHint.DIALOG );

        show_all ();
    }

    [GtkCallback]
    private void response_cb (Gtk.Dialog source, int id) {
        switch (id) {
            case Gtk.ResponseType.CANCEL:
                destroy ();
                break;
            case Gtk.ResponseType.ACCEPT:
                display_file ();
                destroy ();
                break;
            default:
                break;
        }
    }

    [GtkCallback]
    private void file_activated_cb () {
        display_file ();
        destroy ();
    }

    private void display_file () {
        string filename = get_filename ();
        GLib.message ("Displaying file with name: %s\n", filename);
        recent_manager.add_item ("file://" + filename);
        var dialog = new Dactl.DataFileDialog (filename);
    }
}
