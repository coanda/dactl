[Flags]
public enum Dactl.ChartFlag {
    DRAW_TITLE          = 0x01,
    DRAW_GRID           = 0x02,
    DRAW_GRID_BORDER    = 0x04,
    REVERSE_X_AXIS      = 0x08,
    DRAW_X_AXIS_LABEL   = 0x10,
    ROTATE_X_AXIS_LABEL = 0x20,
    DRAW_Y_AXIS_LABEL   = 0x40,
    ROTATE_Y_AXIS_LABEL = 0x80;

    public Dactl.ChartFlag set (Dactl.ChartFlag flag) {
        return (this | flag);
    }

    public Dactl.ChartFlag unset (Dactl.ChartFlag flag) {
        return (this & ~flag);
    }

    public bool is_set (Dactl.ChartFlag flag) {
        return (flag in this);
    }
}

protected class Dactl.ChartCanvas : Dactl.Canvas {

    public weak Dactl.Axis x_axis { get; set; }

    public weak Dactl.Axis y_axis { get; set; }

    /* To draw or not draw the grid */
    public bool draw_grid { get; set; }

    /* To draw or not draw the grid border */
    public bool draw_grid_border { get; set; }

    public ChartCanvas () {
        add_events (Gdk.EventMask.BUTTON_PRESS_MASK |
                    Gdk.EventMask.BUTTON_RELEASE_MASK |
                    Gdk.EventMask.POINTER_MOTION_MASK |
                    Gdk.EventMask.KEY_PRESS_MASK |
                    Gdk.EventMask.KEY_RELEASE_MASK |
                    Gdk.EventMask.SCROLL_MASK);

        update ();

        set_size_request (320, 240);
    }

    /**
     * Draw callback.
     */
    public override bool draw (Cairo.Context cr) {
        cr.set_source_rgb (1, 1, 1);
        /*cr.set_source_rgba (1, 1, 1, 0.5);*/
        cr.paint ();

        var w = get_allocated_width ();
        var h = get_allocated_height ();
        var parent = get_parent ();
        var grid_surface = new Cairo.ImageSurface (Cairo.Format.ARGB32, w, h);
        var grid = new Dactl.ChartGrid (grid_surface);

        cr.set_antialias (Cairo.Antialias.SUBPIXEL);

        /* Grid */
        if (draw_grid) {
            var grid_color = Gdk.RGBA () {
                red = 0.5,
                green = 0.5,
                blue = 0.5,
                alpha = 1.0
            };

            if (draw_grid_border) {
                grid.set_source_rgba (grid_color.red, grid_color.green, grid_color.blue, grid_color.alpha);
                grid.rectangle (0.5, 0.5, w, h);
                grid.set_line_width (1.0);
                grid.stroke ();
            }

            grid.draw (x_axis, y_axis, grid_color, w, h);
            cr.set_operator (Cairo.Operator.OVER);
            cr.set_source_surface (grid.get_target (), 0, 0);
            cr.paint ();
        }

        return false;
    }

    public override bool button_press_event (Gdk.EventButton event) {
        return false;
    }

    public override bool button_release_event (Gdk.EventButton event) {
        return false;
    }

    public override bool motion_notify_event (Gdk.EventMotion event) {
        return false;
    }

    private bool update () {
        redraw ();
        return true;
    }

    public void redraw () {
        var window = get_window ();
        if (window == null) {
            return;
        }

        /*var region = window.get_clip_region ();*/
        // Redraw the cairo canvas completely by exposing it
        /*window.invalidate_region (region, true);*/
        queue_draw ();
    }
}

[GtkTemplate (ui = "/org/coanda/libdactl/ui/chart.ui")]
public class Dactl.Chart : Dactl.CompositeWidget {

    private Xml.Node* _node;

    private string _xml = """
        <ui:object id=\"chart0\" type=\"chart\"/>
          <ui:property name=\"title\">Chart 0</ui:property>
          <ui:property name=\"height-min\">100</ui:property>
          <ui:property name=\"width-min\">100</ui:property>
          <ui:property name=\"expand\">true</ui:property>
          <ui:property name=\"fill\">true</ui:property>
          <ui:property name=\"show-title\">true</ui:property>
          <ui:property name=\"show-grid\">true</ui:property>
          <ui:property name=\"show-grid-border\">true</ui:property>
    """;

    private string _xsd = """
        <xs:element name="object">
          <xs:attribute name="id" type="xs:string" use="required"/>
          <xs:attribute name="type" type="xs:string" use="required"/>
          <xs:attribute name="ref" type="xs:string" use="required"/>
        </xs:element>
    """;

    private Gee.Map<string, Dactl.Object> _objects;

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
    protected virtual Xml.Node* node {
        get {
            return _node;
        }
        set {
            _node = value;
        }
    }

    /**
     * {@inheritDoc}
     */
    protected bool satisfied { get; set; default = false; }

    /* Title */
    public string title { get; set; default = "Chart"; }

    /* Minimum height to support scrollable container */
    public int height_min { get; set; default = 100; }

    /* Minimum width to support scrollable container */
    public int width_min { get; set; default = 100; }

    public Dactl.ChartFlag flags { get; set; }

    [GtkChild]
    private Gtk.Grid grid;

    [GtkChild]
    protected Dactl.ChartCanvas canvas;

    protected Dactl.Axis y_axis;

    protected Dactl.Axis x_axis;

    [GtkChild]
    protected Gtk.Label lbl_title;

    [GtkChild]
    protected Gtk.Label lbl_y_axis;

    [GtkChild]
    protected Gtk.Label lbl_x_axis;

    private Gee.Map<string, Dactl.Object> drawables;

    /**
     * Common object construction.
     */
    construct {
        id = "chart0";
        canvas.id = "%s-canvas0".printf (id);
        objects = new Gee.TreeMap<string, Dactl.Object> ();
        hexpand = true;
        vexpand = true;
        halign = Gtk.Align.FILL;
        valign = Gtk.Align.FILL;
        flags = Dactl.ChartFlag.DRAW_TITLE | Dactl.ChartFlag.DRAW_GRID;

        connect_signals ();
    }

    /**
     * Construction using an XML node.
     */
    public Chart.from_xml_node (Xml.Node *node) {
        build_from_xml_node (node);
        canvas.id = "%s-canvas0".printf (id);
        update_layout ();

        drawables = get_object_map (typeof (Dactl.Drawable));
        do_flags ();
        connect_notify_signals ();

        show_all ();
    }

    /**
     * {@inheritDoc}
     */
    public override void build_from_xml_node (Xml.Node *node) {
        string? value;

        this.node = node;
        if (node->type == Xml.ElementType.ELEMENT_NODE &&
            node->type != Xml.ElementType.COMMENT_NODE) {
            id = node->get_prop ("id");

            /* Iterate through node children */
            for (Xml.Node *iter = node->children; iter != null; iter = iter->next) {
                if (iter->name == "property") {

                    switch (iter->get_prop ("name")) {
                        case "title":
                            title = iter->get_content ();
                            lbl_title.set_text (title);
                            break;
                        case "expand":
                            value = iter->get_content ();
                            expand = bool.parse (value);
                            break;
                        case "fill":
                            value = iter->get_content ();
                            fill = bool.parse (value);
                            break;
                        case "height-min":
                            value = iter->get_content ();
                            height_min = int.parse (value);
                            break;
                        case "width-min":
                            value = iter->get_content ();
                            width_min = int.parse (value);
                            break;
                        case "show-title":
                            value = iter->get_content ();
                            if (bool.parse (value))
                                flags = flags.set (Dactl.ChartFlag.DRAW_TITLE);
                            else
                                flags = flags.unset (Dactl.ChartFlag.DRAW_TITLE);
                            break;
                        case "show-grid":
                            value = iter->get_content ();
                            if (bool.parse (value))
                                flags = flags.set (Dactl.ChartFlag.DRAW_GRID);
                            else
                                flags = flags.unset (Dactl.ChartFlag.DRAW_GRID);
                            break;
                        case "show-grid-border":
                            value = iter->get_content ();
                            if (bool.parse (value))
                                flags = flags.set (Dactl.ChartFlag.DRAW_GRID_BORDER);
                            else
                                flags = flags.unset (Dactl.ChartFlag.DRAW_GRID_BORDER);
                            break;
                        case "reverse-x-axis":
                            value = iter->get_content ();
                            flags = (bool.parse (value))
                                  ? flags.set (Dactl.ChartFlag.REVERSE_X_AXIS)
                                  : flags.unset (Dactl.ChartFlag.REVERSE_X_AXIS);
                            break;
                        case "show-x-axis-label":
                            value = iter->get_content ();
                            flags = (bool.parse (value))
                                  ? flags.set (Dactl.ChartFlag.DRAW_X_AXIS_LABEL)
                                  : flags.unset (Dactl.ChartFlag.DRAW_X_AXIS_LABEL);
                            break;
                        case "rotate-x-axis-label":
                            value = iter->get_content ();
                            flags = (bool.parse (value))
                                  ? flags.set (Dactl.ChartFlag.ROTATE_X_AXIS_LABEL)
                                  : flags.unset (Dactl.ChartFlag.ROTATE_X_AXIS_LABEL);
                            break;
                        case "show-y-axis-label":
                            value = iter->get_content ();
                            flags = (bool.parse (value))
                                  ? flags.set (Dactl.ChartFlag.DRAW_Y_AXIS_LABEL)
                                  : flags.unset (Dactl.ChartFlag.DRAW_Y_AXIS_LABEL);
                            break;
                        case "rotate-y-axis-label":
                            value = iter->get_content ();
                            flags = (bool.parse (value))
                                  ? flags.set (Dactl.ChartFlag.ROTATE_Y_AXIS_LABEL)
                                  : flags.unset (Dactl.ChartFlag.ROTATE_Y_AXIS_LABEL);
                            break;
                        default:
                            break;
                    }
                } else if (iter->name == "object") {
                    var type = iter->get_prop ("type");
                    if (type == "chart-axis") {
                        var axis = new Dactl.Axis.from_xml_node (iter);
                        this.add_child (axis);
                    } else if (type == "trace") {
                        var ttype = iter->get_prop ("ttype");
                        if (ttype == "xy") {
                            var trace = new Dactl.Trace.from_xml_node (iter);
                            this.add_child (trace);
                        } else if (ttype == "real-time") {
                            var trace = new Dactl.RTTrace.from_xml_node (iter);
                            this.add_child (trace);
                        } else if (ttype == "multichannel") {
                            var trace = new Dactl.RTMultiChannelTrace.from_xml_node (iter);
                            this.add_child (trace);
                        }
                    } else if (type == "heatmap") {
                        var heatmap = new Dactl.HeatMap.from_xml_node (iter);
                        this.add_child (heatmap);
                    }
                }
            }
        }
    }

    /**
     * Connect all notify signals to update node
     */
    protected void connect_notify_signals () {
        Type type = get_type ();
        ObjectClass ocl = (ObjectClass)type.class_ref ();

        foreach (ParamSpec spec in ocl.list_properties ()) {
            notify[spec.get_name ()].connect ((s, p) => {
                update_node ();
                queue_draw ();
            });
        }

        notify["title"].connect (() => {
            lbl_title.set_text (title);
        });

        notify["flags"].connect ((s, p) => {
            do_flags ();
        });
    }

    private void do_flags () {
        var traces = get_object_map (typeof (Dactl.Trace));
        /* Sets the scroll direction of the trace and axis */
        if (flags.is_set (Dactl.ChartFlag.REVERSE_X_AXIS)) {
            x_axis.flags = x_axis.flags.set (Dactl.AxisFlag.REVERSE_ORDER);
            foreach (var trace in traces.values) {
                (trace as Dactl.Trace).flags = (trace as Dactl.Trace).
                                           flags.set (Dactl.TraceFlag.SCROLL_LEFT);
            }
        } else {
            x_axis.flags = x_axis.flags.unset (Dactl.AxisFlag.REVERSE_ORDER);
            foreach (var trace in traces.values) {
                (trace as Dactl.Trace).flags = (trace as Dactl.Trace).
                                           flags.unset (Dactl.TraceFlag.SCROLL_LEFT);
            }
        }

        if (flags.is_set (Dactl.ChartFlag.DRAW_TITLE)) {
            var parent = lbl_title.get_parent ();
            parent.remove (lbl_title);
            if (lbl_title.parent == null) {
                (grid as Gtk.Grid).attach (lbl_title, 2, 0, 1, 1);
            }
        } else {
            var parent = lbl_title.get_parent ();
            parent.remove (lbl_title);
        }

        flags.is_set (Dactl.ChartFlag.DRAW_GRID)
        ? canvas.draw_grid = true : canvas.draw_grid = false;

        flags.is_set (Dactl.ChartFlag.DRAW_GRID_BORDER)
        ? canvas.draw_grid_border = true : canvas.draw_grid_border = false;

        var parent = lbl_x_axis.get_parent ();
        if (flags.is_set (Dactl.ChartFlag.DRAW_X_AXIS_LABEL)) {
            grid.attach (lbl_x_axis, 0, 2, 1, 1);
        } else {
            parent.remove (lbl_x_axis);
        }

        if (flags.is_set (Dactl.ChartFlag.ROTATE_X_AXIS_LABEL)) {
            lbl_x_axis.set_angle (90);
        } else {
            lbl_x_axis.set_angle (0);
        }

        parent = lbl_y_axis.get_parent ();
        if (flags.is_set (Dactl.ChartFlag.DRAW_Y_AXIS_LABEL)) {
            grid.attach (lbl_y_axis, 2, 4, 1, 1);
        } else {
            parent.remove (lbl_y_axis);
        }

        if (flags.is_set (Dactl.ChartFlag.ROTATE_Y_AXIS_LABEL)) {
            lbl_y_axis.set_angle (90);
        } else {
            lbl_y_axis.set_angle (0);
        }

        canvas.redraw ();
    }

    /**
     * Update the XML Node for this object.
     */
    private void update_node () {
        if (node->type == Xml.ElementType.ELEMENT_NODE &&
            node->type != Xml.ElementType.COMMENT_NODE) {
            /* iterate through node children */
            for (Xml.Node *iter = node->children;
                 iter != null;
                 iter = iter->next) {
                if (iter->name == "property") {
                    switch (iter->get_prop ("name")) {
                        case "title":
                            iter->set_content (title);
                            break;
                        case "expand":
                            iter->set_content (expand.to_string ());
                            break;
                        case "fill":
                            iter->set_content (fill.to_string ());
                            break;
                        case "height-min":
                            iter->set_content ("%d".printf (height_min));
                            break;
                        case "width-min":
                            iter->set_content ("%d".printf (width_min));
                            break;
                        case "show-title":
                            iter->set_content (flags.is_set (Dactl.ChartFlag.DRAW_TITLE).to_string ());
                            break;
                        case "show-grid":
                            iter->set_content (flags.is_set (Dactl.ChartFlag.DRAW_GRID).to_string ());
                            break;
                        case "show-grid-border":
                            iter->set_content (flags.is_set (Dactl.ChartFlag.DRAW_GRID_BORDER).to_string ());
                            break;
                        case "reverse-x-axis":
                            iter->set_content (flags.is_set (Dactl.ChartFlag.REVERSE_X_AXIS).to_string ());
                            break;
                        case "show-x-axis-label":
                            iter->set_content (flags.is_set (Dactl.ChartFlag.DRAW_X_AXIS_LABEL).to_string ());
                            break;
                        case "rotate-x-axis-label":
                            iter->set_content (flags.is_set (Dactl.ChartFlag.ROTATE_X_AXIS_LABEL).to_string ());
                            break;
                        case "show-y-axis-label":
                            iter->set_content (flags.is_set (Dactl.ChartFlag.DRAW_Y_AXIS_LABEL).to_string ());
                            break;
                        case "rotate-y-axis-label":
                            iter->set_content (flags.is_set (Dactl.ChartFlag.ROTATE_Y_AXIS_LABEL).to_string ());
                            break;
                        default:
                            break;
                    }
                }
            }
        }
    }

    private void update_layout () {
        var axes = get_object_map (typeof (Dactl.Axis));

        foreach (var axis in axes.values) {
            if ((axis as Dactl.Axis).orientation == Dactl.Orientation.HORIZONTAL) {
                x_axis = axis as Dactl.Axis;
                lbl_x_axis.set_text (x_axis.label);
                x_axis.height_request = 25;
                grid.attach (x_axis, 2, 2, 1, 1);
                canvas.x_axis = x_axis;
            } else if ((axis as Dactl.Axis).orientation == Dactl.Orientation.VERTICAL) {
                y_axis = axis as Dactl.Axis;
                lbl_y_axis.set_text (y_axis.label);
                y_axis.width_request = 25;
                grid.attach (y_axis, 1, 1, 1, 1);
                canvas.y_axis = y_axis;
            }
        }
    }

    /**
     * Connect any signals including the notifications from the model.
     */
    private void connect_signals () {
        /*Draw everything else after the default handler has run*/
        canvas.draw.connect_after (draw_more);
    }

    private bool draw_more (Gtk.Widget da, Cairo.Context cr) {
        /*var drawables = get_object_map (typeof (Dactl.Drawable));*/
        var w = canvas.get_allocated_width ();
        var h = canvas.get_allocated_height ();
        var x_min = x_axis.min;
        var x_max = x_axis.max;
        var y_min = y_axis.min;
        var y_max = y_axis.max;
        /* XXX can image surface set be put in Dactl.Drawable as virtual */
        var image_surface = new Cairo.ImageSurface (Cairo.Format.ARGB32, w, h);

        foreach (var drawable in drawables.values) {
            (drawable as Dactl.Drawable).image_surface = image_surface;
            (drawable as Dactl.Drawable).generate (w, h, x_min, x_max, y_min, y_max);
            (drawable as Dactl.Drawable).draw (cr); // XXX put this in drawable too?
        }
        return false;
    }

    /**
     * {@inheritDoc}
     */
    public override void update_objects (Gee.Map<string, Dactl.Object> val) {
        _objects = val;
    }
}
