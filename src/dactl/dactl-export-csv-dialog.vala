using Gee;
using Gtk;

/**
 * The ExportCsvDialog class interfaces with an SQLite database.
 * It creates a subset of data from a single Log table. XXX Eventually
 * the time period chosen will span multiple Log tables.
 * over the chosen time perid. This data is saved to a CSV file.
 *
 */

[GtkTemplate (ui = "/org/coanda/dactl/ui/export_dialog.ui")]
public class Dactl.ExportCsvDialog : Gtk.Dialog {

    [GtkChild]
    private Gtk.ScrolledWindow scrolledwindow_experiment;

    [GtkChild]
    private Gtk.Calendar calendar_start;

    [GtkChild]
    private Gtk.Calendar calendar_stop;

    [GtkChild]
    private Gtk.SpinButton btn_start_hour;

    [GtkChild]
    private Gtk.SpinButton btn_start_minute;

    [GtkChild]
    private Gtk.SpinButton btn_start_second;

    [GtkChild]
    private Gtk.SpinButton btn_stop_hour;

    [GtkChild]
    private Gtk.SpinButton btn_stop_minute;

    [GtkChild]
    private Gtk.SpinButton btn_stop_second;

    [GtkChild]
    private Gtk.SpinButton btn_step;

    [GtkChild]
    private Gtk.Entry entry_filename;

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
    private Gtk.Adjustment adj_step;

    private Dactl.ApplicationModel model;
    private Cld.SqliteLog log;
    private Dactl.ExperimentTreeView experiment_treeview;
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

    public ExportCsvDialog (ApplicationModel model) {
        this.model = model;
        // find the SqliteLog if it exists
        log = new Cld.SqliteLog ();

        foreach (var object in model.ctx.objects.values) {
            if (object is Cld.SqliteLog) {
                log = object as Cld.SqliteLog;
            }
        }

        create_dialog ();
    }

    private void create_dialog () {
        title = "Export CSV";

        add_button (Gtk.Stock.APPLY, Gtk.ResponseType.APPLY);
        add_button (Gtk.Stock.OK, Gtk.ResponseType.OK);
        add_button (Gtk.Stock.CANCEL, Gtk.ResponseType.CANCEL);

        add_experiments_treeview ();
        connect_signals ();
        initialize_dialog ();
    }

    [GtkCallback]
    private void response_cb (Gtk.Dialog source, int id) {
        debug ("Response ID: %d\n", id);
        switch (id) {
            case Gtk.ResponseType.OK:
                debug ("OK\n");
                update_values ();
                update_filename ();
                debug ("filename: %s\n begin: %d end: %d step: %d",
                       export_filename,
                       int.parse (select_begin.id),
                       int.parse (select_end.id),
                       step);

                (log as Cld.SqliteLog).export_csv (export_filename,
                                                   int.parse (select_begin.id),
                                                   int.parse (select_end.id),
                                                   start,
                                                   stop,
                                                   step);
                hide ();
                break;
            case Gtk.ResponseType.CANCEL:
                debug ("Cancel\n");
                hide ();
                break;
            case Gtk.ResponseType.APPLY:
                debug ("Apply\n");
                update_values ();
                update_filename ();
                break;
           case Gtk.ResponseType.DELETE_EVENT:
                destroy ();
                debug ("destroyed");
                break;
        }
    }

    private void add_experiments_treeview () {
        /* XXX TBD should work with multiple log databases.*/
        experiment_treeview = new ExperimentTreeView (log);
        experiment_treeview.activate_on_single_click = true;
        selection = (experiment_treeview as Gtk.TreeView).get_selection ();
        selection.mode = Gtk.SelectionMode.MULTIPLE;
        TreePath treepath = new Gtk.TreePath.first ();
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
            debug ("%s || %s || %s ||  %s || %s ||  %s || %s",
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
            debug ("%s || %s || %s ||  %s || %s ||  %s || %s",
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

        start = new DateTime.local ((int) year,
                                    (int) month,
                                    (int) day,
                                    (int) hour,
                                    (int) minute,
                                    second);
        calendar_start.select_month (start.get_month () - 1, start.get_year());
        calendar_start.select_day (start.get_day_of_month ());
        btn_start_hour.set_value (start.get_hour ());
        btn_start_minute.set_value (start.get_minute ());
        btn_start_second.set_value (start.get_second ());

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

        stop = new DateTime.local ((int) year,
                                   (int) month,
                                   (int) day,
                                   (int) hour,
                                   (int) minute,
                                   second);

        calendar_stop.select_month (stop.get_month () - 1, stop.get_year ());
        calendar_stop.select_day (stop.get_day_of_month ());
        btn_stop_hour.set_value (stop.get_hour ());
        btn_stop_minute.set_value (stop.get_minute ());
        btn_stop_second.set_value (stop.get_second ());
    }

    private void update_values () {
        uint year, month, day;
        int hour, minute;
        double second;

        (calendar_start as Gtk.Calendar).get_date (out year, out month, out day);
        hour = (int) (adj_start_hour as Gtk.Adjustment).get_value ();
        minute = (int) (adj_start_minute as Gtk.Adjustment).get_value ();
        second = (adj_start_second as Gtk.Adjustment).get_value ();
        start = new DateTime.local ((int) year,
                                    (int) month + 1,
                                    (int) day,
                                    hour,
                                    minute,
                                    second);

        (calendar_stop as Gtk.Calendar).get_date (out year, out month, out day);
        hour = (int) (adj_stop_hour as Gtk.Adjustment).get_value ();
        minute = (int) (adj_stop_minute as Gtk.Adjustment).get_value ();
        second = (int) (adj_stop_second as Gtk.Adjustment).get_value ();
        stop = new DateTime.local ((int) year,
                                   (int) month + 1,
                                   (int) day,
                                   hour,
                                   minute,
                                   second);

        step = (int) (adj_step as Gtk.Adjustment).get_value ();
    }

    /**
     * Update the file name based on the selection.
     */
    private void update_filename () {
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

        //debug ("export filename: %s", export_filename);
        entry_filename.set_text (export_filename);
    }
}
