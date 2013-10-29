using Cld;
using Gee;
using Gtk;
using Linux;
using Posix;

public class SerialPortSettingsBox : Gtk.Box {

    private Gtk.Builder builder;
    private Gtk.Widget serial_port_settings_box;
    private Gtk.Widget lbl_id;
    private Gtk.Widget lbl_connected;
    private Gtk.Widget entry_device;
    private Gtk.Widget cb_parity;
    private Gtk.Widget cb_handshake;
    private Gtk.Widget cb_access_mode;
    private Gtk.Widget cb_baud_rate;
    private Gtk.Widget cb_data_bits;
    private Gtk.Widget cb_stop_bits;
    private Gtk.Widget cb_echo;
    private Cld.SerialPort port;
    /* Temporary variables with values that are transferred to the port when an update is done */
    private Cld.SerialPort.Parity parity;
    private Cld.SerialPort.Handshake handshake;
    private Cld.SerialPort.AccessMode access_mode;
    private int baud_rate;
    private int data_bits;
    private int stop_bits;
    private bool echo;
    /**/
    private int[] baudrates = { 300,
                                600,
                                1200,
                                2400,
                                4800,
                                9600,
                                19200,
                                38400,
                                57600,
                                115200,
                                230400,
                                460800,
                                576000,
                                921600,
                                1000000,
                                2000000
    };
    private SerialPort.Parity [] parity_all;
    private SerialPort.Handshake [] handshake_all;
    private SerialPort.AccessMode [] access_mode_all;
    private Gtk.ListStore parity_store = new Gtk.ListStore (1, typeof (string));
    private Gtk.ListStore handshake_store = new Gtk.ListStore (1, typeof (string));
    private Gtk.ListStore access_mode_store = new Gtk.ListStore (1, typeof (string));
    private Gtk.ListStore baudrate_store = new Gtk.ListStore (1, typeof (int));
    private Gtk.ListStore data_bits_store = new Gtk.ListStore (1, typeof (int));
    private Gtk.ListStore stop_bits_store = new Gtk.ListStore (1, typeof (int));
    private Gtk.ListStore echo_store = new Gtk.ListStore (1, typeof (bool));

    construct {
        string path = GLib.Path.build_filename (Config.DATADIR,
                                                "serial_port_settings_box.ui");
        builder = new Gtk.Builder ();
        Cld.debug ("Loaded interface file: %s\n", path);

        try {
            builder.add_from_file (path);
            serial_port_settings_box = builder.get_object ("serial_port_settings_box") as Gtk.Widget;
            lbl_id = builder.get_object ("lbl_id") as Gtk.Widget;
            lbl_connected = builder.get_object ("lbl_connected") as Gtk.Widget;
            entry_device = builder.get_object ("entry_device") as Gtk.Widget;
            cb_parity = builder.get_object ("cb_parity") as Gtk.Widget;
            cb_handshake = builder.get_object ("cb_handshake") as Gtk.Widget;
            cb_access_mode = builder.get_object ("cb_access_mode") as Gtk.Widget;
            cb_baud_rate = builder.get_object ("cb_baud_rate") as Gtk.Widget;
            cb_data_bits = builder.get_object ("cb_data_bits") as Gtk.Widget;
            cb_stop_bits = builder.get_object ("cb_stop_bits") as Gtk.Widget;
            cb_echo = builder.get_object ("cb_echo") as Gtk.Widget;

        } catch (GLib.Error e) {
            var msg = new MessageDialog (null, DialogFlags.MODAL,
                                         MessageType.ERROR,
                                         ButtonsType.CANCEL,
                                         "Failed to load UI\n%s",
                                         e.message);
            msg.run ();
        }
    }

    public SerialPortSettingsBox (Cld.SerialPort port) {
        this.port = port;

        (lbl_id as Label).set_text (port.id);
        (lbl_connected as Label).set_text (port.connected.to_string ());
        (entry_device as Gtk.Entry).set_text (port.device);
        populate_parity_box ();
        populate_handshake_box ();
        populate_access_mode_box ();
        populate_baud_rate_box ();
        populate_data_bits_box ();
        populate_stop_bits_box ();
        populate_echo_box ();
        connect_signals ();
        pack_start (serial_port_settings_box);
        show_all ();
    }

    private void populate_parity_box () {
        Gtk.TreeIter iter;
        int j = 0;

        parity_all = SerialPort.Parity.all ();
        for (int i = 0; i < parity_all.length; i++) {
            if (port.parity == i) {
                j = i;
            }
            parity_store.append (out iter);
            parity_store.set (iter, 0, parity_all[i].to_string ());
        }

        (cb_parity as ComboBox).set_model (parity_store);
        Gtk.CellRendererText renderer_parity = new Gtk.CellRendererText ();
        (cb_parity as ComboBox).pack_start (renderer_parity, true);
        (cb_parity as ComboBox).add_attribute (renderer_parity, "text", 0);
        (cb_parity as ComboBox).active = j;
    }

    private void populate_handshake_box () {
        Gtk.TreeIter iter;
        int j = 0;

        handshake_all = SerialPort.Handshake.all ();
        for (int i = 0; i < handshake_all.length; i++) {
            if (port.handshake == i) {
                j = i;
            }
            handshake_store.append (out iter);
            handshake_store.set (iter, 0, handshake_all[i].to_string ());
        }

        (cb_handshake as ComboBox).set_model (handshake_store);
        Gtk.CellRendererText renderer_handshake = new Gtk.CellRendererText ();
        (cb_handshake as ComboBox).pack_start (renderer_handshake, true);
        (cb_handshake as ComboBox).add_attribute (renderer_handshake, "text", 0);
        (cb_handshake as ComboBox).active = j;
    }

    private void populate_access_mode_box () {
        Gtk.TreeIter iter;
        int j = 0;

        access_mode_all = SerialPort.AccessMode.all ();
        for (int i = 0; i < parity_all.length; i++) {
            if (port.parity == i) {
                j = i;
            }
            access_mode_store.append (out iter);
            access_mode_store.set (iter, 0, access_mode_all[i].to_string ());
        }

        (cb_access_mode as ComboBox).set_model (access_mode_store);
        Gtk.CellRendererText renderer_access_mode = new Gtk.CellRendererText ();
        (cb_access_mode as ComboBox).pack_start (renderer_access_mode, true);
        (cb_access_mode as ComboBox).add_attribute (renderer_access_mode, "text", 0);
        (cb_access_mode as ComboBox).active = j;
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

        (cb_baud_rate as ComboBox).set_model (baudrate_store);
        Gtk.CellRendererText renderer_baud = new Gtk.CellRendererText ();
        (cb_baud_rate as ComboBox).pack_start (renderer_baud, true);
        (cb_baud_rate as ComboBox).add_attribute (renderer_baud, "text", 0);
        (cb_baud_rate as ComboBox).active = j;
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

        (cb_data_bits as ComboBox).set_model (data_bits_store);
        Gtk.CellRendererText renderer_data_bits = new Gtk.CellRendererText ();
        (cb_data_bits as ComboBox).pack_start (renderer_data_bits, true);
        (cb_data_bits as ComboBox).add_attribute (renderer_data_bits, "text", 0);
        (cb_data_bits as ComboBox).active = j;
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

        (cb_stop_bits as ComboBox).set_model (stop_bits_store);
        Gtk.CellRendererText renderer_stop_bits = new Gtk.CellRendererText ();
        (cb_stop_bits as ComboBox).pack_start (renderer_stop_bits, true);
        (cb_stop_bits as ComboBox).add_attribute (renderer_stop_bits, "text", 0);
        (cb_stop_bits as ComboBox).active = j;
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

        (cb_echo as ComboBox).set_model (echo_store);
        Gtk.CellRendererText renderer_echo = new Gtk.CellRendererText ();
        (cb_echo as ComboBox).pack_start (renderer_echo, true);
        (cb_echo as ComboBox).add_attribute (renderer_echo, "text", 0);
        (cb_echo as ComboBox).active = j;
    }

    private void connect_signals () {
        /* Parity */
        (cb_parity as Gtk.ComboBox).changed.connect (() => {
            Gtk.TreeIter iter;
            Value val;

            (cb_parity as Gtk.ComboBox).get_active_iter (out iter);
            parity_store.get_value (iter, 0, out val);
            parity = SerialPort.Parity.parse ((string) val);
            Cld.debug ("get_value (): %s parity: %d\n", (string) val, parity);
        });
        /* Handshake */
        (cb_handshake as Gtk.ComboBox).changed.connect (() => {
            Gtk.TreeIter iter;
            Value val;

            (cb_handshake as Gtk.ComboBox).get_active_iter (out iter);
            handshake_store.get_value (iter, 0, out val);
            handshake = SerialPort.Handshake.parse ((string) val);
            Cld.debug ("get_value (): %s handshake: %d\n", (string) val, handshake);
        });
        /* Access Mode */
        (cb_access_mode as Gtk.ComboBox).changed.connect (() => {
            Gtk.TreeIter iter;
            Value val;

            (cb_access_mode as Gtk.ComboBox).get_active_iter (out iter);
            access_mode_store.get_value (iter, 0, out val);
            access_mode = SerialPort.AccessMode.parse ((string) val);
            Cld.debug ("get_value (): %s access_mode: %d\n", (string) val, access_mode);

        });
        /* Baud Rate */
        (cb_baud_rate as Gtk.ComboBox).changed.connect (() => {
            Gtk.TreeIter iter;
            Value val;

            (cb_baud_rate as Gtk.ComboBox).get_active_iter (out iter);
            baudrate_store.get_value (iter, 0, out val);
            Cld.debug ("Baud rate selection: %d\n", (int) val);
            baud_rate = (int) val;
        });
        /* Data Bits */
        (cb_data_bits as Gtk.ComboBox).changed.connect (() => {
            Gtk.TreeIter iter;
            Value val;

            (cb_data_bits as Gtk.ComboBox).get_active_iter (out iter);
            data_bits_store.get_value (iter, 0, out val);
            Cld.debug ("Data bits selection: %d\n", (int) val);
            data_bits =  (int) val;
        });
        /* Stop Bits */
        (cb_stop_bits as Gtk.ComboBox).changed.connect (() => {
            Gtk.TreeIter iter;
            Value val;

            (cb_stop_bits as Gtk.ComboBox).get_active_iter (out iter);
            stop_bits_store.get_value (iter, 0, out val);
            Cld.debug ("Stop bits selection: %d\n", (int) val);
            stop_bits = (int) val;
        });
        /* Echo */
        (cb_echo as Gtk.ComboBox).changed.connect (() => {
            Gtk.TreeIter iter;
            Value val;

            (cb_echo as Gtk.ComboBox).get_active_iter (out iter);
            echo_store.get_value (iter, 0, out val);
            Cld.debug ("Echo selection: %s\n", ((bool) val).to_string ());
            echo = (bool) val;
        });
    }

    public void update () {
        port.device = (entry_device as Gtk.Entry).get_text ();
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
                case Posix.B300:
                    return 300;
                case Posix.B600:
                    return 600;
                case Posix.B1200:
                    return 1200;
                case Posix.B2400:
                    return 2400;
                case Posix.B4800:
                    return 4800;
                case Posix.B9600:
                    return 9600;
                case Posix.B19200:
                    return 19200;
                case Posix.B38400:
                    return 38400;
                case Posix.B57600:
                    return 57600;
                case Posix.B115200:
                    return 115200;
                case Posix.B230400:
                    return 230400;
                case Linux.Termios.B460800:
                    return 460800;
                case Linux.Termios.B576000:
                    return 576000;
                case Linux.Termios.B921600:
                    return 921600;
                case Linux.Termios.B1000000:
                    return 1000000;
                case Linux.Termios.B2000000:
                    return 2000000;
                default:
                    return 9600;
            }
    }
}
