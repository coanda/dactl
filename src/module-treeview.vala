using Cld;
using Gtk;
using Gee;

public class ModuleTreeView : TreeView {

    public enum Columns {
        ID,
        LOADED,
        PORT
    }

    private Map<string, Cld.Object> _modules;
    public Map<string, Cld.Object> modules {
        get { return _modules; }
        set { _modules = value; }
    }

    public ModuleTreeView (Map<string, Cld.Object> modules) {
        this.modules = modules;
        create_treeview ();
    }

    private void create_treeview () {
        var listmodel = new ListStore (3, typeof (string),
                                          typeof (bool),
                                          typeof (string));
        set_model (listmodel);
        insert_column_with_attributes (-1, "ID", new CellRendererText (), "text", Columns.ID);
        insert_column_with_attributes (-1, "Loaded", new CellRendererText (), "text", Columns.LOADED);
        insert_column_with_attributes (-1, "Port", new CellRendererText (), "text", Columns.PORT);

        TreeIter iter;
        foreach (var module in modules.values) {
            listmodel.append (out iter);
            listmodel.set (iter, Columns.ID, module.id,
                                 Columns.LOADED, (module as Module).loaded,
                                 Columns.PORT, (module as Module).portref);
        }

        set_rules_hint (true);
    }
}

