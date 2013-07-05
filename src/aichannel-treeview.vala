using Cld;
using Gtk;
using Gee;

public class AIChannelTreeView : TreeView {

    public enum Columns {
        ID,
        NUM,
        TAG,
        DESCRIPTION,
        CALIBRATION,
        AVERAGE
    }

    private Map<string, Cld.Object> _channels;
    public Map<string, Cld.Object> channels {
        get { return _channels; }
        set { _channels = value; }
    }

    public AIChannelTreeView (Map<string, Cld.Object> channels) {
        this.channels = channels;
        create_treeview ();
    }

    private void create_treeview () {
        var listmodel = new ListStore (6, typeof (string),
                                          typeof (int),
                                          typeof (string),
                                          typeof (string),
                                          typeof (string),
                                          typeof (int));

        set_model (listmodel);
        insert_column_with_attributes (-1, "ID", new CellRendererText (), "text", Columns.ID);
        insert_column_with_attributes (-1, "Num", new CellRendererText (), "text", Columns.NUM);
        insert_column_with_attributes (-1, "Tag", new CellRendererText (), "text", Columns.TAG);
        insert_column_with_attributes (-1, "Description", new CellRendererText (), "text", Columns.DESCRIPTION);
        insert_column_with_attributes (-1, "Calibration", new CellRendererText (), "text", Columns.CALIBRATION);
        insert_column_with_attributes (-1, "Averaging", new CellRendererText (), "text", Columns.AVERAGE);

        TreeIter iter;
        foreach (var channel in channels.values) {
            listmodel.append (out iter);
            listmodel.set (iter, Columns.ID, channel.id,
                                 Columns.NUM, (channel as Channel).num,
                                 Columns.TAG, (channel as Channel).tag,
                                 Columns.DESCRIPTION, (channel as Channel).desc,
                                 Columns.CALIBRATION, (channel as ScalableChannel).calref,
                                 Columns.AVERAGE, (channel as AIChannel).raw_value_list_size);
        }

        set_rules_hint (true);
    }
}
