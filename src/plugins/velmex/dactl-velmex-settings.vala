[GtkTemplate (ui = "/org/coanda/dactl/plugins/velmex/velmex-settings.ui")]
public class Dactl.Velmex.Settings : Gtk.Window {

    [GtkChild]
    private Gtk.TextBuffer textbuffer_traverse;

    [GtkChild]
    private Gtk.Entry entry_device;

    [GtkChild]
    private Gtk.CheckButton btn_show_advanced;

    [GtkChild]
    private Gtk.Revealer revealer_advanced;

    [GtkChild]
    private Gtk.ComboBox combo_baudrate;

    [GtkChild]
    private Gtk.ComboBox combo_data_bits;

    [GtkChild]
    private Gtk.ComboBox combo_stop_bits;

    [GtkChild]
    private Gtk.ComboBox combo_parity;

    [GtkChild]
    private Gtk.ComboBox combo_handshake;

    [GtkChild]
    private Gtk.ComboBox combo_access_mode;

    [GtkChild]
    private Gtk.ListStore liststore_baudrate;

    [GtkChild]
    private Gtk.ListStore liststore_data_bits;

    [GtkChild]
    private Gtk.ListStore liststore_stop_bits;

    [GtkChild]
    private Gtk.ListStore liststore_parity;

    [GtkChild]
    private Gtk.ListStore liststore_handshake;

    [GtkChild]
    private Gtk.ListStore liststore_access_mode;

    [GtkChild]
    private Gtk.Switch switch_echo;

    private Cld.VelmexModule module;

    construct {
        revealer_advanced.set_reveal_child (false);
        revealer_advanced.transition_type = Gtk.RevealerTransitionType.SLIDE_DOWN;
        revealer_advanced.transition_duration = 400;
    }

    public Settings (Cld.VelmexModule module) {
        this.module = module;
        textbuffer_traverse.text = this.module.program.strip ();

        load_port_settings ();
    }

    private void load_port_settings () {
        var port = this.module.port as Cld.SerialPort;

        entry_device.text = port.device;
        switch_echo.active = port.echo;

        Gtk.TreeModelForeachFunc select_baudrate = (model, path, iter) => {
            GLib.Value cell;
            liststore_baudrate.get_value (iter, 0, out cell);
            /* The serial port baud rate gets mapped to a Linux/Posix enum */
            var tmp_port = new Cld.SerialPort ();
            tmp_port.baud_rate = (int)cell;
            if (port.baud_rate == tmp_port.baud_rate)
                combo_baudrate.set_active_iter (iter);

            return false;
        };

        Gtk.TreeModelForeachFunc select_data_bits = (model, path, iter) => {
            GLib.Value cell;
            liststore_data_bits.get_value (iter, 0, out cell);
            if (port.data_bits == (int)cell)
                combo_data_bits.set_active_iter (iter);

            return false;
        };

        Gtk.TreeModelForeachFunc select_stop_bits = (model, path, iter) => {
            GLib.Value cell;
            liststore_stop_bits.get_value (iter, 0, out cell);
            if (port.stop_bits == (int)cell)
                combo_stop_bits.set_active_iter (iter);

            return false;
        };

        liststore_baudrate.foreach (select_baudrate);
        liststore_data_bits.foreach (select_data_bits);
        liststore_stop_bits.foreach (select_stop_bits);

        populate_parity ();
        populate_handshake ();
        populate_access_mode ();
    }

    private void populate_parity () {
        Gtk.TreeIter iter;
        var port = this.module.port as Cld.SerialPort;

        foreach (var parity in Cld.SerialPort.Parity.all ()) {
            liststore_parity.append (out iter);
            liststore_parity.set (iter, 0, parity.to_string ());
            if (port.parity == parity)
                combo_parity.set_active_iter (iter);
        }
    }

    private void populate_handshake () {
        Gtk.TreeIter iter;
        var port = this.module.port as Cld.SerialPort;

        foreach (var handshake in Cld.SerialPort.Handshake.all ()) {
            liststore_handshake.append (out iter);
            liststore_handshake.set (iter, 0, handshake.to_string ());
            if (port.handshake == handshake)
                combo_handshake.set_active_iter (iter);
        }
    }

    private void populate_access_mode () {
        Gtk.TreeIter iter;
        var port = this.module.port as Cld.SerialPort;

        foreach (var access_mode in Cld.SerialPort.AccessMode.all ()) {
            liststore_access_mode.append (out iter);
            liststore_access_mode.set (iter, 0, access_mode.to_string ());
            if (port.access_mode == access_mode)
                combo_access_mode.set_active_iter (iter);
        }
    }

    [GtkCallback]
    private void btn_show_advanced_toggled_cb () {
        revealer_advanced.set_reveal_child (btn_show_advanced.active);
    }

    [GtkCallback]
    private void btn_ok_clicked_cb () {
        /* Save module program */
        Gtk.TextIter start, end;
        textbuffer_traverse.get_bounds (out start, out end);
        var program = textbuffer_traverse.get_text (start, end, false).strip ();
        program += "\r";
        module.program = program;
        module.store_program ();

        /* Save port settings */
        Gtk.TreeIter iter;
        GLib.Value val;
        var port = this.module.port as Cld.SerialPort;

        port.device = entry_device.text;
        port.echo = switch_echo.active;

        combo_baudrate.get_active_iter (out iter);
        liststore_baudrate.get_value (iter, 0, out val);
        port.baud_rate = (int)val;

        combo_data_bits.get_active_iter (out iter);
        liststore_data_bits.get_value (iter, 0, out val);
        port.data_bits = (int)val;

        combo_stop_bits.get_active_iter (out iter);
        liststore_stop_bits.get_value (iter, 0, out val);
        port.stop_bits = (int)val;

        combo_parity.get_active_iter (out iter);
        liststore_parity.get_value (iter, 0, out val);
        port.parity = Cld.SerialPort.Parity.parse ((string)val);

        combo_handshake.get_active_iter (out iter);
        liststore_handshake.get_value (iter, 0, out val);
        port.handshake = Cld.SerialPort.Handshake.parse ((string)val);

        combo_access_mode.get_active_iter (out iter);
        liststore_access_mode.get_value (iter, 0, out val);
        port.access_mode = Cld.SerialPort.AccessMode.parse ((string)val);

        close ();
    }

    [GtkCallback]
    private void btn_cancel_clicked_cb () {
        close ();
    }
}
