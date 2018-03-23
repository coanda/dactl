/**
 * A chart that refreshes its traces periodically
 */
public class Dactl.RTChart : Dactl.Chart, Dactl.Settable {

    private int _refresh_ms = 33;
    private Gee.Map<string, Dactl.Object> _objects;
    private uint timer_id;

    /**
     * The time period that is the inverse of the refresh rate
     */
    public int refresh_ms {
        get { return _refresh_ms; }
        set { _refresh_ms = value; }
    }

    /**
     * {@inheritDoc}
     */
    public Gee.Map<string, Dactl.Object> objects {
        get { return _objects; }
        set { update_objects (value); }
    }

    private Dactl.SettingsWidget _settings_menu;

    /**
     * {@inheritDoc}
     */
    protected Dactl.SettingsWidget settings_menu {
        get { return _settings_menu; }
        set {
            _settings_menu = value;
            /*_settings_menu.parent = this;*/
        }
    }

    construct {
        objects = new Gee.TreeMap<string, Dactl.Object> ();
        settings_menu = new Dactl.RTChartSettings ();

        canvas.add_events (Gdk.EventMask.BUTTON_PRESS_MASK |
                    Gdk.EventMask.BUTTON_RELEASE_MASK |
                    Gdk.EventMask.POINTER_MOTION_MASK |
                    Gdk.EventMask.KEY_PRESS_MASK |
                    Gdk.EventMask.KEY_RELEASE_MASK |
                    Gdk.EventMask.SCROLL_MASK);
        button_press_event.connect (button_press_event_cb);
    }

    /**
     * Construction using an XML node.
     */
    public RTChart.from_xml_node (Xml.Node *node) {
        base.from_xml_node (node);
        build_from_xml_node (node);
        connect_notify_signals ();
        start_timer ();
        update_settings_menu ();
        bind_to_menu ();
    }

    private void bind_to_menu () {
        var menu = settings_menu as Dactl.RTChartSettings;
        bind_property ("title", menu, "title", GLib.BindingFlags.BIDIRECTIONAL);
        y_axis.bind_property ("label", menu, "y-axis-label", GLib.BindingFlags.SYNC_CREATE | GLib.BindingFlags.BIDIRECTIONAL);
        y_axis.bind_property ("min", menu, "y-axis-min", GLib.BindingFlags.BIDIRECTIONAL);
        y_axis.bind_property ("max", menu, "y-axis-max", GLib.BindingFlags.BIDIRECTIONAL);
        y_axis.bind_property ("div-major", menu, "y-axis-div-major", GLib.BindingFlags.BIDIRECTIONAL);
        y_axis.bind_property ("div-minor", menu, "y-axis-div-minor", GLib.BindingFlags.BIDIRECTIONAL);
        x_axis.bind_property ("label", menu, "x-axis-label", GLib.BindingFlags.BIDIRECTIONAL);
        x_axis.bind_property ("min", menu, "x-axis-min", GLib.BindingFlags.BIDIRECTIONAL);
        x_axis.bind_property ("max", menu, "x-axis-max", GLib.BindingFlags.BIDIRECTIONAL);
        x_axis.bind_property ("div-major", menu, "x-axis-div-major", GLib.BindingFlags.BIDIRECTIONAL);
        x_axis.bind_property ("div-minor", menu, "x-axis-div-minor", GLib.BindingFlags.BIDIRECTIONAL);
    }

    private void update_settings_menu () {
        var menu = settings_menu as Dactl.RTChartSettings;

        menu.title = title;

        menu.y_axis_label = y_axis.label;
        menu.y_axis_min = y_axis.min;
        menu.y_axis_max = y_axis.max;
        menu.y_axis_div_major = y_axis.div_major;
        menu.y_axis_div_minor = y_axis.div_minor;

        menu.x_axis_label = x_axis.label;
        menu.x_axis_min = x_axis.min;
        menu.x_axis_max = x_axis.max;
        menu.x_axis_div_major = x_axis.div_major;
        menu.x_axis_div_minor = x_axis.div_minor;
    }

    /**
     * {@inheritDoc}
     */
    internal void build_from_xml_node (Xml.Node *node) {
        if (node->type == Xml.ElementType.ELEMENT_NODE &&
            node->type != Xml.ElementType.COMMENT_NODE) {
            this.node = node;
            /* Iterate through node children */
            for (Xml.Node *iter = node->children; iter != null; iter = iter->next) {
                if (iter->name == "property") {
                    switch (iter->get_prop ("name")) {
                        case "refresh-ms":
                            refresh_ms = int.parse (iter->get_content ());
                            break;
                        default:
                            break;
                    }
                }
            }
        }
    }

    private void start_timer () {
        var drawables = get_object_map (typeof (Dactl.Drawable));

        if (timer_id != 0)
            GLib.Source.remove (timer_id);
        timer_id = GLib.Timeout.add (refresh_ms, () => {
            /* XXX This is ugly */
            foreach (var drawable in drawables.values) {
                if (drawable is Dactl.RTTrace)
                    (drawable as Dactl.RTTrace).refresh ();
                else if (drawable is Dactl.RTMultiChannelTrace)
                    (drawable as Dactl.RTMultiChannelTrace).refresh ();
                else if (drawable is Dactl.HeatMap)
                    (drawable as Dactl.HeatMap).refresh ();
            }
            canvas.redraw ();

            return GLib.Source.CONTINUE;
        }, GLib.Priority.DEFAULT);
    }

    /**
     * Connect all notify signals to update node
     */
    private void connect_notify_signals () {
        Type type = get_type ();
        ObjectClass ocl = (ObjectClass)type.class_ref ();
        var menu = settings_menu as Dactl.RTChartSettings;

        foreach (ParamSpec spec in ocl.list_properties ()) {
            notify[spec.get_name ()].connect ((s, p) => {
                (this as Dactl.RTChart).update_node ();
            });
        }

        notify["refresh-ms"].connect (() => {
            start_timer ();
        });

        menu.notify["x-axis-label"].connect (() => {
            lbl_x_axis.set_text (menu.x_axis_label);
        });

        menu.notify["y-axis-label"].connect (() => {
            lbl_y_axis.set_text (menu.y_axis_label);
        });
    }

    public void highlight_trace (string id) {
        var traces = get_object_map (typeof (Dactl.RTTrace));
        foreach (var trace in traces.values) {
            if (trace is Dactl.RTTrace) {
                (trace as Dactl.RTTrace).highlight = false;
                if ((trace as Dactl.RTTrace).dataseries.ch_ref == id) {
                    debug ("Chart `%s' highlighting `%s'", this.id, id);
                    (trace as Dactl.RTTrace).highlight = true;
                }
            }
        }
    }

    /**
     * Update the XML Node for this object.
     */
    private new void update_node () {
        if (node->type == Xml.ElementType.ELEMENT_NODE &&
            node->type != Xml.ElementType.COMMENT_NODE) {
            /* iterate through node children */
            for (Xml.Node *iter = node->children;
                 iter != null;
                 iter = iter->next) {
                if (iter->name == "property") {
                    switch (iter->get_prop ("name")) {
                        case "refresh-ms":
                            iter->set_content ("%d".printf (refresh_ms));
                            break;
                        default:
                            break;
                    }
                }
            }
        }
    }

    /**
     * {@inheritDoc}
     */
    public void update_objects (Gee.Map<string, Dactl.Object> val) {
        _objects = val;
    }
}

[GtkTemplate (ui = "/org/coanda/libdactl/ui/rt-chart-settings.ui")]
public class Dactl.RTChartSettings : Gtk.ScrolledWindow, Dactl.SettingsWidget {

    public string title { get; set; }
    public string y_axis_label { get; set; }
    public double y_axis_min { get; set; }
    public double y_axis_max { get; set; }
    public int y_axis_div_major { get; set; }
    public int y_axis_div_minor { get; set; }
    public string x_axis_label { get; set; }
    public double x_axis_min { get; set; }
    public double x_axis_max { get; set; }
    public int x_axis_div_major { get; set; }
    public int x_axis_div_minor { get; set; }

    [GtkChild]
    private Gtk.Entry entry_title;

    [GtkChild]
    private Gtk.Entry entry_y_axis;

    [GtkChild]
    private Gtk.SpinButton spinbutton_y_min;

    [GtkChild]
    private Gtk.SpinButton spinbutton_y_max;

    [GtkChild]
    private Gtk.SpinButton spinbutton_y_major;

    [GtkChild]
    private Gtk.SpinButton spinbutton_y_minor;

    [GtkChild]
    private Gtk.Entry entry_x_axis;

    [GtkChild]
    private Gtk.SpinButton spinbutton_x_min;

    [GtkChild]
    private Gtk.SpinButton spinbutton_x_max;

    [GtkChild]
    private Gtk.SpinButton spinbutton_x_major;

    [GtkChild]
    private Gtk.SpinButton spinbutton_x_minor;

    [GtkChild]
    private Gtk.Adjustment adj_x_min;

    [GtkChild]
    private Gtk.Adjustment adj_x_max;

    [GtkChild]
    private Gtk.Adjustment adj_y_min;

    [GtkChild]
    private Gtk.Adjustment adj_y_max;

    [GtkChild]
    private Gtk.ListBox listbox_traces;

    construct {
        populate_traces ();
        show_all ();
        connect_notify_signals ();
    }

    private void connect_notify_signals () {
        notify["title"].connect (() => {
            entry_title.set_text (title);
        });

        notify["y-axis-label"].connect (() => {
            entry_y_axis.set_text (y_axis_label);
        });

        notify["y-axis-min"].connect (() => {
            adj_y_max.lower = y_axis_min + adj_y_max.step_increment;
            spinbutton_y_min.set_value (y_axis_min);
        });

        notify["y-axis-max"].connect (() => {
            adj_y_min.upper = y_axis_max - adj_y_min.step_increment;
            spinbutton_y_max.set_value (y_axis_max);
        });

        notify["y-axis-div-major"].connect (() => {
            spinbutton_y_major.set_value (y_axis_div_major);
        });

        notify["y-axis-div-minor"].connect (() => {
            spinbutton_y_minor.set_value (y_axis_div_minor);
        });

        notify["x-axis-label"].connect (() => {
            entry_x_axis.set_text (x_axis_label);
        });

        notify["x-axis-min"].connect (() => {
            adj_x_max.lower = x_axis_min + adj_x_max.step_increment;
            spinbutton_x_min.set_value (x_axis_min);
        });

        notify["x-axis-max"].connect (() => {
            adj_x_min.upper = x_axis_max - adj_x_min.step_increment;
            spinbutton_x_max.set_value (x_axis_max);
        });

        notify["x-axis-div-major"].connect (() => {
            spinbutton_x_major.set_value (x_axis_div_major);
        });

        notify["x-axis-div-minor"].connect (() => {
            spinbutton_x_minor.set_value (x_axis_div_minor);
        });
    }

    private void populate_traces () {
        /*var traces = (parent as Dactl.Container).get_object_map (typeof (Dactl.RTTrace));*/
        /*var app = Dactl.UI.Application.get_default ();*/
/*
 *        var channels = app.model.ctx.get_object_map (typeof (Cld.Channel));
 *        foreach (var row in listbox_traces.get_children ())
 *            remove (row);
 *
 *        foreach (var trace in traces.values) {
 *            var box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 5);
 *            var btn_remove = new Gtk.Button.with_label (Remove);
 *            var combo = new Gtk.ComboBoxText.with_entry ("???");
 *            var btn_edit = new Gtk.Button.with_label (Edit);
 *            foreach (var channel in channels.values) {
 *                combo.append (null, channel.uri);
 *            }
 *            box.pack_start (btn_remove);
 *            box_pack_start (combo);
 *            box.pack_start (btn_edit);
 *
 *            var row = new Gtk.ListBoxRow ();
 *            row.add (box);
 *        }
 */
    }

    [GtkCallback]
    private void entry_title_activate_cb () {
        title = entry_title.get_text ();
    }

    [GtkCallback]
    private void entry_y_axis_activate_cb () {
        y_axis_label = entry_y_axis.get_text ();
    }

    [GtkCallback]
    private void spinbutton_y_min_value_changed_cb () {
        y_axis_min = spinbutton_y_min.get_value ();
    }

    [GtkCallback]
    private void spinbutton_y_max_value_changed_cb () {
        y_axis_max = spinbutton_y_max.get_value ();
    }

    [GtkCallback]
    private void spinbutton_y_major_value_changed_cb () {
        y_axis_div_major = spinbutton_y_major.get_value_as_int ();
    }

    [GtkCallback]
    private void spinbutton_y_minor_value_changed_cb () {
        y_axis_div_minor = spinbutton_y_minor.get_value_as_int ();
    }

    [GtkCallback]
    private void entry_x_axis_activate_cb () {
        x_axis_label = entry_x_axis.get_text ();
    }

    [GtkCallback]
    private void spinbutton_x_min_value_changed_cb () {
        x_axis_min = spinbutton_x_min.get_value ();
    }

    [GtkCallback]
    private void spinbutton_x_max_value_changed_cb () {
        x_axis_max = spinbutton_x_max.get_value ();
    }

    [GtkCallback]
    private void spinbutton_x_major_value_changed_cb () {
        x_axis_div_major = spinbutton_x_major.get_value_as_int ();
    }

    [GtkCallback]
    private void spinbutton_x_minor_value_changed_cb () {
        x_axis_div_minor = spinbutton_x_minor.get_value_as_int ();
    }
}


