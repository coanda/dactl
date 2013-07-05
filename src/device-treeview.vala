using Cld;
using Gtk;
using Gee;

public class DeviceTreeView : TreeView {

    public enum Columns {
        ID,
        DESC,
        FILE
    }

    private Map<string, Cld.Object> _devices;
    public Map<string, Cld.Object> devices {
        get { return _devices; }
        set { _devices = value; }
    }

    public DeviceTreeView (Map<string, Cld.Object> devices) {
        this.devices = devices;
        create_treeview ();
    }

    private void create_treeview () {
        var listmodel = new ListStore (3/*5*/, typeof (string),
                                          typeof (string),
        //                                  typeof (string),
        //                                  typeof (string),
                                          typeof (string));

        set_model (listmodel);
        insert_column_with_attributes (-1, "ID", new CellRendererText (), "text", Columns.ID);
        insert_column_with_attributes (-1, "Name", new CellRendererText (), "text", Columns.DESC);
        //insert_column_with_attributes (-1, "Driver", new CellRendererText (), "text", Columns.DRIVER);
        //insert_column_with_attributes (-1, "Hardware", new CellRendererText (), "text", Columns.HARDWARE);
        insert_column_with_attributes (-1, "File", new CellRendererText (), "text", Columns.FILE);

        TreeIter iter;
        foreach (var device in devices.values) {
            //DeviceType dev_type = ((device as Device).driver as DeviceType);
            //HardwareType hw_type = ((device as Device).hw_type as HardwareType);
            listmodel.append (out iter);
            listmodel.set (iter, Columns.ID, device.id,
                                 Columns.DESC, (device as Device).description,
                                 //Columns.DRIVER, dev_type.to_string (),
                                 //Columns.HARDWARE, hw_type.to_string (),
                                 Columns.FILE, (device as Device).filename);
        }

        set_rules_hint (true);
    }
}
