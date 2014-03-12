using Cld;
using Gee;
using Gtk;

/**
 * The ExportCsvDialog class interfaces with an SQLite database.
 * It creates a subset of data from a single Log table. XXX Eventually
 * the time period chosen will span multiple Log tables.
 * over the chosen time perid. This data is saved to a CSV file.
 *
 */

public class ExportCsvDialog : Dialog {

    private ApplicationModel model;
    private Gtk.Builder builder;
    private GLib.Object scrolledwindow_experiment;
    private GLib.Object btn_apply;
    private GLib.Object btn_ok;
    private GLib.Object btn_cancel;
    private GLib.Object calendar_start;
    private GLib.Object calendar_stop;
    private GLib.Object btn_start_hour;
    private GLib.Object btn_start_minute;
    private GLib.Object btn_start_second;
    private GLib.Object btn_stop_hour;
    private GLib.Object btn_stop_minute;
    private GLib.Object btn_stop_second;
    private GLib.Object btn_step;
    private GLib.Object adj_start_hour;
    private GLib.Object adj_start_minute;
    private GLib.Object adj_start_second;
    private GLib.Object adj_stop_hour;
    private GLib.Object adj_stop_minute;
    private GLib.Object adj_stop_second;
    private GLib.Object adj_step;
    private Cld.SqliteLog log;
    private ExperimentTreeView experiment_treeview;
    private Gtk.TreeSelection selection;
    private DateTime start;
    private DateTime stop;
    private string export_filename;
    private int step;
    /* A data struct of an experiment treeview selection */
    struct ExperimentSelection {
        public string id;
        public string name;
        public string start_date;
        public string stop_date;
        public string start_time;
        public string stop_time;
        public string log_rate;
    }


    /* A ExperimentSelections for this dialog */
    private ExperimentSelection select_begin;
    private ExperimentSelection select_end;

    construct {
        string path = GLib.Path.build_filename (Config.UI_DIR,
                                                "export_dialog.ui");
        builder = new Gtk.Builder ();
        GLib.debug ("Loaded interface file: %s", path);

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

    public ExportCsvDialog (ApplicationModel model) {
        this.model = model;
        // find the SqliteLog if it exists
        log = new Cld.SqliteLog ();
        foreach (var object in model.ctx.objects.values) {
            if (object is Cld.SqliteLog) {
                log = object as SqliteLog;
            }
        }

        create_dialog ();
        show_all ();
    }

    private void create_dialog () {
        var content = get_content_area ();
        var action = get_action_area ();
        var dialog = builder.get_object ("export_dialog");

        /* Load everything */

        var _content = (dialog as Dialog).get_content_area ();
        _content.reparent (content);
        var _action = (dialog as Dialog).get_action_area ();
        _action.reparent (action);
        title = "Export CSV";

        btn_apply = add_button (Stock.APPLY, ResponseType.APPLY);
        btn_ok = add_button (Stock.OK, ResponseType.OK);
        btn_cancel = add_button (Stock.CANCEL, ResponseType.CANCEL);

        scrolledwindow_experiment = builder.get_object ("scrolledwindow_experiment") ;
        calendar_start = builder.get_object ("calendar_start") ;
        calendar_stop = builder.get_object ("calendar_stop") ;
        btn_start_hour = builder.get_object ("btn_start_hour") ;
        btn_start_minute = builder.get_object ("btn_start_minute") ;
        btn_start_second = builder.get_object ("btn_start_second") ;
        btn_stop_hour = builder.get_object ("btn_stop_hour") ;
        btn_stop_minute = builder.get_object ("btn_stop_minute") ;
        btn_stop_second = builder.get_object ("btn_stop_second") ;
        btn_step = builder.get_object ("btn_step") ;
        adj_start_hour = builder.get_object ("adj_start_hour") ;
        adj_start_minute = builder.get_object ("adj_start_minute") ;
        adj_start_second = builder.get_object ("adj_start_second") ;
        adj_stop_hour = builder.get_object ("adj_stop_hour") ;
        adj_stop_minute = builder.get_object ("adj_stop_minute") ;
        adj_stop_second = builder.get_object ("adj_stop_second") ;
        adj_step = builder.get_object ("adj_step");

        add_experiments_treeview ();
        connect_signals ();
        initialize_dialog ();
        action.show_all ();
        content.show_all ();
    }

    public void response_cb (Dialog source, int response_id) {
        Cld.debug ("Response ID: %d\n", response_id);
        switch (response_id) {
            case ResponseType.OK:
                Cld.debug ("OK\n");
                update_values ();
                update_filename ();
                Cld.debug ("filename: %s\n begin: %d end: %d step: %d",
                          export_filename,
                          int.parse (select_begin.id),
                          int.parse (select_end.id),
                          step
                          );

                (log as Cld.SqliteLog).export_csv (
                                                  export_filename,
                                                  int.parse (select_begin.id),
                                                  int.parse (select_end.id),
                                                  start,
                                                  stop,
                                                  step
                                                  );
                hide ();
                break;
            case ResponseType.CANCEL:
                Cld.debug ("Cancel\n");
                hide ();
                break;
            case ResponseType.APPLY:
                Cld.debug ("Apply\n");
                update_values ();
                update_filename ();
                break;
           case ResponseType.DELETE_EVENT:
                destroy ();
                Cld.debug ("destroyed");
                break;
        }
    }

    private void add_experiments_treeview () {
        /* XXX TBD should work with multiple log databases.*/
        experiment_treeview = new ExperimentTreeView (log);
        experiment_treeview.activate_on_single_click = true;
        selection = (experiment_treeview as Gtk.TreeView).get_selection ();
        selection.mode = Gtk.SelectionMode.MULTIPLE;
        TreePath treepath = new TreePath.first ();
        (experiment_treeview as TreeView).set_cursor (treepath, null, false);
        (scrolledwindow_experiment as ScrolledWindow).add (experiment_treeview);
    }

    private void connect_signals () {
        (selection as TreeSelection).changed.connect (() => {
            TreeModel tm;
            TreeIter iter;
            GLib.List<Gtk.TreePath> path_list;
            unowned GLib.List<Gtk.TreePath>? path;

            path_list = selection.get_selected_rows (out tm);
            /* Get beginning table information */
            path = path_list.first ();
            tm.get_iter (out iter, path.data);
            tm.get (iter, ExperimentTreeView.Columns.ID, out select_begin.id);
            tm.get (iter, ExperimentTreeView.Columns.NAME, out select_begin.name);
            tm.get (iter, ExperimentTreeView.Columns.START_DATE, out select_begin.start_date);
            tm.get (iter, ExperimentTreeView.Columns.STOP_DATE, out select_begin.stop_date);
            tm.get (iter, ExperimentTreeView.Columns.START_TIME, out select_begin.start_time);
            tm.get (iter, ExperimentTreeView.Columns.STOP_TIME, out select_begin.stop_time);
            tm.get (iter, ExperimentTreeView.Columns.LOG_RATE, out select_begin.log_rate);
            Cld.debug ("%s || %s || %s ||  %s || %s ||  %s || %s",
                select_begin.id, select_begin.name, select_begin.start_date, select_begin.stop_date,
                select_begin.start_time, select_begin.stop_time, select_begin.log_rate);
            /* Get ending table information */
            path = path_list.last ();
            tm.get_iter (out iter, path.data);
            tm.get (iter, ExperimentTreeView.Columns.ID, out select_end.id);
            tm.get (iter, ExperimentTreeView.Columns.NAME, out select_end.name);
            tm.get (iter, ExperimentTreeView.Columns.START_DATE, out select_end.start_date);
            tm.get (iter, ExperimentTreeView.Columns.STOP_DATE, out select_end.stop_date);
            tm.get (iter, ExperimentTreeView.Columns.START_TIME, out select_end.start_time);
            tm.get (iter, ExperimentTreeView.Columns.STOP_TIME, out select_end.stop_time);
            tm.get (iter, ExperimentTreeView.Columns.LOG_RATE, out select_end.log_rate);
            Cld.debug ("%s || %s || %s ||  %s || %s ||  %s || %s",
                select_end.id, select_end.name, select_end.start_date, select_end.stop_date,
                select_end.start_time, select_end.stop_time, select_end.log_rate);
            update_time ();
            update_values ();
            update_filename ();
        });
    }

    private void initialize_dialog () {
        (experiment_treeview as TreeView).cursor_changed ();
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
        start = new DateTime.local (
                                   (int) year,
                                   (int) month,
                                   (int) day,
                                   (int) hour,
                                   (int) minute,
                                   second
                                   );
        (calendar_start as Gtk.Calendar).select_month (start.get_month () - 1, start.get_year());
        (calendar_start as Gtk.Calendar).select_day (start.get_day_of_month ());
        (btn_start_hour as Gtk.SpinButton).set_value (start.get_hour ());
        (btn_start_minute as Gtk.SpinButton).set_value (start.get_minute ());
        (btn_start_second as Gtk.SpinButton).set_value (start.get_second ());

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
        stop = new DateTime.local (
                                  (int) year,
                                  (int) month,
                                  (int) day,
                                  (int) hour,
                                  (int) minute,
                                  second
                                  );

        (calendar_stop as Gtk.Calendar).select_month (stop.get_month () - 1, stop.get_year ());
        (calendar_stop as Gtk.Calendar).select_day (stop.get_day_of_month ());
        (btn_stop_hour as Gtk.SpinButton).set_value (stop.get_hour ());
        (btn_stop_minute as Gtk.SpinButton).set_value (stop.get_minute ());
        (btn_stop_second as Gtk.SpinButton).set_value (stop.get_second ());
    }

    private void update_values () {
        uint year, month, day;
        int hour, minute;
        double second;

        (calendar_start as Gtk.Calendar).get_date (out year, out month, out day);
        hour = (int) (adj_start_hour as Gtk.Adjustment).get_value ();
        minute = (int) (adj_start_minute as Gtk.Adjustment).get_value ();
        second = (adj_start_second as Gtk.Adjustment).get_value ();
        start = new DateTime.local (
                                   (int) year,
                                   (int) month + 1,
                                   (int) day,
                                   hour,
                                   minute,
                                   second
                                   );

        (calendar_stop as Gtk.Calendar).get_date (out year, out month, out day);
        hour = (int) (adj_stop_hour as Gtk.Adjustment).get_value ();
        minute = (int) (adj_stop_minute as Gtk.Adjustment).get_value ();
        second = (int) (adj_stop_second as Gtk.Adjustment).get_value ();
        stop = new DateTime.local (
                                   (int) year,
                                   (int) month + 1,
                                   (int) day,
                                   hour,
                                   minute,
                                   second
                                   );

        step = (int) (adj_step as Gtk.Adjustment).get_value ();
    }

    /**
     * Update the file name based on the selection.
     */
    private void update_filename () {
        var entry_filename = builder.get_object ("entry_filename");
        export_filename = (log as Cld.Log).path;
        if (!(export_filename.has_suffix ("/"))) {
            export_filename = "%s%s".printf ((log as Cld.Log).path, "/");
        }
        export_filename = "%s%s%s%s%s%s%s".printf (
                                 export_filename,
                                 (log as Cld.Log).file.replace (".","_"),
                                 "_",
                                 start.to_string (),
                                 "_",
                                 stop.to_string (),
                                 ".csv"
                                 );
        //Cld.debug ("export filename: %s", export_filename);
        (entry_filename as Gtk.Entry).set_text (export_filename);
    }
}
