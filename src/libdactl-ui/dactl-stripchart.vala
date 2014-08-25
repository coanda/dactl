private class Dactl.StripChartCanvas : Dactl.CustomWidget {

    /**
     * {@inheritDoc}
     */
    protected override string xml { get { return "<object />"; } }

    /**
     * {@inheritDoc}
     */
    protected override string xsd { get { return "<object />"; } }

    public weak Dactl.Axis t_axis { get; set; }

    public weak Dactl.Axis y_axis { get; set; }

    private Gee.Map<string, Dactl.Object> _traces;

    public Gee.Map<string, Dactl.Object> traces {
        get { return _traces; }
        set { _traces.set_all (value); }
    }

    private int padding_top = 40;

    private int padding_right = 40;

    private int padding_bottom = 80;

    private int padding_left = 80;

    construct {
        margin_top = 5;
        margin_right = 5;
        margin_bottom = 5;
        margin_left = 5;

        add_events (Gdk.EventMask.BUTTON_PRESS_MASK |
                    Gdk.EventMask.BUTTON_RELEASE_MASK |
                    Gdk.EventMask.POINTER_MOTION_MASK |
                    Gdk.EventMask.KEY_PRESS_MASK |
                    Gdk.EventMask.KEY_RELEASE_MASK |
                    Gdk.EventMask.SCROLL_MASK);

        set_size_request (320, 240);

        _traces = new Gee.TreeMap<string, Dactl.Trace> ();
    }

    public StripChartCanvas () {
        set_size_request (320, 240);
    }

    // FIXME: Didn't expect to need internal CustomWidget classes
    public override void build_from_xml_node (Xml.Node *node) { }

    /**
     * Draw callback.
     */
    public override bool draw (Cairo.Context cr) {

        var parent = get_parent ();

        var w = get_allocated_width ();
        var h = get_allocated_height ();

        var grid_x = padding_left;
        var grid_y = padding_top;
        var grid_w = w - padding_left - padding_right;
        var grid_h = h - padding_top - padding_bottom;

        /* FIXME: probably won't work if min and max y are negative */

        var y_offset = Math.fabs ((y_axis.max / (y_axis.max - y_axis.min)) * grid_h);

        cr.set_antialias (Cairo.Antialias.SUBPIXEL);

        /* Grid */
        var grid_surface = new Cairo.ImageSurface (Cairo.Format.ARGB32, w, h);
        var grid_color = Gdk.RGBA () {
            red = 0.5,
            green = 0.5,
            blue = 0.5,
            alpha = 1.0
        };
        var grid = new Dactl.ChartGrid (grid_surface);
        grid.draw (t_axis, y_axis, grid_color, grid_w, grid_h);

        cr.set_operator (Cairo.Operator.OVER);
        cr.set_source_surface (grid.get_target (), grid_x, grid_y);
        cr.paint ();

        /* Axes */
        var t_axis_x = padding_left;
        var t_axis_y = padding_top + grid_h;
        var t_axis_surface = new Cairo.ImageSurface (Cairo.Format.ARGB32, w, h);
        var t_axis_ctx = new Dactl.AxisView (t_axis_surface);
        t_axis_ctx.draw (grid_w, 40, t_axis);

        cr.set_operator (Cairo.Operator.OVER);
        cr.set_source_surface (t_axis_ctx.get_target (), t_axis_x, t_axis_y);
        cr.paint ();

        var y_axis_x = padding_left -40;
        var y_axis_y = padding_top;
        var y_axis_surface = new Cairo.ImageSurface (Cairo.Format.ARGB32, w, h);
        var y_axis_ctx = new Dactl.AxisView (y_axis_surface);
        y_axis_ctx.draw (40, grid_h, y_axis);

        cr.set_operator (Cairo.Operator.OVER);
        cr.set_source_surface (y_axis_ctx.get_target (), y_axis_x, y_axis_y);
        cr.paint ();

        /* Labels */
        cr.set_source_rgb (0.5, 0.5, 0.5);
        cr.select_font_face ("sans-serif", Cairo.FontSlant.NORMAL, Cairo.FontWeight.BOLD);
        cr.set_font_size (12);
        cr.move_to (padding_left, padding_top - 5);
        cr.show_text ((parent as Dactl.StripChart).title);

        /* Legend */

        /* Traces */
        var trace_surface = new Cairo.ImageSurface (Cairo.Format.ARGB32, w, h);

        foreach (var trace in traces.values) {

            //var data = (trace as Dactl.Trace).window.to_array ();
            Dactl.Point[] data = new Dactl.Point[(trace as Dactl.Trace).window_size + 1];
            //for (var i = 0; i < data.length - 1; i++) {
            for (var i = 0; i < data.length; i++) {
                var point = (trace as Dactl.Trace).window.get (i);
                data[i] = new Dactl.Point (0.0, point.y);
            }

            double trace_div = (double)grid_w / (double)(data.length - 1);

            /* Scale the points to pixel values */
            for (var i = 0; i < data.length; i++) {
                data[i].x = i * trace_div;
                double value = data[i].y;

                /* FIXME: negative values displayed incorrectly */
                if (value > y_axis.max || value == double.NAN)
                    value = y_axis.max;
                else if (value < y_axis.min)
                    value = y_axis.min;

                data[i].y = (value > 0.0)
                    ? y_offset * (1 - (value / y_axis.max))
                    : y_offset * (1 + (value / y_axis.min));
            }

            var color = Gdk.RGBA ();
            color.parse ((trace as Dactl.Trace).color_spec);

            switch ((trace as Dactl.Trace).draw_type) {
                case Dactl.TraceDrawType.BAR:
                    var stencil = new Dactl.Bar (trace_surface);
                    stencil.set_source_rgba (color.red, color.green, color.blue, color.alpha);
                    stencil.draw (data, new Dactl.Point (0.0, y_offset), true);
                    cr.set_operator (Cairo.Operator.OVER);
                    cr.set_source_surface (stencil.get_target (), grid_x, grid_y);
                    cr.paint ();
                    break;
                case Dactl.TraceDrawType.LINE:
                    var stencil = new Dactl.Line (trace_surface);
                    stencil.set_source_rgba (color.red, color.green, color.blue, color.alpha);
                    stencil.draw (data);
                    cr.set_operator (Cairo.Operator.OVER);
                    cr.set_source_surface (stencil.get_target (), grid_x, grid_y);
                    cr.paint ();
                    break;
                case Dactl.TraceDrawType.POLYLINE:
                    var stencil = new Dactl.Polyline (trace_surface);
                    stencil.set_source_rgba (color.red, color.green, color.blue, color.alpha);
                    stencil.draw (data);
                    cr.set_operator (Cairo.Operator.OVER);
                    cr.set_source_surface (stencil.get_target (), grid_x, grid_y);
                    cr.paint ();
                    break;
                case Dactl.TraceDrawType.SCATTER:
                    var stencil = new Dactl.Scatter (trace_surface);
                    stencil.set_source_rgba (color.red, color.green, color.blue, color.alpha);
                    stencil.draw (data);
                    cr.set_operator (Cairo.Operator.OVER);
                    cr.set_source_surface (stencil.get_target (), grid_x, grid_y);
                    cr.paint ();
                    break;
                default:
                    assert_not_reached ();
                    break;
            }
        }

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

        if (t_axis != null && y_axis != null) {
            var region = window.get_clip_region ();
            // redraw the cairo canvas completely by exposing it
            window.invalidate_region (region, true);
            //window.process_updates (true);
        }
    }
}

[GtkTemplate (ui = "/org/coanda/libdactl/ui/stripchart.ui")]
public class Dactl.StripChart : Dactl.CompositeWidget, Dactl.CldAdapter {

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
    protected bool satisfied { get; set; default = false; }

    /**
     * Update timeout in ms.
     */
    public int timeout { get; set; default = 33; }

    /* Title */
    public string title { get; set; default = "Chart"; }

    /* Minimum height to support scrollable container */
    public int height_min { get; set; default = 100; }

    /* Minimum width to support scrollable container */
    public int width_min { get; set; default = 100; }

    [GtkChild]
    private Dactl.StripChartCanvas canvas;

    [GtkChild]
    private Gtk.Revealer settings;

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

        settings.set_reveal_child (false);
        settings.transition_type = Gtk.RevealerTransitionType.SLIDE_LEFT;
        settings.transition_duration = 400;
    }

    /**
     * Default construction.
     */
    public StripChart () {
        var t_axis = new Dactl.Axis ();
        var y_axis = new Dactl.Axis ();
        t_axis.orientation = Dactl.Orientation.HORIZONTAL;
        y_axis.orientation = Dactl.Orientation.VERTICAL;
        add_child (t_axis);
        add_child (y_axis);
        canvas.t_axis = t_axis;
        canvas.y_axis = y_axis;
        request_data.begin ();
    }

    /**
     * Construction using an XML node.
     */
    public StripChart.from_xml_node (Xml.Node *node) {
        build_from_xml_node (node);
        canvas.id = "%s-canvas0".printf (id);
        request_data.begin ();
    }

    /**
     * {@inheritDoc}
     */
    public override void build_from_xml_node (Xml.Node *node) {
        string? value;

        if (node->type == Xml.ElementType.ELEMENT_NODE &&
            node->type != Xml.ElementType.COMMENT_NODE) {
            id = node->get_prop ("id");

            /* Iterate through node children */
            for (Xml.Node *iter = node->children; iter != null; iter = iter->next) {
                if (iter->name == "property") {
                    switch (iter->get_prop ("name")) {
                        case "title":
                            title = iter->get_content ();
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
                        default:
                            break;
                    }
                } else if (iter->name == "object") {
                    var type = iter->get_prop ("type");
                    if (type == "chart-axis") {
                        var axis = new Dactl.Axis.from_xml_node (iter);
                        this.add_child (axis);
                    } else if (type == "chart-trace") {
                        var trace = new Dactl.Trace.from_xml_node (iter);
                        this.add_child (trace);
                    }
                }
            }
        }
    }

    /**
     * {@inheritDoc}
     */
    public virtual void offer_cld_object (Cld.Object object) {
        var traces = get_object_map (typeof (Dactl.Trace));
        foreach (var trace in traces.values) {
            if ((trace as Dactl.Trace).ch_ref == object.uri) {
                message ("Assigning channel `%s' to `%s'", object.uri, trace.id);
                (trace as Dactl.Trace).channel = (object as Cld.Channel);
            }
            satisfied = (trace as Dactl.Trace).channel_isset;
        }

        message ("Chart `%s' requirements satisfied: %s", id, satisfied.to_string ());

        if (satisfied) {
            /*
             *channels_loaded ();
             */

            message ("Updating the layout for `%s' using configured data", id);
            update_layout ();

            Timeout.add (timeout, update);
            show_all ();
        }
    }

    private void update_layout () {
        var axes = get_object_map (typeof (Dactl.Axis));
        foreach (var axis in axes.values) {
            if ((axis as Dactl.Axis).orientation == Dactl.Orientation.HORIZONTAL) {
                canvas.t_axis = axis as Dactl.Axis;
            } else if ((axis as Dactl.Axis).orientation == Dactl.Orientation.VERTICAL) {
                canvas.y_axis = axis as Dactl.Axis;
            }
        }

        var traces = get_object_map (typeof (Dactl.Trace));
        canvas.traces = traces;
    }

    /**
     * {@inheritDoc}
     */
    protected async void request_data () {
        while (!satisfied) {
            var traces = get_object_map (typeof (Dactl.Trace));
            foreach (var trace in traces.values) {
                if (!(trace as Dactl.Trace).channel_isset)
                    request_object ((trace as Dactl.Trace).ch_ref);
            }
            // Try again in a second
            yield nap (1000);
        }
    }

    /**
     * Connect any signals including the notifications from the model.
     */
    private void connect_signals () {

        notify["title"].connect (() => {
            /* Change the title */
        });
    }

    /**
     * Callback to perform on the timeout interval.
     */
    private bool update () {
        canvas.redraw ();
        return true;
    }

    /**
     * {@inheritDoc}
     */
    public override void update_objects (Gee.Map<string, Dactl.Object> val) {
        _objects = val;
    }

    [GtkCallback]
    public bool canvas_button_press_event_cb (Gdk.EventButton event) {

        if (event.type == Gdk.EventType.2BUTTON_PRESS) {
            settings.set_reveal_child (!settings.reveal_child);
        }

        return false;
    }

    [GtkCallback]
    public bool canvas_button_release_event_cb (Gdk.EventButton event) {
        return false;
    }
}
