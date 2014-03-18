using Cld;
using Gtk;
using Gee;

public class CoefficientTreeView : TreeView {

    public enum Columns {
        ID,
        N,
        VALUE
    }

    private Map<string, Cld.Object> _coefficients;
    public Map<string, Cld.Object> coefficients {
        get { return _coefficients; }
        set { _coefficients = value; }
    }

    public signal void change_confirmed (string coefficient_id, double value);

    public CoefficientTreeView (Map<string, Cld.Object> coefficients) {
        this.coefficients = coefficients;
        create_treeview ();
    }

    private void create_treeview () {
        var listmodel = new ListStore (3, typeof (string),
                                          typeof (int),
                                          typeof (double));

        set_model (listmodel);
        insert_column_with_attributes (-1, "ID", new CellRendererText (), "text", Columns.ID);
        insert_column_with_attributes (-1, "Number", new CellRendererText (), "text", Columns.N);
        var value_cell = new CellRendererText ();
        value_cell.editable = true;
        insert_column_with_attributes (-1, "Value", value_cell, "text", Columns.VALUE);

        /* Callback here for now */
        value_cell.edited.connect (value_cell_edited_cb);

        TreeIter iter;
        foreach (var coefficient in coefficients.values) {
            listmodel.append (out iter);
            listmodel.set (iter, Columns.ID, coefficient.id,
                                 Columns.N, (coefficient as Coefficient).n,
                                 Columns.VALUE, (coefficient as Coefficient).value);
        }

        set_rules_hint (true);
    }

    private void value_cell_edited_cb (string path_string, string new_text) {
        Gtk.TreeModel model = this.model;
        Gtk.TreePath path = new Gtk.TreePath.from_string (path_string);
        Gtk.TreeIter iter;
        string id;

        model.get_iter (out iter, path);
        model.get (iter, Columns.ID, out id);
        (model as Gtk.ListStore).set (iter, Columns.VALUE, double.parse (new_text));

        /* Fire signal to tell parent to deal with changes */
        change_confirmed (id, double.parse (new_text));
    }
}
