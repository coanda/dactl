[GtkTemplate (ui = "/org/coanda/dactl/ui/log_settings_dialog.ui")]
public class Dactl.LogSettingsDialog : Gtk.FileChooserDialog {

    [GtkChild]
    private Gtk.Label lbl_selected;

    [GtkChild]
    private Gtk.Label lbl_access;

    private string path;
    private int mode = Posix.R_OK | Posix.W_OK;

    public Cld.Log log {
        get { return _log; }
        set { _log = value; }
    }

    public bool done = false;

    /* Property backing fields. */
    private Cld.Log _log;

    public LogSettingsDialog (Cld.Log log) {
        this.log = log;
        create_dialog ();
    }

    private void create_dialog () {
        lbl_selected.set_text (log.path);

        if (Posix.access (log.path, mode) == 0) {
            lbl_access.set_text ("YES");
        } else {
            lbl_access.set_text ("NO");
        }
    }

    [GtkCallback]
    private void response_cb (Gtk.Dialog source, int id) {
        switch (id) {
            case Gtk.ResponseType.OK:
                if (Posix.access (path, mode) == 0) {
                    log.path = path;
                }
                done = true;
                destroy ();
                break;
            case Gtk.ResponseType.CANCEL:
                done = true;
                destroy ();
                break;
            default:
                break;
        }
    }

    [GtkCallback]
    private void current_folder_changed_cb () {
        path = get_current_folder ();
        lbl_selected.set_text (path);

        if (!(Posix.access (path, mode) == 0)) {
            Cld.debug ("Invalid path\n");
            lbl_access.set_text ("NO");
        } else {
            Cld.debug ("folder_activated :: path: %s\n", path);
            lbl_access.set_text ("YES");
        }
    }
}
