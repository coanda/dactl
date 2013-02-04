using Cld;
using Gtk;
using Gee;

public class CalibrationTreeView : TreeView {

    private Map<string, Cld.Object> _calibrations;
    public Map<string, Cld.Object> calibrations {
        get { return _calibrations; }
        set { _calibrations = value; }
    }

    public CalibrationTreeView (Map<string, Cld.Object> calibrations) {
        this.calibrations = calibrations;
        create_treeview ();
    }

    private void create_treeview () {
        var listmodel = new ListStore (2, typeof (string),
                                          typeof (string));

        set_model (listmodel);
        insert_column_with_attributes (-1, "ID", new CellRendererText (), "text", 0);
        insert_column_with_attributes (-1, "Units", new CellRendererText (), "text", 1);

        TreeIter iter;
        foreach (var calibration in calibrations.values) {
            listmodel.append (out iter);
            listmodel.set (iter, 0, calibration.id,
                                 1, (calibration as Calibration).units);
        }

        set_rules_hint (true);
    }
}
