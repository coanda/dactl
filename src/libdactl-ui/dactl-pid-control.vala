[GtkTemplate (ui = "/org/coanda/libdactl/ui/pid-control.ui")]
public class Dactl.PidControl : Dactl.CompositeWidget, Dactl.CldAdapter {

    private string _xml = """
        <object id=\"ai-ctl0\" type=\"ai\" ref=\"cld://ai0\"/>
    """;

    private string _xsd = """
        <xs:element name="object">
          <xs:attribute name="id" type="xs:string" use="required"/>
          <xs:attribute name="type" type="xs:string" use="required"/>
          <xs:attribute name="ref" type="xs:string" use="required"/>
        </xs:element>
    """;

    [GtkChild]
    private Gtk.Stack content;

    [GtkChild]
    private Gtk.Viewport viewport_on;

    [GtkChild]
    private Gtk.Viewport viewport_off;

    [GtkChild]
    private Gtk.Button btn_control_start;

    [GtkChild]
    private Gtk.Button btn_control_stop;

    [GtkChild]
    private Gtk.Button btn_settings;

    [GtkChild]
    private Gtk.SpinButton btn_output;

    [GtkChild]
    private Gtk.SpinButton btn_sp;

    [GtkChild]
    private Gtk.SpinButton btn_kp;

    [GtkChild]
    private Gtk.SpinButton btn_ki;

    [GtkChild]
    private Gtk.SpinButton btn_kd;

    [GtkChild]
    private Gtk.Label lbl_input;

    [GtkChild]
    private Gtk.Label lbl_output;

    [GtkChild]
    private Gtk.Label lbl_units_on;

    [GtkChild]
    private Gtk.Revealer settings;

    [GtkChild]
    private Gtk.Image img_control_start;

    [GtkChild]
    private Gtk.Image img_control_stop;

    [GtkChild]
    private Gtk.Image img_settings;

    [GtkChild]
    private Gtk.Label lbl_id;

    [GtkChild]
    private Gtk.Adjustment adjustment_output;

    [GtkChild]
    private Gtk.Adjustment adjustment_sp;

    [GtkChild]
    private Gtk.Adjustment adjustment_kp;

    [GtkChild]
    private Gtk.Adjustment adjustment_ki;

    [GtkChild]
    private Gtk.Adjustment adjustment_kd;

    private Gee.Map<string, Dactl.Object> _objects;

    private string pid_ref;

    private weak Cld.Pid2 _pid;

    public Cld.Pid2 pid {
        get { return _pid; }
        set {
            if (value.uri == pid_ref) {
                _pid = value;
                pid_isset = true;
            }
        }
    }

    private bool pid_isset { get; private set; default = false; }

    /**
     * {@inheritDoc}
     */
    protected override string xml {
        get { return _xml; }
    }

    /**
     * {@inheritDoc}
     */
    protected override string xsd {
        get { return _xsd; }
    }

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

    construct {
        id = "pid-ctl0";

        objects = new Gee.TreeMap<string, Dactl.Object> ();

        // FIXME: doesn't work from .ui file
        content.transition_type = Gtk.StackTransitionType.SLIDE_LEFT_RIGHT;
        content.transition_duration = 400;

        settings.set_reveal_child (false);
        settings.transition_type = Gtk.RevealerTransitionType.SLIDE_DOWN;
        settings.transition_duration = 400;

        connect_signals ();
    }

    //public PidControl (string pid_ref) {}

    public PidControl.from_xml_node (Xml.Node *node) {
        build_from_xml_node (node);

        // Request CLD data
        request_data.begin ((obj, res) => {
            var style_context = btn_sp.get_style_context ();
            pid.notify["sp-channel-connected"].connect (() => {
                if (pid.sp_channel_connected) {
                    style_context.add_class ("readout");
                } else {
                    style_context.remove_class ("readout");
                    /* Bump the control to get it to signal a value change */
                    adjustment_sp.set_value (double.parse (btn_sp.get_text ()));
                }
            });

            /* Update the setpoint button if the pid is running with the setpoint channel as input */
            GLib.Timeout.add (300, () => {
                if (pid.sp_channel_connected && pid.running)
                    btn_sp.set_text ("%.3f".printf (pid.sp));

                return true;
            });
        });
    }

    /**
     * {@inheritDoc}
     */
    public override void build_from_xml_node (Xml.Node *node) {
        if (node->type == Xml.ElementType.ELEMENT_NODE &&
            node->type != Xml.ElementType.COMMENT_NODE) {
            id = node->get_prop ("id");
            pid_ref = node->get_prop ("ref");
        }
    }

    private void connect_signals () {
        /* Prevent RMB max/min-imization */

        (btn_output as Gtk.Widget).button_press_event.connect ((event) => {
            if ((event.type == Gdk.EventType.BUTTON_PRESS) ||
                (event.type == Gdk.EventType.@2BUTTON_PRESS) ||
                (event.type == Gdk.EventType.@3BUTTON_PRESS)) {
                if (event.button == 2 || event.button == 3)
                    return true;
            }
            return false;
        });

        (btn_sp as Gtk.Widget).button_press_event.connect ((event) => {
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
    public void offer_cld_object (Cld.Object object) {
        if (object.uri == pid_ref) {
            pid = (object as Cld.Pid2);
            lbl_id.label = pid.id;
            var mv = pid.get_object (pid.mv_id);
            satisfied = true;
            adjustment_output.value = ((mv as Cld.DataSeries).channel as Cld.AOChannel).raw_value;
            adjustment_sp.value = pid.sp;
            adjustment_kp.value = pid.kp;
            adjustment_ki.value = pid.ki;
            adjustment_kd.value = pid.kd;
            lbl_input.set_text (pid.pv.uri);
            lbl_output.set_text (pid.mv.uri);
            lbl_units_on.set_text (pid.mv.channel.calibration.units);
            pid.mv.channel.calibration.bind_property ("units",
                               lbl_units_on, "label", GLib.BindingFlags.DEFAULT);
        }
    }

    /**
     * Use methods to emulate an operator initated shutdown of the PID output
     */
    public void shutdown () {
        if (pid.sp_channel_connected)
            pid.disconnect_sp_channel ();
        adjustment_output.value = 0;
        adjustment_output_value_changed_cb ();
        btn_control_stop_clicked_cb ();
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
    }

    [GtkCallback]
    private void btn_control_start_clicked_cb () {
        content.visible_child = viewport_on;

        /* XXX PID object should throw error on failed start */
        var pv = pid.get_object (pid.pv_id);
        adjustment_sp.value = ((pv as Cld.DataSeries).channel as Cld.ScalableChannel).scaled_value;
        debug ("process variable scaled_value: %.3f", ((pv as Cld.DataSeries).channel as Cld.ScalableChannel).scaled_value);
        pid.start ();
    }

    [GtkCallback]
    private void btn_control_stop_clicked_cb () {
        content.visible_child = viewport_off;

        /* XXX PID object should throw error on failed stop */
        var mv = pid.get_object (pid.mv_id);
        adjustment_output.value = ((mv as Cld.DataSeries).channel as Cld.AOChannel).raw_value;
        debug ("manipulated variable raw_value: %.3f", ((mv as Cld.DataSeries).channel as Cld.AOChannel).raw_value);
        pid.stop ();
    }

    [GtkCallback]
    private void btn_settings_clicked_cb () {
        settings.set_reveal_child (!settings.reveal_child);
    }

    [GtkCallback]
    private void adjustment_output_value_changed_cb () {
        var mv = pid.get_object (pid.mv_id);
        /* FIXME: shouldn't be this specific with Cld.AOChannel */
        ((mv as Cld.DataSeries).channel as Cld.AOChannel).raw_value = adjustment_output.value;
    }

    [GtkCallback]
    private void adjustment_sp_value_changed_cb () {
        if (!pid.sp_channel_connected)
            pid.sp = adjustment_sp.value;
    }

    [GtkCallback]
    private void adjustment_kp_value_changed_cb () {
        pid.kp = adjustment_kp.value;
    }

    [GtkCallback]
    private void adjustment_ki_value_changed_cb () {
        pid.ki = adjustment_ki.value;
    }

    [GtkCallback]
    private void adjustment_kd_value_changed_cb () {
        pid.kd = adjustment_kd.value;
    }

    /**
     * {@inheritDoc}
     */
    public override void update_objects (Gee.Map<string, Dactl.Object> val) {
        _objects = val;
    }
}
