using Gtk;
using Cld;

public class LogSettingsDialog : Dialog {

    private Gtk.Builder builder;
    private GLib.Object dlg_log_file_chooser;
    private Gtk.Label lbl_selected;
    private Gtk.Label lbl_access;
    private string path;
    private int mode = Posix.R_OK | Posix.W_OK;
    private Cld.Log _log;
    public Cld.Log log {
        get { return _log; }
        set { _log = value; }
    }

    public bool done = false;

        construct {
        string path = GLib.Path.build_filename (Config.UI_DIR,
                                                "log_dialog.ui");
        builder = new Gtk.Builder ();
        Cld.debug ("Loaded interface file: %s\n", path);

        try {
            builder.add_from_file (path);
        } catch (GLib.Error e) {
            var msg = new MessageDialog (null, DialogFlags.MODAL,
                                         MessageType.ERROR,
                                         ButtonsType.CANCEL,
                                         "Failed to load UI\n%s",
                                         e.message);
            msg.run ();
        }
    }

    public LogSettingsDialog (Cld.Log log) {
        this.log = log;
        create_dialog ();
        connect_signals ();
    }

    private void create_dialog () {
        dlg_log_file_chooser = builder.get_object ("dlg_log_file_chooser");
        lbl_selected = (builder.get_object ("lbl_selected") as Label);
        lbl_access = (builder.get_object ("lbl_access") as Label);

        (lbl_selected as Label).set_text (log.path);
        if (Posix.access (log.path, mode) == 0) {
            (lbl_access as Label).set_text ("YES");
        } else {
            (lbl_access as Label).set_text ("NO");
        }

        var content = get_content_area ();
        var action = get_action_area ();
        var _content = (dlg_log_file_chooser as Dialog).get_content_area ();
        _content.reparent (content);
        add_button (Stock.CANCEL, ResponseType.CANCEL);
        add_button (Stock.OK, ResponseType.OK);
        action.show_all ();
        content.show_all ();
    }

    private void connect_signals () {
        this.response.connect (response_cb);
        (dlg_log_file_chooser as FileChooser).current_folder_changed.connect (current_folder_changed_cb);
    }

    private void response_cb (Dialog source, int response_id) {
        switch (response_id) {
            case ResponseType.OK:
                if (Posix.access (path, mode) == 0) {
                    log.path = path;
                }
                done = true;
                hide ();
                break;
            case ResponseType.CANCEL:
                done = true;
                hide ();
                break;
        }
    }

    private void current_folder_changed_cb () {
        path = (dlg_log_file_chooser as Gtk.FileChooser).get_current_folder ();
        (lbl_selected as Label).set_text (path);
        if (!(Posix.access (path, mode) == 0)) {
            Cld.debug ("Invalid path\n");
            (lbl_access as Label).set_text ("NO");
        } else {
            (lbl_access as Label).set_text ("YES");

        Cld.debug ("folder_activated :: path: %s\n", path);
        }
    }
}
