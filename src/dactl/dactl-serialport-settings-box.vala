[GtkTemplate (ui = "/org/coanda/dactl/ui/serial-port-settings-box.ui")]
public class Dactl.SerialPortSettingsBox : Gtk.Box {

    [GtkChild]
    private Gtk.Label lbl_id;

    [GtkChild]
    private Gtk.Label lbl_connected;

    [GtkChild]
    private Gtk.Entry entry_device;

    [GtkChild]
    private Gtk.ComboBox cb_parity;

    [GtkChild]
    private Gtk.ComboBox cb_handshake;

    [GtkChild]
    private Gtk.ComboBox cb_access_mode;

    [GtkChild]
    private Gtk.ComboBox cb_baud_rate;

    [GtkChild]
    private Gtk.ComboBox cb_data_bits;

    [GtkChild]
    private Gtk.ComboBox cb_stop_bits;

    [GtkChild]
    private Gtk.ComboBox cb_echo;

    private Cld.SerialPort port;

    /* Temp variables that are transferred to the port when update is done */
    private Cld.SerialPort.Parity parity;
    private Cld.SerialPort.Handshake handshake;
    private Cld.SerialPort.AccessMode access_mode;

    private uint baud_rate;
    private int data_bits;
    private int stop_bits;
    private bool echo;

    private int[] baudrates = {
        300, 600, 1200, 2400, 4800, 9600, 19200, 38400, 57600,
        115200, 230400, 460800, 576000, 921600, 1000000, 2000000
    };

    private Cld.SerialPort.Parity [] parity_all;
    private Cld.SerialPort.Handshake [] handshake_all;
    private Cld.SerialPort.AccessMode [] access_mode_all;

    private Gtk.ListStore parity_store = new Gtk.ListStore (1, typeof (string));
    private Gtk.ListStore handshake_store = new Gtk.ListStore (1, typeof (string));
    private Gtk.ListStore access_mode_store = new Gtk.ListStore (1, typeof (string));
    private Gtk.ListStore baudrate_store = new Gtk.ListStore (1, typeof (int));
    private Gtk.ListStore data_bits_store = new Gtk.ListStore (1, typeof (int));
    private Gtk.ListStore stop_bits_store = new Gtk.ListStore (1, typeof (int));
    private Gtk.ListStore echo_store = new Gtk.ListStore (1, typeof (bool));

    public SerialPortSettingsBox (Cld.SerialPort port) {
        this.port = port;

        lbl_id.set_text ((port as Cld.Object).id);
        lbl_connected.set_text ((port as Cld.Port).connected.to_string ());
        entry_device.set_text (port.device);

        parity = port.parity;
        handshake = port.handshake;
        access_mode = port.access_mode;
        baud_rate = port.baud_rate;
        data_bits = port.data_bits;
        stop_bits = port.stop_bits;
        echo = port.echo;

        populate_parity_box ();
        populate_handshake_box ();
        populate_access_mode_box ();
        populate_baud_rate_box ();
        populate_data_bits_box ();
        populate_stop_bits_box ();
        populate_echo_box ();

        connect_signals ();
    }

    private void populate_parity_box () {
        Gtk.TreeIter iter;
        int j = 0;

        parity_all = Cld.SerialPort.Parity.all ();
        for (int i = 0; i < parity_all.length; i++) {
            if (port.parity == i) {
                j = i;
            }
            parity_store.append (out iter);
            parity_store.set (iter, 0, parity_all[i].to_string ());
        }

        cb_parity.set_model (parity_store);
        Gtk.CellRendererText renderer_parity = new Gtk.CellRendererText ();
        cb_parity.pack_start (renderer_parity, true);
        cb_parity.add_attribute (renderer_parity, "text", 0);
        cb_parity.active = j;
    }

    private void populate_handshake_box () {
        Gtk.TreeIter iter;
        int j = 0;

        handshake_all = Cld.SerialPort.Handshake.all ();
        for (int i = 0; i < handshake_all.length; i++) {
            if (port.handshake == i) {
                j = i;
            }
            handshake_store.append (out iter);
            handshake_store.set (iter, 0, handshake_all[i].to_string ());
        }

        cb_handshake.set_model (handshake_store);
        Gtk.CellRendererText renderer_handshake = new Gtk.CellRendererText ();
        cb_handshake.pack_start (renderer_handshake, true);
        cb_handshake.add_attribute (renderer_handshake, "text", 0);
        cb_handshake.active = j;
    }

    private void populate_access_mode_box () {
        Gtk.TreeIter iter;
        int j = 0;

        access_mode_all = Cld.SerialPort.AccessMode.all ();
        for (int i = 0; i < parity_all.length; i++) {
            if (port.parity == i) {
                j = i;
            }
            access_mode_store.append (out iter);
            access_mode_store.set (iter, 0, access_mode_all[i].to_string ());
        }

        cb_access_mode.set_model (access_mode_store);
        Gtk.CellRendererText renderer_access_mode = new Gtk.CellRendererText ();
        cb_access_mode.pack_start (renderer_access_mode, true);
        cb_access_mode.add_attribute (renderer_access_mode, "text", 0);
        cb_access_mode.active = j;
    }

    private void populate_baud_rate_box () {
        Gtk.TreeIter iter;
        int j = 0;

        baud_rate = get_baud_rate ();
        for (int i = 0; i < baudrates.length; i++) {
            if (baudrates [i] == baud_rate) {
                j = i;
            }
            baudrate_store.append (out iter);
            baudrate_store.set (iter, 0, baudrates[i], -1);
        }

        cb_baud_rate.set_model (baudrate_store);
        Gtk.CellRendererText renderer_baud = new Gtk.CellRendererText ();
        cb_baud_rate.pack_start (renderer_baud, true);
        cb_baud_rate.add_attribute (renderer_baud, "text", 0);
        cb_baud_rate.active = j;
    }

    private void populate_data_bits_box () {
        Gtk.TreeIter iter;
        int min = 5;
        int max = 8;
        int j = 0;

        for (int i = 0; i < (max - min) + 1; i++) {
            if (i == port.data_bits - min) {
                j = i;
            }
            data_bits_store.append (out iter);
            data_bits_store.set (iter, 0, i + min, -1);
        }

        cb_data_bits.set_model (data_bits_store);
        Gtk.CellRendererText renderer_data_bits = new Gtk.CellRendererText ();
        cb_data_bits.pack_start (renderer_data_bits, true);
        cb_data_bits.add_attribute (renderer_data_bits, "text", 0);
        cb_data_bits.active = j;
    }

    private void populate_stop_bits_box () {
        Gtk.TreeIter iter;
        int min = 0;
        int max = 1;
        int j = 0;

        for (int i = 0; i < (max - min) + 1; i++) {
            if (i == port.stop_bits - min) {
                j = i;
            }
            stop_bits_store.append (out iter);
            stop_bits_store.set (iter, 0, i + min, -1);
        }

        cb_stop_bits.set_model (stop_bits_store);
        Gtk.CellRendererText renderer_stop_bits = new Gtk.CellRendererText ();
        cb_stop_bits.pack_start (renderer_stop_bits, true);
        cb_stop_bits.add_attribute (renderer_stop_bits, "text", 0);
        cb_stop_bits.active = j;
    }

    private void populate_echo_box () {
        Gtk.TreeIter iter;
        int j = 0;

        for (int i = 0; i <= 1; i++) {
            echo_store.append (out iter);
            if (port.echo) {
                j = 1;
            } else {
                j = 0;
            }
            if (i == 0)
                echo_store.set (iter, 0, false);
            if (i == 1)
                echo_store.set (iter, 0, true);
        }

        var renderer_echo = new Gtk.CellRendererText ();

        cb_echo.set_model (echo_store);
        cb_echo.pack_start (renderer_echo, true);
        cb_echo.add_attribute (renderer_echo, "text", 0);
        cb_echo.active = j;
    }

    private void connect_signals () {
        /* Parity */
        (cb_parity as Gtk.ComboBox).changed.connect (() => {
            Gtk.TreeIter iter;
            Value val;

            (cb_parity as Gtk.ComboBox).get_active_iter (out iter);
            parity_store.get_value (iter, 0, out val);
            parity = Cld.SerialPort.Parity.parse ((string) val);
            debug ("get_value (): %s parity: %d\n", (string) val, parity);
        });

        /* Handshake */
        (cb_handshake as Gtk.ComboBox).changed.connect (() => {
            Gtk.TreeIter iter;
            Value val;

            (cb_handshake as Gtk.ComboBox).get_active_iter (out iter);
            handshake_store.get_value (iter, 0, out val);
            handshake = Cld.SerialPort.Handshake.parse ((string) val);
            debug ("get_value (): %s handshake: %d\n", (string) val, handshake);
        });

        /* Access Mode */
        (cb_access_mode as Gtk.ComboBox).changed.connect (() => {
            Gtk.TreeIter iter;
            Value val;

            (cb_access_mode as Gtk.ComboBox).get_active_iter (out iter);
            access_mode_store.get_value (iter, 0, out val);
            access_mode = Cld.SerialPort.AccessMode.parse ((string) val);
            debug ("get_value (): %s access_mode: %d\n", (string) val, access_mode);

        });

        /* Baud Rate */
        (cb_baud_rate as Gtk.ComboBox).changed.connect (() => {
            Gtk.TreeIter iter;
            Value val;

            (cb_baud_rate as Gtk.ComboBox).get_active_iter (out iter);
            baudrate_store.get_value (iter, 0, out val);
            debug ("Baud rate selection: %d\n", (int) val);
            baud_rate = (int) val;
        });

        /* Data Bits */
        (cb_data_bits as Gtk.ComboBox).changed.connect (() => {
            Gtk.TreeIter iter;
            Value val;

            (cb_data_bits as Gtk.ComboBox).get_active_iter (out iter);
            data_bits_store.get_value (iter, 0, out val);
            debug ("Data bits selection: %d\n", (int) val);
            data_bits =  (int) val;
        });

        /* Stop Bits */
        (cb_stop_bits as Gtk.ComboBox).changed.connect (() => {
            Gtk.TreeIter iter;
            Value val;

            (cb_stop_bits as Gtk.ComboBox).get_active_iter (out iter);
            stop_bits_store.get_value (iter, 0, out val);
            debug ("Stop bits selection: %d\n", (int) val);
            stop_bits = (int) val;
        });

        /* Echo */
        (cb_echo as Gtk.ComboBox).changed.connect (() => {
            Gtk.TreeIter iter;
            Value val;

            (cb_echo as Gtk.ComboBox).get_active_iter (out iter);
            echo_store.get_value (iter, 0, out val);
            debug ("Echo selection: %s\n", ((bool) val).to_string ());
            echo = (bool) val;
        });
    }

    public void update () {
        port.device = entry_device.get_text ();
        port.parity = parity;
        port.handshake = handshake;
        port.access_mode = access_mode;
        port.baud_rate = baud_rate;
        port.data_bits = data_bits;
        port.stop_bits = stop_bits;
        port.echo = echo;
        port.settings_changed (); // Emit this signal to cause port settings to take effect.
    }

    private int get_baud_rate () {
        switch (port.baud_rate) {
            case Posix.B300:             return 300;
            case Posix.B600:             return 600;
            case Posix.B1200:            return 1200;
            case Posix.B2400:            return 2400;
            case Posix.B4800:            return 4800;
            case Posix.B9600:            return 9600;
            case Posix.B19200:           return 19200;
            case Posix.B38400:           return 38400;
            case Posix.B57600:           return 57600;
            case Posix.B115200:          return 115200;
            case Posix.B230400:          return 230400;
            case Linux.Termios.B460800:  return 460800;
            case Linux.Termios.B576000:  return 576000;
            case Linux.Termios.B921600:  return 921600;
            case Linux.Termios.B1000000: return 1000000;
            case Linux.Termios.B2000000: return 2000000;
            default:                     return 9600;
        }
    }
}
