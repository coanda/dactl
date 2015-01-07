[GtkTemplate (ui = "/org/coanda/dactl/ui/csv-export.ui")]
private class Dactl.CsvExport : Gtk.Box {

    /* A data struct of an experiment treeview selection */
    struct ExperimentSelection {
        string id;
        string name;
        string start_date;
        string stop_date;
        string start_time;
        string stop_time;
        string log_rate;
    }

    [GtkChild]
    private Gtk.ListStore listmodel;

    [GtkChild]
    private Gtk.TreeModelFilter model_filter;

    [GtkChild]
    private Gtk.TreeSelection selection;

    [GtkChild]
    private Gtk.TreeView tv_experiment;

    [GtkChild]
    private Gtk.ScrolledWindow sw_experiment;

    [GtkChild]
    private Gtk.Calendar cal_start;

    [GtkChild]
    private Gtk.Calendar cal_stop;

    [GtkChild]
    private Gtk.Entry entry_filename;

    [GtkChild]
    private Gtk.Entry entry_filepath;

    [GtkChild]
    private Gtk.Adjustment adj_step;

    [GtkChild]
    private Gtk.Adjustment adj_start_hour;

    [GtkChild]
    private Gtk.Adjustment adj_start_minute;

    [GtkChild]
    private Gtk.Adjustment adj_start_second;

    [GtkChild]
    private Gtk.Adjustment adj_stop_hour;

    [GtkChild]
    private Gtk.Adjustment adj_stop_minute;

    [GtkChild]
    private Gtk.Adjustment adj_stop_second;

    [GtkChild]
    private Gtk.Dialog log_selector;

    [GtkChild]
    private Gtk.ListStore log_listmodel;

    [GtkChild]
    private Gtk.TreeSelection log_selection;

    [GtkChild]
    private Gtk.ToggleButton btn_single_header;

    private bool first_open = true;

    private Cld.SqliteLog log;
    private DateTime start;
    private DateTime stop;
    private string export_filename;
    private string export_filepath;

    private int step;
    private int start_hour;
    private int start_minute;
    private int stop_hour;
    private int stop_minute;
    private double start_second;
    private double stop_second;
    private bool single_header;

    /* A experiment selections to use */
    private ExperimentSelection select_begin;
    private ExperimentSelection select_end;

    construct {
        /* Add a default-text */
        entry_filepath.text = "enter a directory";
        entry_filename.text = "enter a filename";

        /* Add a way to clear the input */
        entry_filepath.set_icon_from_icon_name (Gtk.EntryIconPosition.SECONDARY,
                                                "edit-clear");
        /* Add a way to select a file and/or location */
        entry_filepath.set_icon_from_icon_name (Gtk.EntryIconPosition.PRIMARY,
                                                "document-open");

        /* Clear the first time the user selects the entry */
        entry_filepath.focus_in_event.connect ((event) => {
            if (entry_filepath.text == "enter a directory") {
                entry_filepath.text = "";
            }
        });

        /* Add a way to clear the input */
        entry_filename.set_icon_from_icon_name (Gtk.EntryIconPosition.SECONDARY,
                                                "edit-clear");

        /* Clear the first time the user selects the entry */
        entry_filename.focus_in_event.connect ((event) => {
            if (entry_filename.text == "enter a filename") {
                entry_filename.text = "";
            }
        });

        log_selector.transient_for = this.get_toplevel () as Gtk.Window;
        log_selector.parent = this;
        log_selector.delete_event.connect (log_selector.hide_on_delete);
        log_selector.modal = true;
        log_selector.type_hint = Gdk.WindowTypeHint.DIALOG;
    }

    private void list_append (string id,
                              string name,
                              string start_date,
                              string stop_date,
                              string start_time,
                              string stop_time,
                              string log_rate,
                              bool visible) {
        Gtk.TreeIter iter;

        listmodel.append (out iter);
        listmodel.set (iter, 0, id);
        listmodel.set (iter, 1, name);
        listmodel.set (iter, 2, start_date);
        listmodel.set (iter, 3, stop_date);
        listmodel.set (iter, 4, start_time);
        listmodel.set (iter, 5, stop_time);
        listmodel.set (iter, 6, log_rate);
        listmodel.set (iter, 7, visible);
    }

    private void populate () {
        var experiments = log.get_experiment_entries ();
        if (experiments.size > 0) {
            foreach (var experiment in experiments) {
                if (experiment != null) {
                    message ("Adding `%d' to experiment list", experiment.id);
                    list_append (experiment.id.to_string (),
                                 experiment.name,
                                 experiment.start_date,
                                 experiment.stop_date,
                                 experiment.start_time,
                                 experiment.stop_time,
                                 experiment.log_rate.to_string (),
                                 true);
                }
            }

            model_filter.set_visible_column (7);
            (listmodel as Gtk.TreeSortable).set_sort_func (0, compare_int);
            var path = new Gtk.TreePath.from_string ("0");
            tv_experiment.set_cursor (path, null, false);
        }
    }

    private void append_experiments () {
        Gtk.TreeIter iter;

        var experiments = log.get_experiment_entries ();
        if (experiments.size > 0) {
            var n = listmodel.iter_n_children (null);
            if (experiments.size > n) {
                var experiment = experiments.get (n++);
                message ("Adding `%d' to experiment list", experiment.id);

                var model = tv_experiment.model as Gtk.TreeModelFilter;
                var store = model.child_model;
                (store as Gtk.ListStore).append (out iter);
                (store as Gtk.ListStore).set (iter, 0, experiment.id.to_string (),
                                                    1, experiment.name,
                                                    2, experiment.start_date,
                                                    3, experiment.stop_date,
                                                    4, experiment.start_time,
                                                    5, experiment.stop_time,
                                                    6, experiment.log_rate.to_string (),
                                                    7, true);

                /*
                 *list_append (experiment.id.to_string (),
                 *             experiment.name,
                 *             experiment.start_date,
                 *             experiment.stop_date,
                 *             experiment.start_time,
                 *             experiment.stop_time,
                 *             experiment.log_rate.to_string (),
                 *             true);
                 */
            }
        }
    }

    private int compare_int (Gtk.TreeModel model,
                             Gtk.TreeIter iter_a,
                             Gtk.TreeIter iter_b) {
        int sort_column_id;
        int order;
        Value a_str;
        Value b_str;

        (listmodel as Gtk.TreeSortable).get_sort_column_id (out sort_column_id,
                                                            out order);
        model.get_value (iter_a, sort_column_id, out a_str);
        model.get_value (iter_b, sort_column_id, out b_str);

        int a = int.parse ((string) a_str);
        int b = int.parse ((string) b_str);

        if (a < b) {
            return -1;
        } else if (a == b) {
            return 0;
        } else {
            return 1;
        }
    }

    /**
     * Update the dialog based on the experiment treeview selection.
     */
    private void update_time () {
        DateTime now = new DateTime.now_local ();
        int year, month, day, hour, minute, second;

        /* Update start time and date */
        if (select_begin.start_date != "<none>" && select_begin.start_time != "<none>") {
            year = int.parse (select_begin.start_date.substring (0, 4));
            month = (int.parse (select_begin.start_date.substring (5, 2)));
            day = int.parse (select_begin.start_date.substring (8, 2));
            hour = int.parse (select_begin.start_time.substring (0, 2));
            minute = int.parse (select_begin.start_time.substring (3, 2));
            second = int.parse (select_begin.start_time.substring (6, 2));
        } else {
            now.get_ymd (out year, out month, out day);
            hour = now.get_hour ();
            minute = now.get_minute ();
            second = now.get_second ();
        }

        start = new DateTime.local ((int)year,
                                    (int)month,
                                    (int)day,
                                    (int)hour,
                                    (int)minute,
                                    second);

        cal_start.select_month (start.get_month () - 1, start.get_year());
        cal_start.select_day (start.get_day_of_month ());
        adj_start_hour.set_value (start.get_hour ());
        adj_start_minute.set_value (start.get_minute ());
        adj_start_second.set_value (start.get_second ());

        /* Update stop time and date */
        if (select_end.stop_date != "<none>" && select_end.stop_time != "<none>") {
            year = int.parse (select_end.stop_date.substring (0, 4));
            month = (int.parse (select_end.stop_date.substring (5, 2)));
            day = int.parse (select_end.stop_date.substring (8, 2));
            hour = int.parse (select_end.stop_time.substring (0, 2));
            minute = int.parse (select_end.stop_time.substring (3, 2));
            second = int.parse (select_end.stop_time.substring (6, 2));
        } else {
            now.get_ymd (out year, out month, out day);
            hour = now.get_hour ();
            minute = now.get_minute ();
            second = now.get_second ();
        }

        stop = new DateTime.local ((int)year,
                                   (int)month,
                                   (int)day,
                                   (int)hour,
                                   (int)minute,
                                   second);

        cal_stop.select_month (stop.get_month () - 1, stop.get_year ());
        cal_stop.select_day (stop.get_day_of_month ());
        adj_stop_hour.set_value (stop.get_hour ());
        adj_stop_minute.set_value (stop.get_minute ());
        adj_stop_second.set_value (stop.get_second ());
    }

    private void update_values () {
        uint year, month, day;

        cal_start.get_date (out year, out month, out day);
        start = new DateTime.local ((int)year,
                                    (int)month + 1,
                                    (int)day,
                                    start_hour,
                                    start_minute,
                                    start_second);

        cal_stop.get_date (out year, out month, out day);
        stop = new DateTime.local ((int)year,
                                   (int)month + 1,
                                   (int)day,
                                   stop_hour,
                                   stop_minute,
                                   stop_second);
    }

    [GtkCallback]
    private void map_cb () {
        var app = Dactl.UI.Application.get_default ();
        var logs = app.model.ctx.get_object_map (typeof (Cld.SqliteLog));

        message (" > Mapped CSV export");

        if (logs.size > 1) {
            if (first_open) {
                foreach (var object in logs.values) {
                    Gtk.TreeIter iter;
                    log_listmodel.append (out iter);
                    log_listmodel.set (iter, 0, object.id);
                }
                first_open = false;
            }
            log_selector.show ();
        } else {
            var arr = logs.values.to_array ();
            log = arr[0] as Cld.SqliteLog;

            message ("   - Received %d logs - showing the first", arr.length);

            if (first_open) {
                populate ();
                first_open = false;
            } else {
                append_experiments ();
            }
        }
    }

    [GtkCallback]
    private void log_selector_response_cb (int response_id) {
        switch (response_id) {
            case Gtk.ResponseType.OK:
                string id;
                Gtk.TreeIter log_iter;
                Gtk.TreeModel log_model;

                log_selection.get_selected (out log_model, out log_iter);
                log_model.get (log_iter, 0, out id);
                var app = Dactl.UI.Application.get_default ();
                log = app.model.ctx.get_object (id) as Cld.SqliteLog;

                /* FIXME: clearing doesn't work */
                //listmodel.clear ();
                populate ();

                log_selector.hide ();
                break;
        }
    }

    [GtkCallback]
    private void entry_filename_activate_cb () {
/*
 *        export_filename = (log as Cld.Log).path;
 *
 *        if (!(export_filename.has_suffix ("/"))) {
 *            export_filename = "%s%s".printf ((log as Cld.Log).path, "/");
 *        }
 *
 *        export_filename = "%s%s%s%s%s%s%s".printf (
 *                                export_filename,
 *                                (log as Cld.Log).file.replace (".","_"),
 *                                "_",
 *                                start.to_string (),
 *                                "_",
 *                                stop.to_string (),
 *                                ".csv"
 *                            );
 */

        /*
         *entry_filename.set_text (export_filename);
         */

        export_filename = entry_filename.text;
    }

    [GtkCallback]
    private void adj_step_changed_cb () {
        step = (int)adj_step.get_value ();
    }

    [GtkCallback]
    private void adj_start_hour_changed_cb () {
        start_hour = (int)adj_start_hour.get_value ();
        update_values ();
    }

    [GtkCallback]
    private void adj_start_minute_changed_cb () {
        start_minute = (int)adj_start_minute.get_value ();
        update_values ();
    }

    [GtkCallback]
    private void adj_start_second_changed_cb () {
        start_second = adj_start_second.get_value ();
        update_values ();
    }

    [GtkCallback]
    private void adj_stop_hour_changed_cb () {
        stop_hour = (int)adj_stop_hour.get_value ();
        update_values ();
    }

    [GtkCallback]
    private void adj_stop_minute_changed_cb () {
        stop_minute = (int)adj_stop_minute.get_value ();
        update_values ();
    }

    [GtkCallback]
    private void adj_stop_second_changed_cb () {
        stop_second = adj_stop_second.get_value ();
        update_values ();
    }

    [GtkCallback]
    private void selection_changed_cb () {
        Gtk.TreeModel model;
        Gtk.TreeIter iter;
        GLib.List<Gtk.TreePath> path_list;
        unowned GLib.List<Gtk.TreePath>? path;

        //if (listmodel.get_iter_first (out iter) == true) {

            path_list = selection.get_selected_rows (out model);

            /* Get beginning table information */
            path = path_list.first ();
            model.get_iter (out iter, path.data);
            model.get (iter, 0, out select_begin.id);
            model.get (iter, 1, out select_begin.name);
            model.get (iter, 2, out select_begin.start_date);
            model.get (iter, 3, out select_begin.stop_date);
            model.get (iter, 4, out select_begin.start_time);
            model.get (iter, 5, out select_begin.stop_time);
            model.get (iter, 6, out select_begin.log_rate);
            debug ("%s || %s || %s ||  %s || %s ||  %s || %s",
                    select_begin.id, select_begin.name, select_begin.start_date, select_begin.stop_date,
                    select_begin.start_time, select_begin.stop_time, select_begin.log_rate);

            /* Get ending table information */
            path = path_list.last ();
            model.get_iter (out iter, path.data);
            model.get (iter, 0, out select_end.id);
            model.get (iter, 1, out select_end.name);
            model.get (iter, 2, out select_end.start_date);
            model.get (iter, 3, out select_end.stop_date);
            model.get (iter, 4, out select_end.start_time);
            model.get (iter, 5, out select_end.stop_time);
            model.get (iter, 6, out select_end.log_rate);
            debug ("%s || %s || %s ||  %s || %s ||  %s || %s",
                    select_end.id, select_end.name, select_end.start_date, select_end.stop_date,
                    select_end.start_time, select_end.stop_time, select_end.log_rate);
        //}

        update_time ();
    }

    [GtkCallback]
    private void entry_filepath_icon_press_cb (Gtk.EntryIconPosition pos,
                                               Gdk.Event event) {
        if (pos == Gtk.EntryIconPosition.PRIMARY) {
            var prompt = "Select a directory to export to";
            var window = (this as Gtk.Widget).get_toplevel () as Gtk.Window;
            var dialog = new Gtk.FileChooserDialog (prompt,
                                                    window,
                                                    Gtk.FileChooserAction.OPEN,
                                                    "_Cancel",
                                                    Gtk.ResponseType.CANCEL,
                                                    "_Open",
                                                    Gtk.ResponseType.ACCEPT);
            dialog.modal = true;
            dialog.do_overwrite_confirmation = true;
            dialog.action = Gtk.FileChooserAction.SELECT_FOLDER;

            if (dialog.run () == Gtk.ResponseType.ACCEPT) {
                //entry_filepath.text = dialog.get_uri ();
                entry_filepath.text = dialog.get_current_folder ();
            }

            dialog.close ();
        } else if (pos == Gtk.EntryIconPosition.SECONDARY) {
            entry_filepath.text = "";
        }
    }

    [GtkCallback]
    private void entry_filename_icon_press_cb (Gtk.EntryIconPosition pos,
                                               Gdk.Event event) {
        if (pos == Gtk.EntryIconPosition.SECONDARY) {
            entry_filename.text = "";
        }
    }

    [GtkCallback]
    private void btn_export_clicked_cb () {
        export_filepath = entry_filepath.text;
        adj_step.changed ();
        single_header = btn_single_header.get_active ();

        if (!(export_filepath.has_suffix ("/")))
            export_filepath += "/";

        var filename = "%s%s".printf (export_filepath, export_filename);
        var output = true;

        if (FileUtils.test (filename, FileTest.EXISTS)) {
            var prompt = @"The file $filename exists.\nOverwrite?";
            var window = (this as Gtk.Widget).get_toplevel () as Gtk.Window;
            var dialog = new Gtk.MessageDialog (window,
                                                Gtk.DialogFlags.MODAL,
                                                Gtk.MessageType.WARNING,
                                                Gtk.ButtonsType.YES_NO,
                                                prompt);
            dialog.response.connect ((response_id) => {
                switch (response_id) {
                    case Gtk.ResponseType.YES:
                        output = true;
                        break;
                    case Gtk.ResponseType.NO:
                        output = false;
                        break;
                    case Gtk.ResponseType.DELETE_EVENT:
                        output = false;
                        break;
                }

                dialog.destroy();
            });

            dialog.modal = true;
            dialog.show ();
        }

        if (output) {
            (log as Cld.SqliteLog).export_csv (filename,
                                               int.parse (select_begin.id),
                                               int.parse (select_end.id),
                                               start,
                                               stop,
                                               step,
                                               single_header);
        }
    }
}
