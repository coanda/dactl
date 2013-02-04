using Cld;
using Gtk;
using Gee;

public class LogTreeView : TreeView {

    public enum Columns {
        ID,
        NAME,
        PATH,
        FILE,
        RATE,
        FORMAT
    }

    private Map<string, Cld.Object> _logs;
    public Map<string, Cld.Object> logs {
        get { return _logs; }
        set { _logs = value; }
    }

    public LogTreeView (Map<string, Cld.Object> logs) {
        this.logs = logs;
        create_treeview ();
    }

    private void create_treeview () {
        var listmodel = new ListStore (6, typeof (string),
                                          typeof (string),
                                          typeof (string),
                                          typeof (string),
                                          typeof (double),
                                          typeof (string));

        set_model (listmodel);
        insert_column_with_attributes (-1, "ID", new CellRendererText (), "text", Columns.ID);
        insert_column_with_attributes (-1, "Name", new CellRendererText (), "text", Columns.NAME);
        insert_column_with_attributes (-1, "Path", new CellRendererText (), "text", Columns.RATE);
        insert_column_with_attributes (-1, "File", new CellRendererText (), "text", Columns.FILE);
        insert_column_with_attributes (-1, "Rate", new CellRendererText (), "text", Columns.RATE);
        insert_column_with_attributes (-1, "Date Format", new CellRendererText (), "text", Columns.FORMAT);

        TreeIter iter;
        foreach (var log in logs.values) {
            listmodel.append (out iter);
            listmodel.set (iter, Columns.ID, log.id,
                                 Columns.NAME, (log as Cld.Log).name,
                                 Columns.PATH, (log as Cld.Log).path,
                                 Columns.FILE, (log as Cld.Log).file,
                                 Columns.RATE, (log as Cld.Log).rate,
                                 Columns.FORMAT, (log as Cld.Log).date_format);
        }

        set_rules_hint (true);
    }
}
