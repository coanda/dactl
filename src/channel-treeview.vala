using Cld;
using Gee;
using Gtk;

public class ChannelTreeView : TreeView {

    public enum Columns {
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
        var listmodel = new ListStore (5, typeof (string),
                                          typeof (string),
                                          typeof (string),
                                          typeof (string),
                                          typeof (string));

        set_model (listmodel);
        insert_column_with_attributes (-1, "Tag", new CellRendererText (), "text", Columns.TAG);
        insert_column_with_attributes (-1, "Value", new CellRendererText (), "text", Columns.VALUE);
        insert_column_with_attributes (-1, "Units", new CellRendererText (), "text", Columns.UNITS);
        insert_column_with_attributes (-1, "Description", new CellRendererText (), "text", Columns.DESCRIPTION);

        TreeIter iter;
        foreach (var channel in channels.values) {
            char[] buf = new char[double.DTOSTR_BUF_SIZE];
            string scaled_as_string;
            /* Just AI channels for now */
            if (channel is AIChannel) {
                var cal = (channel as AChannel).calibration;
                scaled_as_string = ((channel as AChannel).scaled_value).format (buf, "%.3f");
                message ("scaled_as_string: %s", scaled_as_string);
                listmodel.append (out iter);
                listmodel.set (iter, Columns.TAG, (channel as Channel).tag,
                                     Columns.VALUE, scaled_as_string, //(channel as AChannel).scaled_value,
                                     Columns.UNITS, (cal as Calibration).units,
                                     Columns.DESCRIPTION, (channel as Channel).desc,
                                     Columns.HIDDEN_ID, (channel as Cld.Object).id);
            } else if (channel is VChannel) {
                var cal = (channel as VChannel).calibration;
                scaled_as_string = ((channel as VChannel).scaled_value).format (buf, "%.3f");
                message ("scaled_as_string: %s", scaled_as_string);
                listmodel.append (out iter);
                listmodel.set (iter, Columns.TAG, (channel as Channel).tag,
                                     Columns.VALUE, scaled_as_string, //(channel as VChannel).scaled_value,
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
        char[] buf = new char[double.DTOSTR_BUF_SIZE];
        string value = "0.0";
        Cld.Object? cal = null;

        model.get (iter, Columns.HIDDEN_ID, out id);
        var channel = channels.get (id);
        if (channel is AChannel) {
            value = ((channel as AChannel).scaled_value).format (buf, "%.3f");
            cal = (channel as AChannel).calibration;
        } else if (channel is VChannel) {
            value = ((channel as VChannel).scaled_value).format (buf, "%.3f");
            cal = (channel as VChannel).calibration;
        }

        (model as ListStore).set (iter, Columns.VALUE, value,
                                        Columns.UNITS, (cal as Calibration).units,
                                        -1);

        return false;
    }
}
