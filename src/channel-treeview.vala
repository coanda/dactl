using Cld;
using Gee;
using Gtk;

public class ChannelTreeView : TreeView {

    public enum Columns {
        NUM,
        TAG,
        VALUE,
        UNITS,
        DESCRIPTION,
        HIDDEN_ID
    }

    private Map<string, Cld.Object> _channels;
    public Map<string, Cld.Object> channels {
        get { return _channels; }
        set { _channels = value; }
    }

    public ChannelTreeView (Map<string, Cld.Object> channels) {
        this.channels = channels;
        create_treeview ();
        Timeout.add (1000, update);
    }

    private void create_treeview () {
        var listmodel = new ListStore (6, typeof (int),
                                          typeof (string),
                                          typeof (double),
                                          typeof (string),
                                          typeof (string),
                                          typeof (string));

        set_model (listmodel);
        insert_column_with_attributes (-1, "Num", new CellRendererText (), "text", Columns.NUM);
        insert_column_with_attributes (-1, "Tag", new CellRendererText (), "text", Columns.TAG);
        insert_column_with_attributes (-1, "Value", new CellRendererText (), "text", Columns.VALUE);
        insert_column_with_attributes (-1, "Units", new CellRendererText (), "text", Columns.UNITS);
        insert_column_with_attributes (-1, "Description", new CellRendererText (), "text", Columns.DESCRIPTION);

        TreeIter iter;
        foreach (var channel in channels.values) {
            /* Just AI channels for now */
            if (channel is AIChannel) {
                var cal = (channel as AChannel).calibration;
                listmodel.append (out iter);
                listmodel.set (iter, Columns.NUM, (channel as Channel).num,
                                     Columns.TAG, (channel as Channel).tag,
                                     Columns.VALUE, (channel as AChannel).scaled_value,
                                     Columns.UNITS, (cal as Calibration).units,
                                     Columns.DESCRIPTION, (channel as Channel).desc,
                                     Columns.HIDDEN_ID, (channel as Cld.Object).id);
            } else if (channel is VChannel) {
                var cal = (channel as VChannel).calibration;
                listmodel.append (out iter);
                listmodel.set (iter, Columns.NUM, (channel as Channel).num,
                                     Columns.TAG, (channel as Channel).tag,
                                     Columns.VALUE, (channel as VChannel).scaled_value,
                                     Columns.UNITS, (cal as Calibration).units,
                                     Columns.DESCRIPTION, (channel as Channel).desc,
                                     Columns.HIDDEN_ID, (channel as Cld.Object).id);
            }
        }

        set_rules_hint (true);
    }

    private bool update () {
        TreeModel model = get_model ();
        model.foreach (update_row);
        return true;
    }

    private bool update_row (TreeModel model, TreePath path, TreeIter iter) {
        string id;
        double value = 0.0;
        Cld.Object? cal = null;

        model.get (iter, Columns.HIDDEN_ID, out id);
        var channel = channels.get (id);
        if (channel is AChannel) {
            value = (channel as AChannel).scaled_value;
            cal = (channel as AChannel).calibration;
        } else if (channel is VChannel) {
            value = (channel as VChannel).scaled_value;
            cal = (channel as VChannel).calibration;
        }

        (model as ListStore).set (iter, Columns.VALUE, value,
                                        Columns.UNITS, (cal as Calibration).units,
                                        -1);

        return false;
    }
}
