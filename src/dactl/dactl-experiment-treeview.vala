using Cld;
using Gee;
using Gtk;

public class Dactl.ExperimentTreeView : Gtk.TreeView {

    public enum Columns {
        ID,
        NAME,
        START_DATE,
        STOP_DATE,
        START_TIME,
        STOP_TIME,
        LOG_RATE
    }

    private Gee.ArrayList<Cld.ExperimentEntry?> _experiments;
    public Gee.ArrayList<Cld.ExperimentEntry?> experiments {
        get { return _experiments; }
        set { _experiments = value; }
    }

    private Cld.Log _log;
    public Cld.Log log {
        get { return _log; }
        set { _log = value; }
    }

    private TreeIter iter_a;
    private TreeIter iter_b;
    private Gtk.ListStore listmodel;

    public ExperimentTreeView (Cld.Log log) {
        this.log = log;
        experiments = (log as SqliteLog).get_experiment_entries ();
        create_treeview ();
    }

    private void create_treeview () {
        listmodel = new ListStore (7, typeof (string),
                                          typeof (string),
                                          typeof (string),
                                          typeof (string),
                                          typeof (string),
                                          typeof (string),
                                          typeof (string));

        set_model (listmodel);

        insert_column_with_attributes (-1, "ID", new CellRendererText (), "text", Columns.ID);
        insert_column_with_attributes (-1, "Name", new CellRendererText (), "text", Columns.NAME);
        insert_column_with_attributes (-1, "Start Date", new CellRendererText (), "text", Columns.START_DATE);
        insert_column_with_attributes (-1, "Stop Date", new CellRendererText (), "text", Columns.STOP_DATE);
        insert_column_with_attributes (-1, "Start Time", new CellRendererText (), "text", Columns.START_TIME);
        insert_column_with_attributes (-1, "Stop Time", new CellRendererText (), "text", Columns.STOP_TIME);
        insert_column_with_attributes (-1, "Log Rate", new CellRendererText (), "text", Columns.LOG_RATE);

        (listmodel as Gtk.TreeSortable).set_sort_column_id (Columns.ID, SortType.ASCENDING);
        (listmodel as Gtk.TreeSortable).set_sort_func (Columns.ID, compare_int);

        foreach (var ex in experiments) {
            Cld.debug ("create_treeview (): %s", ex.name);
            TreeIter iter;
            listmodel.append (out iter);
            listmodel.set (iter, Columns.ID, ex.id.to_string (),
                                 Columns.NAME, ex.name,
                                 Columns.START_DATE, ex.start_date,
                                 Columns.STOP_DATE, ex.stop_date,
                                 Columns.START_TIME, ex.start_time,
                                 Columns.STOP_TIME, ex.stop_time,
                                 Columns.LOG_RATE, ex.log_rate.to_string ()
                                 );
        }
        set_rules_hint (true);
    }

    private int compare_int (TreeModel model, TreeIter iter_a, TreeIter iter_b) {
        int sort_column_id;
        int order;
        Value a_str;
        Value b_str;

        (listmodel as Gtk.TreeSortable).get_sort_column_id (out sort_column_id, out order);
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
}

