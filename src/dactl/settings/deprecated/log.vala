[GtkTemplate (ui = "/org/coanda/dactl/ui/log-settings.ui")]
private class Dactl.LogSettings : Gtk.Box {
    public enum LogColumns {
        URI,
        PATH,
        FILE,
        TYPE
    }

    [GtkChild]
    private Gtk.TreeView treeview_logs;

    [GtkChild]
    private Gtk.TreeSelection treeview_logs_selection;

    [GtkChild]
    private Gtk.ListStore liststore_logs;

    [GtkChild]
    private Gtk.RadioButton radiobutton_channel;

    [GtkChild]
    private Gtk.RadioButton radiobutton_streaming;

    [GtkChild]
    private Gtk.Entry entry_id;

    [GtkChild]
    private Gtk.Entry entry_name;

    [GtkChild]
    private Gtk.Button btn_choose_file;

    [GtkChild]
    private Gtk.Entry entry_file;

    [GtkChild]
    private Gtk.Entry entry_rate;

    [GtkChild]
    private Gtk.Entry entry_format;

    [GtkChild]
    private Gtk.Entry entry_timestamp;

    [GtkChild]
    private Gtk.Entry entry_backup_interval;

    [GtkChild]
    private Gtk.Button btn_choose_backup;

    [GtkChild]
    private Gtk.Entry entry_backup_file;

    [GtkChild]
    private Gtk.Box box_rate;

    [GtkChild]
    private Gtk.Box box_interval;

    [GtkChild]
    private Gtk.Box box_backup;

    [GtkChild]
    private Gtk.Box box_data_source;

    [GtkChild]
    private Gtk.Box box_time_stamp;

    [GtkChild]
    private Gtk.FileChooserDialog file_chooser;

    private Cld.Log log_selected;

    construct {
        treeview_logs.set_activate_on_single_click (true);
    }

    public void populate_logs_treeview () {
        var app = Dactl.UI.Application.get_default ();
        var logs = app.model.ctx.get_object_map (typeof (Cld.Log));

        if (logs.size > 0) {
            treeview_logs.set_model (liststore_logs);
            treeview_logs.insert_column_with_attributes
                (-1, "URI", new Gtk.CellRendererText (), "text", LogColumns.URI);
            treeview_logs.insert_column_with_attributes
                (-1, "Path", new Gtk.CellRendererText (), "text", LogColumns.PATH);
            treeview_logs.insert_column_with_attributes
                (-1, "File", new Gtk.CellRendererText (), "text", LogColumns.FILE);
            treeview_logs.insert_column_with_attributes
                (-1, "Type", new Gtk.CellRendererText (), "text", LogColumns.TYPE);

            liststore_logs.clear ();
            Gtk.TreeIter iter;
            foreach (var log in logs.values) {
                string type = "unknown";
                if ((log.get_type ()).is_a (typeof (Cld.CsvLog))) {
                    type = "csv";
                } else if ((log.get_type ()).is_a (typeof (Cld.SqliteLog))) {
                    type = "sqlite";
                }

                liststore_logs.append (out iter);
                liststore_logs.set (iter, LogColumns.URI, log.uri,
                    LogColumns.PATH, (log as Cld.Log).path,
                    LogColumns.FILE, (log as Cld.Log).file,
                    LogColumns.TYPE, type);
            }

            treeview_logs.set_rules_hint (true);
            var path = new Gtk.TreePath.first ();
            treeview_logs.set_cursor (path, null, false);
            treeview_logs_row_activated_cb (path, treeview_logs.get_column (0));
        }
    }

    public void update_preferences () {
        /* XXX TBD */
    }

    private void refresh_logs_treeview () {
        var app = Dactl.UI.Application.get_default ();
        var logs = app.model.ctx.get_object_map (typeof (Cld.Log));

        liststore_logs.clear ();
        Gtk.TreeIter iter;
        foreach (var log in logs.values) {
            string type = "unknown";
            if ((log.get_type ()).is_a (typeof (Cld.CsvLog))) {
                type = "csv";
            } else if ((log.get_type ()).is_a (typeof (Cld.SqliteLog))) {
                type = "sqlite";
            }

            liststore_logs.append (out iter);
            liststore_logs.set (iter, LogColumns.URI, log.uri,
                LogColumns.PATH, (log as Cld.Log).path,
                LogColumns.FILE, (log as Cld.Log).file,
                LogColumns.TYPE, type);
        }
    }

    [GtkCallback]
    private void treeview_logs_row_activated_cb (Gtk.TreePath path, Gtk.TreeViewColumn column) {
        Cld.Log log;
        Gtk.TreeIter iter;
        string uri;

        var app = Dactl.UI.Application.get_default ();
        if (treeview_logs_selection == null ) GLib.message ("selection is null");
        liststore_logs.get_iter (out iter, path);
        liststore_logs.get (iter, LogColumns.URI, out uri);
        log_selected = app.model.ctx.get_object_from_uri (uri) as Cld.Log;
        update_log_entries ();
    }

    private void update_log_entries () {
        string path;

        if ((log_selected.get_type ()).is_a (typeof (Cld.CsvLog))) {
            box_rate.set_visible (true);
            box_time_stamp.set_visible (true);
            box_interval.set_visible (false);
            box_backup.set_visible (false);
            box_data_source.set_visible (false);
            entry_timestamp.set_text ((log_selected as Cld.CsvLog).time_stamp.to_string ());
            entry_rate.set_text ("%.6f".printf ((log_selected as Cld.CsvLog).rate));
        } else if ((log_selected.get_type ()).is_a (typeof (Cld.SqliteLog))) {
            box_rate.set_visible (false);
            box_time_stamp.set_visible (false);
            box_interval.set_visible (true);
            box_backup.set_visible (true);

            box_data_source.set_visible (true);
            entry_backup_interval.set_text (
                    "%d".printf ((int)((log_selected as Cld.SqliteLog).
                    backup_interval_ms / (60 * 60 * 1000))));

            path = (log_selected as Cld.SqliteLog).backup_path;
            if (!path.has_suffix ("/")) {
                path = "%s%s".printf (path, "/");
            }
            entry_backup_file.set_text (path + (log_selected as Cld.SqliteLog).backup_file);

            if ((log_selected as Cld.SqliteLog).data_source == "channel") {
                radiobutton_channel.set_active (true);
            } else if ((log_selected as Cld.SqliteLog).data_source == "streaming") {
                radiobutton_streaming.set_active (true);
            }
        }
        entry_id.set_text (log_selected.id);
        entry_name.set_text ((log_selected as Cld.Log).name);

        path = (log_selected as Cld.Log).path;
        if (!path.has_suffix ("/")) {
            path = "%s%s".printf (path, "/");
        }
        entry_file.set_text (path + (log_selected as Cld.Log).file);

        entry_format.set_text ((log_selected as Cld.Log).date_format);
    }

    [GtkCallback]
    private void btn_choose_file_clicked_cb () {
        file_chooser.set_current_name ("Untitled");
        int res = file_chooser.run ();
        switch (res) {
            case Gtk.ResponseType.OK:
                log_selected.path = file_chooser.get_current_folder ();
                log_selected.file = file_chooser.get_current_name ();
                refresh_logs_treeview ();
                update_log_entries ();
                break;
            case Gtk.ResponseType.CANCEL:
                break;
            default:
                break;
        }

        file_chooser.hide ();
    }

    [GtkCallback]
    private void btn_choose_backup_clicked_cb () {
        file_chooser.set_current_name ("Untitled");
        int res = file_chooser.run ();
        switch (res) {
            case Gtk.ResponseType.OK:
                (log_selected as Cld.SqliteLog).backup_path = file_chooser.get_current_folder ();
                (log_selected as Cld.SqliteLog).backup_file = file_chooser.get_current_name ();
                refresh_logs_treeview ();
                update_log_entries ();
                break;
            case Gtk.ResponseType.CANCEL:
                break;
            default:
                break;
        }

        file_chooser.hide ();
    }

    [GtkCallback]
    private void entry_id_activate_cb () {
        log_selected.id = entry_id.get_text ();
        refresh_logs_treeview ();
    }

    [GtkCallback]
    private void entry_name_activate_cb () {
        (log_selected as Cld.Log).name  = entry_name.get_text ();
    }

    [GtkCallback]
    private void entry_rate_activate_cb () {
        (log_selected as Cld.CsvLog).rate = double.parse (
                entry_rate.get_text ());
    }

    [GtkCallback]
    private void entry_format_activate_cb () {
        (log_selected as Cld.Log).date_format = entry_format.get_text ();
    }

    [GtkCallback]
    private void entry_timestamp_activate_cb () {
        (log_selected as Cld.CsvLog).time_stamp =
                Cld.Log.TimeStampFlag.parse (entry_timestamp.get_text ());

    }

    [GtkCallback]
    private void entry_backup_interval_activate_cb () {
        (log_selected as Cld.SqliteLog).backup_interval_ms = int.parse (
                entry_backup_interval.get_text ()) * 1000 * 60 * 60;
    }

    [GtkCallback]
    private void radiobutton_channel_toggled_cb () {
        if (radiobutton_channel.get_active ()) {
            (log_selected as Cld.SqliteLog).data_source = "channel";
        }
    }

    [GtkCallback]
    private void radiobutton_streaming_toggled_cb () {
        if (radiobutton_streaming.get_active ()) {
            (log_selected as Cld.SqliteLog).data_source = "streaming";
        }
    }
}
