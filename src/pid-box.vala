using Cld;
using Gee;
using Gtk;

public class PIDBox : Gtk.Box {

    private ApplicationData data;

    private Cld.Pid pid;
    private Cld.Pid.Thread pid_thread;
//    private Cld.Pid _pid;
//    public Cld.Pid pid {
//        get { return _pid; }
//        set { _pid = value; }
//    }

    public string pid_id { get; set; }

    private Dialog _settings_dialog;
    public Dialog settings_dialog {
        get { return _settings_dialog; }
        set { _settings_dialog = value; }
    }

    private Adjustment manual_adjustment;
    private Adjustment sp_adjustment;
    private Scale manual_scale;
    private SpinButton manual_spin_button;
    private SpinButton sp_spin_button;
    private Button pid_enable;
    private Button pid_settings;

    /* Thread for control loop execution */
    private unowned GLib.Thread<void *> thread;

    //public PIDBox (Cld.Pid pid) {
    public PIDBox (string pid_id, ApplicationData data) {
        GLib.Object (orientation: Orientation.HORIZONTAL);
        spacing = 10;
        //this.pid = pid;
        this.pid_id = pid_id;
        this.data = data;
        Cld.Builder builder = data.builder;
        pid = builder.get_object (this.pid_id) as Cld.Pid;
        create_widgets ();
        connect_signals ();
    }

    private void create_widgets () {
        /* Create and setup widgets */
        manual_adjustment = new Adjustment (0.0, 0.0, 100.0, 0.5, 0.5, 0.0);
        manual_scale = new Scale (Orientation.HORIZONTAL, manual_adjustment);
        manual_scale.draw_value = false;
        manual_spin_button = new SpinButton (manual_adjustment, 1.0, 2);
        sp_adjustment = new Adjustment (0.0, 0.0, 1000.0, 1.0, 1.0, 0.0);
        sp_spin_button = new SpinButton (sp_adjustment, 1.0, 2);
        sp_spin_button.sensitive = false;
        pid_enable = new ToggleButton ();
        pid_enable.image = new Gtk.Image.from_stock ("gtk-media-play", IconSize.BUTTON);
        pid_settings = new Button ();
        pid_settings.image = new Gtk.Image.from_stock ("gtk-properties", IconSize.BUTTON);

        /* Layout widgets */
        var r1hbox = new Box (Orientation.HORIZONTAL, 5);
        var desc = new Label (pid.desc);
        desc.justify = Justification.LEFT;
        string units = pid.pv.calibration.units;
        r1hbox.pack_start (desc, false, false, 0);
        r1hbox.pack_start (manual_scale, true, true, 0);
        r1hbox.pack_start (pid_enable, false, false, 0);
        r1hbox.pack_start (pid_settings, false, false, 0);

        var r2hbox = new Box (Orientation.HORIZONTAL, 10);
        r2hbox.pack_start (new Gtk.Label ("Output\n[% of max.]"), true, false, 0);
        r2hbox.pack_start (manual_spin_button, false, false, 0);
        r2hbox.pack_start (new Gtk.Label ("PID Setpoint\n[" + units + "]"), true, false, 0);
        r2hbox.pack_start (sp_spin_button, false, false, 0);

        var vbox = new Box (Orientation.VERTICAL, 10);
        vbox.pack_start (r1hbox, false, false, 0);
        vbox.pack_start (r2hbox, false, false, 0);
        pack_start (vbox, false, false, 0);

        show_all ();
    }

    private void connect_signals () {
        pid_settings.clicked.connect (() => {
            settings_dialog.run ();
        });

        (pid_enable as Gtk.ToggleButton).toggled.connect (() => {
            var builder = data.builder;
            var mv = builder.get_object (pid.mv_id);
            var pv = builder.get_object (pid.pv_id);
            if ((pid_enable as Gtk.ToggleButton).active) {
                manual_scale.sensitive = false;
                manual_spin_button.sensitive = false;
                sp_spin_button.sensitive = true;
                sp_adjustment.value = (pv as Cld.AChannel).scaled_value;
                if (!pid.running) {
                    pid.calculate_preload_bias ();
                    try {
                        pid.running = true;
                        pid_thread = new Cld.Pid.Thread (pid);
                        /* TODO create is deprecated, check compiler warnings */
                        thread = GLib.Thread.create<void *> (pid_thread.run, true);
                    } catch (ThreadError e) {
                        pid.running = false;
                        error ("%s\n", e.message);
                    }
                }
            } else {
                manual_scale.sensitive = true;
                manual_spin_button.sensitive = true;
                sp_spin_button.sensitive = false;
                manual_adjustment.value = (mv as Cld.AChannel).scaled_value;
                if (pid.running) {
                    pid.running = false;
                    thread.join ();
                }
            }
        });

        /* for now the manual adjustment on the control is from 0 - 100 %,
         * hence the divide by 10 */
        manual_adjustment.value_changed.connect (() => {
            Cld.Builder builder = data.builder;
            var channel = builder.get_object (pid.mv_id);
            (channel as Cld.AChannel).raw_value = manual_adjustment.value;
        });

        sp_adjustment.value_changed.connect (() => {
            pid.sp = sp_adjustment.value;
        });

        /* Prevent crazy RMB max/min-imization */

        (manual_spin_button as Gtk.Widget).button_press_event.connect ((event) => {
            if ((event.type == Gdk.EventType.BUTTON_PRESS) ||
                (event.type == Gdk.EventType.@2BUTTON_PRESS) ||
                (event.type == Gdk.EventType.@3BUTTON_PRESS)) {
                if (event.button == 2 || event.button == 3)
                    return true;
            }
            return false;
        });

        (sp_spin_button as Gtk.Widget).button_press_event.connect ((event) => {
            if ((event.type == Gdk.EventType.BUTTON_PRESS) ||
                (event.type == Gdk.EventType.@2BUTTON_PRESS) ||
                (event.type == Gdk.EventType.@3BUTTON_PRESS)) {
                if (event.button == 2 || event.button == 3)
                    return true;
            }
            return false;
        });
    }
}
