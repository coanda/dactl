[GtkTemplate (ui = "/org/coanda/dactl/ui/pid_dialog.ui")]
public class Dactl.PIDSettingsDialog : Gtk.Dialog {

    [GtkChild]
    private Gtk.Adjustment adj_kp;

    [GtkChild]
    private Gtk.Adjustment adj_ki;

    [GtkChild]
    private Gtk.Adjustment adj_kd;

    [GtkChild]
    private Gtk.Box process_vars_box;

    private Gtk.ComboBox input_combo;

    private Gtk.ComboBox output_combo;

    private Gee.Map<string, Cld.Object> channels;

    private Cld.Pid _pid;

    public Cld.Pid pid {
        get { return _pid; }
        set { _pid = value; }
    }

    public PIDSettingsDialog (Cld.Pid pid, Gee.Map<string, Cld.Object> channels) {
        this.pid = pid;
        this.channels = channels;

        create_dialog ();
    }

    private void create_dialog () {

        adj_kp.value = pid.kp;
        adj_ki.value = pid.ki;
        adj_kd.value = pid.kd;

        Gtk.ListStore input_store = new Gtk.ListStore (1, typeof (string));
        Gtk.ListStore output_store = new Gtk.ListStore (1, typeof (string));
        Gtk.TreeIter iter;

        foreach (var channel in channels.values) {
            if (channel is Cld.AIChannel) {
                input_store.append (out iter);
                input_store.set (iter, 0, channel.id);
            } else if (channel is Cld.AOChannel) {
                output_store.append (out iter);
                output_store.set (iter, 0, channel.id);
            }
        }

        input_combo = new Gtk.ComboBox.with_model (input_store);
        Gtk.CellRendererText input_renderer = new Gtk.CellRendererText ();

        input_combo.pack_start (input_renderer, true);
        input_combo.add_attribute (input_renderer, "text", 0);
        input_combo.id_column = 0;
        input_combo.active_id = pid.pv_id;
        debug ("Input: %s", pid.pv_id);

        output_combo = new Gtk.ComboBox.with_model (output_store);
        Gtk.CellRendererText output_renderer = new Gtk.CellRendererText ();

        output_combo.pack_start (output_renderer, true);
        output_combo.add_attribute (output_renderer, "text", 0);
        output_combo.id_column = 0;
        output_combo.active_id = pid.mv_id;
        debug ("Output: %s", pid.mv_id);

        process_vars_box.pack_start (new Gtk.Label ("Input:"), true, false, 0);
        process_vars_box.pack_start (input_combo, true, true, 0);
        process_vars_box.pack_start (new Gtk.Label ("Output:"), true, false, 0);
        process_vars_box.pack_start (output_combo, true, true, 0);

        process_vars_box.show_all ();

        title = "PID Settings";
        add_button (Gtk.Stock.OK, Gtk.ResponseType.OK);
        add_button (Gtk.Stock.CANCEL, Gtk.ResponseType.CANCEL);
    }

    [GtkCallback]
    private void response_cb (Gtk.Dialog source, int response_id) {
        switch (response_id) {
            case Gtk.ResponseType.OK:
                /* Update PID object */
                string pv_id = input_combo.active_id;
                string mv_id = output_combo.active_id;

                debug ("Input selected:  %s", input_combo.active_id);
                debug ("Output selected: %s", output_combo.active_id);

                Cld.Object pv_ch = channels.get (pv_id);
                Cld.Object mv_ch = channels.get (mv_id);
                Gee.Map<string, Cld.Object> process_values = new Gee.TreeMap<string, Cld.Object> ();

                var pv = new Cld.ProcessValue.full ("pv0", pv_ch as Cld.Channel);
                var mv = new Cld.ProcessValue.full ("pv1", mv_ch as Cld.Channel);

                process_values.set (pv.id, pv);
                process_values.set (mv.id, mv);
                pid.process_values = process_values;
                pid.print_process_values ();
                pid.kp = adj_kp.value;
                pid.ki = adj_ki.value;
                pid.kd = adj_kd.value;

                hide ();
                break;
            case Gtk.ResponseType.CANCEL:
            case Gtk.ResponseType.DELETE_EVENT:
                /* Probably want to track changes and inform user they will
                 * be lost if any were made */
                hide ();
                break;
        }
    }
}

[GtkTemplate (ui = "/org/coanda/dactl/ui/pid2_dialog.ui")]
public class Dactl.PID2SettingsDialog : Gtk.Dialog {

    [GtkChild]
    private Gtk.Adjustment adj_kp;

    [GtkChild]
    private Gtk.Adjustment adj_ki;

    [GtkChild]
    private Gtk.Adjustment adj_kd;

    [GtkChild]
    private Gtk.Box process_vars_box;

    private Gtk.ComboBox input_combo;

    private Gtk.ComboBox output_combo;

    private Gee.Map<string, Cld.Object> dataseries;

    private Cld.Pid2 _pid;

    public Cld.Pid2 pid {
        get { return _pid; }
        set { _pid = value; }
    }

    public PID2SettingsDialog (Cld.Pid2 pid, Gee.Map<string, Cld.Object> dataseries) {
        this.pid = pid;
        this.dataseries = dataseries;

        create_dialog ();
    }

    private void create_dialog () {

        adj_kp.value = pid.kp;
        adj_ki.value = pid.ki;
        adj_kd.value = pid.kd;

        Gtk.ListStore input_store = new Gtk.ListStore (1, typeof (string));
        Gtk.ListStore output_store = new Gtk.ListStore (1, typeof (string));
        Gtk.TreeIter iter;

        foreach (var ds in dataseries.values) {
            if (ds is Cld.DataSeries) {
                input_store.append (out iter);
                input_store.set (iter, 0, ds.id);
                output_store.append (out iter);
                output_store.set (iter, 0, ds.id);
            }
        }

        input_combo = new Gtk.ComboBox.with_model (input_store);
        Gtk.CellRendererText input_renderer = new Gtk.CellRendererText ();
        input_combo.pack_start (input_renderer, true);
        input_combo.add_attribute (input_renderer, "text", 0);
        input_combo.id_column = 0;
        input_combo.active_id = pid.pv_id;

        output_combo = new Gtk.ComboBox.with_model (output_store);
        Gtk.CellRendererText output_renderer = new Gtk.CellRendererText ();
        output_combo.pack_start (output_renderer, true);
        output_combo.add_attribute (output_renderer, "text", 0);
        output_combo.id_column = 0;
        output_combo.active_id = pid.mv_id;
        debug ("Output: %s", pid.mv_id);

        process_vars_box.pack_start (new Gtk.Label ("Input:"), true, false, 0);
        process_vars_box.pack_start (input_combo, true, true, 0);
        process_vars_box.pack_start (new Gtk.Label ("Output:"), true, false, 0);
        process_vars_box.pack_start (output_combo, true, true, 0);
        process_vars_box.show_all ();

        /* XXX The process_vars_box is not working with DataSeries yet so it is made insensitive for now. */
        (process_vars_box as Gtk.Widget).set_sensitive (true);

        title = "PID Settings";
        add_button (Gtk.Stock.OK, Gtk.ResponseType.OK);
        add_button (Gtk.Stock.CANCEL, Gtk.ResponseType.CANCEL);
    }

    [GtkCallback]
    private void response_cb (Gtk.Dialog source, int response_id) {
        switch (response_id) {
            case Gtk.ResponseType.OK:
                /* Update PID object */
                string pv_id = input_combo.active_id;
                string mv_id = output_combo.active_id;

                debug ("Input selected:  %s", input_combo.active_id);
                debug ("Output selected: %s", output_combo.active_id);

                Cld.Object pv_ds = dataseries.get (pv_id);
                Cld.Object mv_ds = dataseries.get (mv_id);
                Gee.Map<string, Cld.Object> process_values = new Gee.TreeMap<string, Cld.Object> ();

                var pv = new Cld.ProcessValue2.full ("pv0", pv_ds as Cld.DataSeries);
                var mv = new Cld.ProcessValue2.full ("pv1", mv_ds as Cld.DataSeries);

                process_values.set (pv.id, pv);
                process_values.set (mv.id, mv);
                pid.process_values = process_values;
                pid.print_process_values ();
                pid.kp = adj_kp.value;
                pid.ki = adj_ki.value;
                pid.kd = adj_kd.value;

                debug ("pid.id: %s kp: %.3f ki: %.3f kd: %.3f", pid.id, pid.kp, pid.ki, pid.kd);
                hide ();
                break;
            case Gtk.ResponseType.CANCEL:
            case Gtk.ResponseType.DELETE_EVENT:
                /* Probably want to track changes and inform user they will
                 * be lost if any were made */
                hide ();
                break;
        }
    }
}
