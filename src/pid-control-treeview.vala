using Cld;
using Gtk;
using Gee;

public class PIDControlTreeView : TreeView {

    private Map<string, Cld.Object> _pid_controls;
    public Map<string, Cld.Object> pid_controls {
        get { return _pid_controls; }
        set { _pid_controls = value; }
    }

    public PIDControlTreeView (Map<string, Cld.Object> pid_controls) {
        this.pid_controls = pid_controls;
        create_treeview ();
    }

    private void create_treeview () {
        var listmodel = new ListStore (8, typeof (string),
                                          typeof (int),
                                          typeof (double),
                                          typeof (double),
                                          typeof (double),
                                          typeof (string),
                                          typeof (string),
                                          typeof (string));

        set_model (listmodel);
        insert_column_with_attributes (-1, "ID", new CellRendererText (), "text", 0);
        insert_column_with_attributes (-1, "dt", new CellRendererText (), "text", 1);
        insert_column_with_attributes (-1, "Kp", new CellRendererText (), "text", 2);
        insert_column_with_attributes (-1, "Ki", new CellRendererText (), "text", 3);
        insert_column_with_attributes (-1, "Kd", new CellRendererText (), "text", 4);
        insert_column_with_attributes (-1, "PV", new CellRendererText (), "text", 5);
        insert_column_with_attributes (-1, "MV", new CellRendererText (), "text", 6);
        insert_column_with_attributes (-1, "Description", new CellRendererText (), "text", 7);

        TreeIter iter;
        foreach (var pid in pid_controls.values) {
            listmodel.append (out iter);
            listmodel.set (iter, 0, pid.id,
                                 1, (pid as Cld.Pid).dt,
                                 2, (pid as Cld.Pid).kp,
                                 3, (pid as Cld.Pid).ki,
                                 4, (pid as Cld.Pid).kd,
                                 5, (pid as Cld.Pid).pv_id,
                                 6, (pid as Cld.Pid).mv_id,
                                 7, (pid as Cld.Pid).desc);
        }

        set_rules_hint (true);
    }
}
