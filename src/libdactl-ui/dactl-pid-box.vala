/**
 * Custom widget to provide a graphical interface to a Cld.Pid
 */
public class Dactl.PidBox : Dactl.CompositeWidget, Dactl.CldAdapter {

    private Gee.Map<string, Dactl.Object> _objects;

    /**
     * {@inheritDoc}
     */
    public override Gee.Map<string, Dactl.Object> objects {
        get { return _objects; }
        set { update_objects (value); }
    }

    /**
     * {@inheritDoc}
     */
    protected bool satisfied { get; set; default = false; }

    private Gtk.Dialog _settings_dialog;

    public Gtk.Dialog settings_dialog {
        get { return _settings_dialog; }
        set { _settings_dialog = value; }
    }

    private Gtk.Box box;

    private Gtk.Adjustment manual_adjustment;

    private Gtk.Adjustment sp_adjustment;

    private Gtk.Scale manual_scale;

    private Gtk.SpinButton manual_spin_button;

    private Gtk.SpinButton sp_spin_button;

    private Gtk.Button pid_enable;

    private Gtk.Button pid_settings;

    private Cld.Pid2 pid;

    private Cld.Pid2.Thread pid_thread;

    public string pid_ref { get; set; }

    /* Thread for control loop execution */
    private unowned GLib.Thread<void *> thread;

    private string xml_template = """
        <object id="pidbox0" type="pidbox" pidref="pid0" />
    """;

    construct {
        id = "pidbox0";
        box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 10);
        add (box);
    }

    public PidBox (string pid_ref) {
        this.pid_ref = pid_ref;

        // Request the channel
        request_data.begin ();
    }

    public PidBox.from_xml_node (Xml.Node *node) {
        build_from_xml_node (node);

        // Request the channel
        request_data.begin ();
    }

    /**
     * {@inheritDoc}
     */
    public override void build_from_xml_node (Xml.Node *node) {
        if (node->type == Xml.ElementType.ELEMENT_NODE &&
            node->type != Xml.ElementType.COMMENT_NODE) {
            id = node->get_prop ("id");
            pid_ref = node->get_prop ("pidref");
        }
    }

    /**
     * {@inheritDoc}
     */
    public virtual void offer_cld_object (Cld.Object object) {
        if (object.id == pid_ref) {
            pid = (object as Cld.Pid2);
            satisfied = true;
        }
    }

    /**
     * {@inheritDoc}
     */
    protected async void request_data () {
        while (!satisfied) {
            request_object (pid_ref);
            // Try again in a second
            yield nap (1000);
        }

        // No point doing anything without the required data
        connect_signals ();

        // Widget contents depend on the Cld data so postpone the construction
        create_widgets ();
    }

    private void create_widgets () {
        /* Create and setup widgets */
        manual_adjustment = new Gtk.Adjustment (0.0, 0.0, 100.0, 0.5, 0.5, 0.0);
        manual_scale = new Gtk.Scale (Gtk.Orientation.HORIZONTAL, manual_adjustment);
        manual_scale.draw_value = false;
        manual_spin_button = new Gtk.SpinButton (manual_adjustment, 1.0, 2);
        sp_adjustment = new Gtk.Adjustment (0.0, 0.0, 1000.0, 1.0, 1.0, 0.0);
        sp_spin_button = new Gtk.SpinButton (sp_adjustment, 1.0, 2);
        sp_spin_button.sensitive = false;
        pid_enable = new Gtk.ToggleButton ();
        pid_enable.image = new Gtk.Image.from_stock ("gtk-media-play", Gtk.IconSize.BUTTON);
        pid_settings = new Gtk.Button ();
        pid_settings.image = new Gtk.Image.from_stock ("gtk-properties", Gtk.IconSize.BUTTON);

        /* Layout widgets */
        var r1hbox = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 5);
        var desc = new Gtk.Label (pid.desc);
        desc.justify = Gtk.Justification.LEFT;
        string units = pid.pv.channel.calibration.units;
        r1hbox.pack_start (desc, false, false, 0);
        r1hbox.pack_start (manual_scale, true, true, 0);
        r1hbox.pack_start (pid_enable, false, false, 0);
        r1hbox.pack_start (pid_settings, false, false, 0);

        var r2hbox = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 10);
        r2hbox.pack_start (new Gtk.Label ("Output\n[% of max.]"), true, false, 0);
        r2hbox.pack_start (manual_spin_button, false, false, 0);
        r2hbox.pack_start (new Gtk.Label ("PID Setpoint\n[" + units + "]"), true, false, 0);
        r2hbox.pack_start (sp_spin_button, false, false, 0);

        var vbox = new Gtk.Box (Gtk.Orientation.VERTICAL, 10);
        vbox.pack_start (r1hbox, false, false, 0);
        vbox.pack_start (r2hbox, false, false, 0);
        box.pack_start (vbox, false, false, 0);

        show_all ();
    }

    private void connect_signals () {
        pid_settings.clicked.connect (() => {
            settings_dialog.run ();
        });

        (pid_enable as Gtk.ToggleButton).toggled.connect (() => {
            var mv = pid.get_object (pid.mv_id);
            var pv = pid.get_object (pid.pv_id);
            if ((pid_enable as Gtk.ToggleButton).active) {
                manual_scale.sensitive = false;
                manual_spin_button.sensitive = false;
                sp_spin_button.sensitive = true;
                sp_adjustment.value = (((pv as Cld.DataSeries).channel) as Cld.ScalableChannel).scaled_value;
                if (!pid.running) {
                    pid.calculate_preload_bias ();
                    try {
                        pid.running = true;
                        pid_thread = new Cld.Pid2.Thread (pid);
                        /* TODO create is deprecated, chenck compiler warnings */
                        thread = GLib.Thread.create<void *> (pid_thread.run, true);
                    } catch (ThreadError e) {
                        pid.running = false;
                        GLib.error ("%s\n", e.message);
                    }
                }
            } else {
                manual_scale.sensitive = true;
                manual_spin_button.sensitive = true;
                sp_spin_button.sensitive = false;
                manual_adjustment.value = (((mv as Cld.DataSeries).channel) as Cld.ScalableChannel).scaled_value;
                if (pid.running) {
                    pid.running = false;
                    thread.join ();
                }
            }
        });

        /* for now the manual adjustment on the control is from 0 - 100 %,
         * hence the divide by 10 */
        manual_adjustment.value_changed.connect (() => {
            var dataseries = pid.get_object (pid.mv_id);
            (((dataseries as Cld.DataSeries).channel) as Cld.AOChannel).raw_value = manual_adjustment.value;
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

    /**
     * {@inheritDoc}
     */
    public override void update_objects (Gee.Map<string, Dactl.Object> val) {
        _objects = val;
    }
}
