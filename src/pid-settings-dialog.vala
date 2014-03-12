using Cld;
using Gee;
using Gtk;

public class PIDSettingsDialog : Dialog {

    private Cld.Pid _pid;
    public Cld.Pid pid {
        get { return _pid; }
        set { _pid = value; }
    }

    private Gtk.ComboBox input_combo;
    private Gtk.ComboBox output_combo;
    private Gtk.Adjustment adj_kp;
    private Gtk.Adjustment adj_ki;
    private Gtk.Adjustment adj_kd;
    private Gtk.Builder builder;
    private Gee.Map<string, Cld.Object> channels;

    construct {
        string path = GLib.Path.build_filename (Config.UI_DIR,
                                                "pid_dialog.ui");
        builder = new Gtk.Builder ();
        GLib.debug ("Loaded interface file: %s", path);

        try {
            builder.add_from_file (path);
        } catch (GLib.Error e) {
            var msg = new MessageDialog (null, DialogFlags.MODAL,
                                         MessageType.ERROR,
                                         ButtonsType.CANCEL,
                                         "Failed to load UI\n%s",
                                         e.message);
            msg.run ();
        }

        adj_kp = builder.get_object ("adj_kp") as Gtk.Adjustment;
        adj_ki = builder.get_object ("adj_ki") as Gtk.Adjustment;
        adj_kd = builder.get_object ("adj_kd") as Gtk.Adjustment;
    }

    public PIDSettingsDialog (Cld.Pid pid, Gee.Map<string, Cld.Object> channels) {
        this.pid = pid;
        this.channels = channels;

        create_dialog ();
        connect_signals ();
    }

    private void create_dialog () {
        var content = get_content_area ();
        var dialog = builder.get_object ("pid_dialog") as Gtk.Widget;
        var pv_box = builder.get_object ("process_vars_box") as Gtk.Widget;

        adj_kp.value = pid.kp;
        adj_ki.value = pid.ki;
        adj_kd.value = pid.kd;

        Gtk.ListStore input_store = new Gtk.ListStore (1, typeof (string));
        Gtk.ListStore output_store = new Gtk.ListStore (1, typeof (string));
        Gtk.TreeIter iter;

        foreach (var channel in channels.values) {
            if (channel is AIChannel) {
                input_store.append (out iter);
                input_store.set (iter, 0, channel.id);
            } else if (channel is AOChannel) {
                output_store.append (out iter);
                output_store.set (iter, 0, channel.id);
            }
        }

        input_combo = new ComboBox.with_model (input_store);
        Gtk.CellRendererText input_renderer = new Gtk.CellRendererText ();
        input_combo.pack_start (input_renderer, true);
        input_combo.add_attribute (input_renderer, "text", 0);
        input_combo.id_column = 0;
        input_combo.active_id = pid.pv_id;

        output_combo = new ComboBox.with_model (output_store);
        Gtk.CellRendererText output_renderer = new Gtk.CellRendererText ();
        output_combo.pack_start (output_renderer, true);
        output_combo.add_attribute (output_renderer, "text", 0);
        output_combo.id_column = 0;
        output_combo.active_id = pid.mv_id;
       GLib.debug ("Output: %s", pid.mv_id);

        (pv_box as Gtk.Box).pack_start (new Gtk.Label ("Input:"), true, false, 0);
        (pv_box as Gtk.Box).pack_start (input_combo, true, true, 0);
        (pv_box as Gtk.Box).pack_start (new Gtk.Label ("Output:"), true, false, 0);
        (pv_box as Gtk.Box).pack_start (output_combo, true, true, 0);
        pv_box.show_all ();

        var _content = (dialog as Dialog).get_content_area ();
        _content.reparent (content);

        title = "PID Settings";
        add_button (Stock.OK, ResponseType.OK);
        add_button (Stock.CANCEL, ResponseType.CANCEL);
    }

    private void connect_signals () {
        this.response.connect (response_cb);
    }

    private void response_cb (Dialog source, int response_id) {
        switch (response_id) {
            case ResponseType.OK:
                /* Update PID object */
                string pv_id = input_combo.active_id;
                Cld.debug ("Input selected:  %s", input_combo.active_id);
                string mv_id = output_combo.active_id;
                Cld.debug ("Output selected: %s", output_combo.active_id);
                Cld.Object pv_ch = channels.get (pv_id);
                Cld.Object mv_ch = channels.get (mv_id);
                Gee.Map<string, Cld.Object> process_values = new Gee.TreeMap<string, Cld.Object> ();
                var pv = new ProcessValue.full ("pv0", pv_ch as Cld.Channel);
                var mv = new ProcessValue.full ("pv1", mv_ch as Cld.Channel);
                process_values.set (pv.id, pv);
                process_values.set (mv.id, mv);
                pid.process_values = process_values;
                pid.print_process_values ();
                pid.kp = adj_kp.value;
                pid.ki = adj_ki.value;
                pid.kd = adj_kd.value;
                hide ();
                break;
            case ResponseType.CANCEL:
            case ResponseType.DELETE_EVENT:
                /* Probably want to track changes and inform user they will
                 * be lost if any were made */
                hide ();
                break;
        }
    }
}

public class PID2SettingsDialog : Dialog {

    private Cld.Pid2 _pid;
    public Cld.Pid2 pid {
        get { return _pid; }
        set { _pid = value; }
    }

    private Gtk.ComboBox input_combo;
    private Gtk.ComboBox output_combo;
    private Gtk.Adjustment adj_kp;
    private Gtk.Adjustment adj_ki;
    private Gtk.Adjustment adj_kd;
    private Gtk.Builder builder;
    private Gee.Map<string, Cld.Object> dataseries;

    construct {
        string path = GLib.Path.build_filename (Config.UI_DIR,
                                                "pid2_dialog.ui");
        builder = new Gtk.Builder ();
        GLib.debug ("Loaded interface file: %s", path);

        try {
            builder.add_from_file (path);
        } catch (GLib.Error e) {
            var msg = new MessageDialog (null, DialogFlags.MODAL,
                                         MessageType.ERROR,
                                         ButtonsType.CANCEL,
                                         "Failed to load UI\n%s",
                                         e.message);
            msg.run ();
        }

        adj_kp = builder.get_object ("adj_kp") as Gtk.Adjustment;
        adj_ki = builder.get_object ("adj_ki") as Gtk.Adjustment;
        adj_kd = builder.get_object ("adj_kd") as Gtk.Adjustment;
    }

    public PID2SettingsDialog (Cld.Pid2 pid, Gee.Map<string, Cld.Object> dataseries) {
        this.pid = pid;
        this.dataseries = dataseries;

        create_dialog ();
        connect_signals ();
    }

    private void create_dialog () {
        var content = get_content_area ();
        var dialog = builder.get_object ("pid_dialog") as Gtk.Widget;
        var pv_box = builder.get_object ("process_vars_box") as Gtk.Widget;

        adj_kp.value = pid.kp;
        adj_ki.value = pid.ki;
        adj_kd.value = pid.kd;

        Gtk.ListStore input_store = new Gtk.ListStore (1, typeof (string));
        Gtk.ListStore output_store = new Gtk.ListStore (1, typeof (string));
        Gtk.TreeIter iter;

        foreach (var ds in dataseries.values) {
            if (ds is DataSeries) {
                input_store.append (out iter);
                input_store.set (iter, 0, ds.id);
                output_store.append (out iter);
                output_store.set (iter, 0, ds.id);
            }
        }

        input_combo = new ComboBox.with_model (input_store);
        Gtk.CellRendererText input_renderer = new Gtk.CellRendererText ();
        input_combo.pack_start (input_renderer, true);
        input_combo.add_attribute (input_renderer, "text", 0);
        input_combo.id_column = 0;
        input_combo.active_id = pid.pv_id;

        output_combo = new ComboBox.with_model (output_store);
        Gtk.CellRendererText output_renderer = new Gtk.CellRendererText ();
        output_combo.pack_start (output_renderer, true);
        output_combo.add_attribute (output_renderer, "text", 0);
        output_combo.id_column = 0;
        output_combo.active_id = pid.mv_id;
        GLib.debug ("Output: %s", pid.mv_id);

        (pv_box as Gtk.Box).pack_start (new Gtk.Label ("Input:"), true, false, 0);
        (pv_box as Gtk.Box).pack_start (input_combo, true, true, 0);
        (pv_box as Gtk.Box).pack_start (new Gtk.Label ("Output:"), true, false, 0);
        (pv_box as Gtk.Box).pack_start (output_combo, true, true, 0);
        pv_box.show_all ();
        /* XXX The pv_box is not working with DataSeries yet so it is made insensitive for now. */
        (pv_box as Gtk.Widget).set_sensitive (true);

        var _content = (dialog as Dialog).get_content_area ();
        _content.reparent (content);

        title = "PID Settings";
        add_button (Stock.OK, ResponseType.OK);
        add_button (Stock.CANCEL, ResponseType.CANCEL);
    }

    private void connect_signals () {
        this.response.connect (response_cb);
    }

    private void response_cb (Dialog source, int response_id) {
        switch (response_id) {
            case ResponseType.OK:
                /* Update PID object */
                string pv_id = input_combo.active_id;
                Cld.debug ("Input selected:  %s", input_combo.active_id);
                string mv_id = output_combo.active_id;
                Cld.debug ("Output selected: %s", output_combo.active_id);
                Cld.Object pv_ds = dataseries.get (pv_id);
                Cld.Object mv_ds = dataseries.get (mv_id);
                Gee.Map<string, Cld.Object> process_values = new Gee.TreeMap<string, Cld.Object> ();
                var pv = new ProcessValue2.full ("pv0", pv_ds as Cld.DataSeries);
                var mv = new ProcessValue2.full ("pv1", mv_ds as Cld.DataSeries);
                process_values.set (pv.id, pv);
                process_values.set (mv.id, mv);
                pid.process_values = process_values;
                pid.print_process_values ();
                pid.kp = adj_kp.value;
                pid.ki = adj_ki.value;
                pid.kd = adj_kd.value;
                Cld.debug ("pid.id: %s kp: %.3f ki: %.3f kd: %.3f", pid.id, pid.kp, pid.ki, pid.kd);
                hide ();
                break;
            case ResponseType.CANCEL:
            case ResponseType.DELETE_EVENT:
                /* Probably want to track changes and inform user they will
                 * be lost if any were made */
                hide ();
                break;
        }
    }
}
