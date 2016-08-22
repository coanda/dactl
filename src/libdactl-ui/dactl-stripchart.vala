[Deprecated (since = "0.4.0")]
public class Dactl.StripChartTrace : GLib.Object, Dactl.Object, Dactl.Buildable {

    /* Changed name from Trace to StripChartTrace while refactoring */

    private Xml.Node* _node;

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

    /**
     * {@inheritDoc}
     */
    public string id { get; set; default = "trace0"; }

    /**
     * {@inheritDoc}
     */
    protected virtual string xml {
        get { return _xml; }
    }

    /**
     * {@inheritDoc}
     */
    protected virtual string xsd {
        get { return _xsd; }
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

    public string ch_ref { get; set; }

    private weak Cld.Channel _channel;
    public Cld.Channel channel {
        get { return _channel; }
        set {
            if ((value as Cld.Object).uri == ch_ref) {
                _channel = value;
                channel_isset = true;

                /* Wait for channel requirement to be satisfied */
                (_channel as Cld.ScalableChannel).new_value.connect (new_value_cb);
            }
        }
    }

    //public bool channel_isset { get; private set; default = false; }

    public bool channel_isset { get; private set; default = false; }

    public bool highlight { get; set; default = false; }

    /**
     * Timeout in milliseconds duration to accumulate values over.
     * XXX FIXME Is this needed for anything???
     */
    public int duration { get; set; default = 10; }

    private int _buffer_size = 11;
    /**
     * Size of the buffer in samples.
     * XXX: buffer resize is completely untested
     */
    public int buffer_size {
        get { return _buffer_size - 1; }
        set {
            int n = value + 1;
            if (value != _buffer_size) {
                lock (buffer) {
                    /* Resizing the buffer involves repositioning the elements */
                    if (n < _buffer_size) {
                        for (int i = 0; i < n - 1; i++)
                            buffer[i] = buffer[i + 1];
                        buffer.resize (n - 1);
                    } else {
                        //buffer.resize (n - 1);
                        buffer.resize (n);
                        for (int i = n - 1; i > n - _buffer_size - 1; i--) {
                            buffer [i] = buffer [i - (n - _buffer_size)];
                        }
                        for (int i = 0; i < (n - buffer_size); i++) {
                            buffer [i] = 0;
                        }
                        buffer.resize (n - 1);
                    }
                }
                _buffer_size = n;
                buffer_size_changed (_buffer_size);
            }
        }
    }
    /**
     * Which simple drawing type to use to display the trace data.
     */
    public Dactl.TraceDrawType draw_type { get; set; default = Dactl.TraceDrawType.BAR; }

    /**
     * Line width to use for drawing.
     */
    public double line_weight { get; set; default = 1.0; }

    private double initial_line_weight = 1.0;

    /**
     * Textual representation of the color to use, could be anything from
     * the file rgb.txt, a hexadecimal value as eg. #FFF/#FF00FF/#FF00FF00,
     * or decimal value as eg. rgb(255,0,255)/rgba(255,0,255,0.0).
     */
    private string color_spec { get; set; default = "black"; }

    private Gdk.RGBA _color;

    public Gdk.RGBA color  {
        get { return _color; }
        set {
            _color = value;
            color_spec = color.to_string ();
        }
    }

    private Gee.List<Dactl.Point> _window = null;
    /**
     * Window of data to draw.
     */
    public Gee.List<Dactl.Point> window {
        get {
            /* Set default data whenever the window has be nullified */
            if (_window == null) {
                _window = new Gee.ArrayList<Dactl.Point> ();
                for (int i = 0; i < _window_size; i++)
                    _window.add (new Dactl.Point (0.0, 0.0));
            }
            return _window;
        }
        private set { _window = value; }
    }

    /* FIXME: add a n_division property for public access, window_size should
     *        for internal use */

    private int _window_size = 11;
    /**
     * Number of samples to use for the window.
     * FIXME: setting the window size should resize the window
     */
    public int window_size {
        get { return _window_size - 1; }
        set {
            int n = value + 1;
            /* XXX Removed this to fix chart resizing problem */
//            if (value != _window_size) {
                lock (window) {
                    /* Resizing is just dropping elements at the head */
                    if (n < _window_size) {
                        for (int i = 0; i < _window_size - n; i++)
                            _window.remove_at (0);
                    } else {
                        for (int i = 0; i < n - _window_size; i++)
                            _window.add (new Dactl.Point (0.0, 0.0));
                    }
                }
//            }
            _window_size = n;
            window_size_changed (_window_size);
        }
    }

    private int _stride = 1;
    /**
     * Data sampling stride for the buffer - window.
     */
    public int stride {
        get { return _stride; }
        set {
            lock (window) {
                _stride = (value > 0) ? value : 1;
            }
        }
    }

    private int nth_sample = 0;

    /**
     * Measured data from the connect channel.
     */
    private double[] buffer;

    /**
     * Emitted when the trace view window has been resized.
     */
    public signal void window_size_changed (int size);

    /**
     * Emitted when the buffer has been resized.
     */
    public signal void buffer_size_changed (int size);

    /**
     * Default construction.
     */
    construct {
        _color = Gdk.RGBA ();
    }

    public StripChartTrace () {
        buffer = new double[buffer_size];
        connect_signals ();
    }

    /**
     * Construction using an XML node.
     */
    public StripChartTrace.from_xml_node (Xml.Node *node) {
        build_from_xml_node (node);
        buffer = new double[buffer_size];
        connect_signals ();
    }

    /**
     * {@inheritDoc}
     */
    internal void build_from_xml_node (Xml.Node *node) {
        if (node->type == Xml.ElementType.ELEMENT_NODE &&
            node->type != Xml.ElementType.COMMENT_NODE) {
            id = node->get_prop ("id");
            ch_ref = node->get_prop ("ref");
            this.node = node;

            /* Iterate through node children */
            for (Xml.Node *iter = node->children; iter != null; iter = iter->next) {
                if (iter->name == "property") {
                    switch (iter->get_prop ("name")) {
                        case "buffer-size":
                            buffer_size = int.parse (iter->get_content ());
                            break;
                        case "draw-type":
                            draw_type = Dactl.TraceDrawType.parse (iter->get_content ());
                            break;
                        case "line-weight":
                            line_weight = double.parse (iter->get_content ());
                            initial_line_weight = line_weight;
                            break;
                        case "color":
                            color_spec = iter->get_content ();
                            _color.parse (color_spec);
                            break;
                        case "stride":
                            stride = int.parse (iter->get_content ());
                            break;
                        case "window-size":
                            window_size = int.parse (iter->get_content ());
                            break;
                        case "duration":
                            var value = iter->get_content ();
                            var regex = /^([0-9]*)([a-zA-Z]*)$/;
                            GLib.MatchInfo match;
                            regex.match (value, 0, out match);
                            var time = match.fetch (1);
                            var units = match.fetch (2);
                            var multiplier = 1;

                            if (units != "") {
                                switch (units.down ()) {
                                    case "ms":
                                        multiplier = 1;
                                        break;
                                    case "s":
                                        multiplier = 1000;
                                        break;
                                    case "m":
                                        multiplier = 60000;
                                        break;
                                    case "h":
                                        multiplier = 3600000;
                                        break;
                                    default:
                                        break;
                                }
                            }

                            duration = int.parse (time) * multiplier;

                            break;
                        default:
                            break;
                    }
                }
            }
        }
        connect_notify_signals ();
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
            });
        }
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
                        case "buffer-size":
                            iter->set_content ("%d".printf (buffer_size));
                            break;
                        case "draw-type":
                            iter->set_content (draw_type.to_string ());
                            break;
                        case "line-weight":
                            iter->set_content (line_weight.to_string ());
                            break;
                        case "color":
                            iter->set_content (color_spec);
                            break;
                        case "stride":
                            /* XXX FIXME Saving this causes problem with charts */
                            //iter->set_content ("%d".printf (stride));
                            break;
                        case "window-size":
                            /* XXX FIXME Saving this causes problem with charts */
                            //iter->set_content ("%d".printf (window_size));
                            break;
                        default:
                            break;
                    }
                }
            }
        }
    }

    private void connect_signals () {
        this.notify["highlight"].connect (() => {
            if (highlight)
                line_weight = initial_line_weight * 3.0;
            else
                line_weight = initial_line_weight;
        });
    }

    private void new_value_cb (string id, double value) {
        if (channel_isset) {
            /* Simple rotate left by one value */
            lock (buffer) {
                for (var i = 0; i < _buffer_size - 1; i++) {

                    buffer[i] = buffer[i + 1];
                }
                buffer[_buffer_size - 1] = value;
            }

            nth_sample++;

            /* Update the window with the required data */
            if (nth_sample >= stride) {

                lock (window) {
                    for (int i = 0; i < window.size; i++) {
                        int pos = buffer.length - (i * stride);
                        var point = _window.get ((window.size - 1) - i);
                        point.y = buffer[pos];
                    }
//                    int x = buffer.length - ((window.size - 1) * stride);
//                    stdout.printf ("buffer [%d] %.3f buffer [%d], %.3f\n",
//                                        buffer.length,
//                                        buffer[buffer.length],
//                                        buffer.length - 1,
//                                        buffer[buffer.length -1]);
                }
                nth_sample = 0;
            }
        }
    }
}

private class Dactl.StripChartCanvas : Dactl.Canvas {

    public weak Dactl.Axis t_axis { get; set; }

    public weak Dactl.Axis y_axis { get; set; }

    private Gee.Map<string, Dactl.Object> _traces;

    public Gee.Map<string, Dactl.Object> traces {
        get { return _traces; }
        set { _traces.set_all (value); }
    }

    private int padding_top = 10;
    private int padding_right = 10;
    private int padding_bottom = 10;
    private int padding_left = 10;

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

        _traces = new Gee.TreeMap<string, Dactl.StripChartTrace> ();
    }

    public StripChartCanvas () {
        set_size_request (320, 240);
    }

    private void update_padding () {

        /* Reset to defaults */
        padding_top = 10;
        padding_right = 10;
        padding_bottom = 10;
        padding_left = 10;

        var parent = get_parent ();

        if ((parent as Dactl.StripChart).flags.is_set (Dactl.ChartFlag.DRAW_TITLE))
            padding_top += 20;

        if (y_axis.flags.is_set (Dactl.AxisFlag.DRAW_LABEL))
            padding_left += 50;

        if (t_axis.flags.is_set (Dactl.AxisFlag.DRAW_LABEL))
            padding_bottom += 40;
    }

    /**
     * Draw callback.
     */
    public override bool draw (Cairo.Context cr) {

        var allocation = Gtk.Allocation ();
        var parent = get_parent ();

        cr.set_source_rgb (1, 1, 1);
        cr.paint ();

        this.get_allocation (out allocation);

        cr.rectangle (0.5, 0.5, allocation.width - 1, allocation.height - 1);
        cr.set_source_rgb (0, 0, 0);
        cr.set_line_width (1.0);
        cr.stroke ();

        update_padding ();

        var grid_x = padding_left;
        var grid_y = padding_top;
        var grid_w = allocation.width - padding_left - padding_right;
        var grid_h = allocation.height - padding_top - padding_bottom;

        cr.set_antialias (Cairo.Antialias.SUBPIXEL);

        /* Grid */
        if ((parent as Dactl.StripChart).flags.is_set (Dactl.ChartFlag.DRAW_GRID)) {
            var grid_surface = new Cairo.ImageSurface (Cairo.Format.ARGB32,
                                                       allocation.width,
                                                       allocation.height);
            var grid_color = Gdk.RGBA () {
                red = 0.5,
                green = 0.5,
                blue = 0.5,
                alpha = 1.0
            };
            /**
             * FIXME Strip chart should use a generic ChartGrid instead of StripChartGrid. This is here to allow for
             * code refactoring without breaking StripChart.
             */
            var grid = new Dactl.StripChartGrid (grid_surface);

            if ((parent as Dactl.StripChart).flags.is_set (Dactl.ChartFlag.DRAW_GRID_BORDER)) {
                grid.set_source_rgba (grid_color.red, grid_color.green, grid_color.blue, grid_color.alpha);
                grid.rectangle (0.5, 0.5, grid_w - 1, grid_h - 1);
                grid.set_line_width (1.0);
                grid.stroke ();
            }

            grid.draw (t_axis, y_axis, grid_color, grid_w, grid_h);

            cr.set_operator (Cairo.Operator.OVER);
            cr.set_source_surface (grid.get_target (), grid_x, grid_y);
            cr.paint ();
        }

        /* Axes */
        var t_axis_x = padding_left;
        var t_axis_y = padding_top + grid_h;
        var t_axis_surface = new Cairo.ImageSurface (Cairo.Format.ARGB32,
                                                     allocation.width,
                                                     allocation.height);
        var t_axis_ctx = new Dactl.AxisView (t_axis_surface);
        t_axis_ctx.draw (grid_w, 40, t_axis);

        cr.set_operator (Cairo.Operator.OVER);
        cr.set_source_surface (t_axis_ctx.get_target (), t_axis_x, t_axis_y);
        cr.paint ();

        var y_axis_x = padding_left - 40;
        var y_axis_y = padding_top;
        var y_axis_surface = new Cairo.ImageSurface (Cairo.Format.ARGB32,
                                                     allocation.width,
                                                     allocation.height);
        var y_axis_ctx = new Dactl.AxisView (y_axis_surface);
        y_axis_ctx.draw (40, grid_h, y_axis);

        cr.set_operator (Cairo.Operator.OVER);
        cr.set_source_surface (y_axis_ctx.get_target (), y_axis_x, y_axis_y);
        cr.paint ();

        /* Labels */
        cr.set_source_rgb (0.5, 0.5, 0.5);
        cr.select_font_face ("sans-serif", Cairo.FontSlant.NORMAL, Cairo.FontWeight.BOLD);
        cr.set_font_size (12);

        if ((parent as Dactl.StripChart).flags.is_set (Dactl.ChartFlag.DRAW_TITLE)) {
            cr.move_to (padding_left, padding_top - 5);
            cr.show_text ((parent as Dactl.StripChart).title);
        }

        if (t_axis.flags.is_set (Dactl.AxisFlag.DRAW_LABEL)) {
            if (t_axis.flags.is_set (Dactl.AxisFlag.ROTATE_LABEL)) {
                cr.save ();
                var font_extents = Cairo.FontExtents ();
                cr.font_extents (out font_extents);
                var text_extents = Cairo.TextExtents ();
                cr.text_extents (t_axis.label, out text_extents);
                cr.translate (padding_left + grid_w / 2, padding_top + grid_h + 40);
                cr.rotate (-1 * Math.PI / 2);
                cr.translate (-1 * text_extents.height / 2, font_extents.height / 2);
                cr.move_to (0, 0);
                cr.show_text (t_axis.label);
                cr.restore ();
            } else {
                cr.move_to (padding_left + grid_w / 2, padding_top + grid_h + 40);
                cr.show_text (t_axis.label);
            }
        }

        if (y_axis.flags.is_set (Dactl.AxisFlag.DRAW_LABEL)) {
            if (y_axis.flags.is_set (Dactl.AxisFlag.ROTATE_LABEL)) {
                cr.save ();
                var font_extents = Cairo.FontExtents ();
                cr.font_extents (out font_extents);
                var text_extents = Cairo.TextExtents ();
                cr.text_extents (y_axis.label, out text_extents);
                cr.translate (5, allocation.height / 2);
                cr.rotate (-1 * Math.PI / 2);
                cr.translate (-1 * text_extents.height / 2, font_extents.height / 2);
                cr.move_to (0, 0);
                cr.show_text (y_axis.label);
                cr.restore ();
            } else {
                cr.move_to (5, allocation.height / 2);
                cr.show_text (y_axis.label);
            }
        }

        /* Legend */

        /* Traces */
        var trace_surface = new Cairo.ImageSurface (Cairo.Format.ARGB32,
                                                    allocation.width,
                                                    allocation.height);
        foreach (var trace in traces.values) {

            //var data = (trace as Dactl.StripChartTrace).window.to_array ();
            Dactl.Point[] data = new Dactl.Point[(trace as Dactl.StripChartTrace).window_size + 1];
            //for (var i = 0; i < data.length - 1; i++) {
            for (var i = 0; i < data.length; i++) {
                var point = (trace as Dactl.StripChartTrace).window.get (i);
                data[i] = new Dactl.Point (0.0, point.y);
            }

            double trace_div = (double)grid_w / (double)(data.length - 1);

            /* Scale the points to pixel values */
            for (var i = 0; i < data.length; i++) {
                data[i].x = i * trace_div;
                double value = data[i].y;

                if (value > y_axis.max || value == double.NAN)
                    value = y_axis.max;
                else if (value < y_axis.min)
                    value = y_axis.min;
                data [i].y = grid_h * (1 - ((value - y_axis.min) /
                                                    (y_axis.max - y_axis.min)));
            }

            /*var color = Gdk.RGBA ();*/
            /*color.parse ((trace as Dactl.StripChartTrace).color_spec);*/
            var color = (trace as Dactl.StripChartTrace).color;

            switch ((trace as Dactl.StripChartTrace).draw_type) {
                case Dactl.TraceDrawType.BAR:
                    var stencil = new Dactl.Bar (trace_surface);
                    stencil.set_line_width ((trace as Dactl.StripChartTrace).line_weight);
                    stencil.set_source_rgba (color.red, color.green, color.blue, color.alpha);
                    var y_origin = grid_h * (1 - ((0 - y_axis.min) /
                                                    (y_axis.max - y_axis.min)));
                    if (y_origin > grid_h)
                        y_origin = grid_h;
                    else if (y_origin < 0)
                        y_origin = 0;
                    stencil.draw (data, new Dactl.Point (0.0, y_origin), true);
                    cr.set_operator (Cairo.Operator.OVER);
                    cr.set_source_surface (stencil.get_target (), grid_x, grid_y);
                    cr.paint ();
                    break;
                case Dactl.TraceDrawType.LINE:
                    var stencil = new Dactl.Line (trace_surface);
                    stencil.set_line_width ((trace as Dactl.StripChartTrace).line_weight);
                    stencil.set_source_rgba (color.red, color.green, color.blue, color.alpha);
                    stencil.draw (data);
                    cr.set_operator (Cairo.Operator.OVER);
                    cr.set_source_surface (stencil.get_target (), grid_x, grid_y);
                    cr.paint ();
                    break;
                case Dactl.TraceDrawType.POLYLINE:
                    var stencil = new Dactl.Polyline (trace_surface);
                    stencil.set_line_width ((trace as Dactl.StripChartTrace).line_weight);
                    stencil.set_source_rgba (color.red, color.green, color.blue, color.alpha);
                    stencil.draw (data);
                    cr.set_operator (Cairo.Operator.OVER);
                    cr.set_source_surface (stencil.get_target (), grid_x, grid_y);
                    cr.paint ();
                    break;
                case Dactl.TraceDrawType.SCATTER:
                    var stencil = new Dactl.Scatter (trace_surface);
                    stencil.set_line_width ((trace as Dactl.StripChartTrace).line_weight);
                    stencil.set_source_rgba (color.red, color.green, color.blue, color.alpha);
                    stencil.draw (data);
                    cr.set_operator (Cairo.Operator.OVER);
                    cr.set_source_surface (stencil.get_target (), grid_x, grid_y);
                    cr.paint ();
                    break;
                default:
                    assert_not_reached ();
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
        <object id=\"chart0\" type=\"stripchart\"/>
    """;

    private string _xsd = """
        <xs:element name="object">
          <xs:attribute name="id" type="xs:string" use="required"/>
          <xs:attribute name="type" type="xs:string" use="required"/>
          <xs:attribute name="ref" type="xs:string" use="required"/>
        </xs:element>
    """;

    /* Global variable that holds the maximum window size of all the traces */
    private int window_size_max = 0;
    /* Global variable that holds the mainimum stride of all the traces */
    private int stride_min = int.MAX;
    /* The number of data points per second */
    private double pps = 0;
    bool once = false;

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

    public Dactl.ChartFlag flags { get; set; }

    [GtkChild]
    private Dactl.StripChartCanvas canvas;

    [GtkChild]
    private Gtk.Revealer settings;

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
    private Gtk.Entry entry_time_axis;

    [GtkChild]
    private Gtk.SpinButton spinbutton_delta_t;

    [GtkChild]
    private Gtk.SpinButton spinbutton_points;

    [GtkChild]
    private Gtk.SpinButton spinbutton_t_major;

    [GtkChild]
    private Gtk.SpinButton spinbutton_t_minor;
    /**
     * Common object construction.
     */
    construct {
        id = "chart0";
        canvas.id = "%s-canvas0".printf (id);
        objects = new Gee.TreeMap<string, Dactl.Object> ();

        flags = Dactl.ChartFlag.DRAW_TITLE |
                Dactl.ChartFlag.DRAW_GRID |
                Dactl.ChartFlag.DRAW_GRID_BORDER;

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
                        case "points-per-second":
                            value = iter->get_content ();
                            pps = double.parse (value);
                            break;
                        default:
                            break;
                    }
                } else if (iter->name == "object") {
                    var type = iter->get_prop ("type");
                    if (type == "chart-axis") {
                        var axis = new Dactl.Axis.from_xml_node (iter);
                        this.add_child (axis);
                    } else if (type == "stripchart-trace") {
                        var trace = new Dactl.StripChartTrace.from_xml_node (iter);
                        this.add_child (trace);
                    }
                }
            }
        }
        if (pps == 0) {
            warning ("point-per-second (pps) is set to 0");
        }
        connect_notify_signals ();
    }

    /**
     * Connect all notify signals to update node
     */
    protected void connect_notify_signals () {
        Type type = get_type ();
        ObjectClass ocl = (ObjectClass)type.class_ref ();

        foreach (ParamSpec spec in ocl.list_properties ()) {
            notify[spec.get_name ()].connect ((s, p) => {
            debug ("type: %s spec: %s", type.name (), spec.get_name ());
                update_node ();
            });
        }
    }

    /**
     * Update XML node
     */
    protected void update_node () {
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
    public virtual void offer_cld_object (Cld.Object object) {
        var traces = get_object_map (typeof (Dactl.StripChartTrace));
        foreach (var trace in traces.values) {
            if ((trace as Dactl.StripChartTrace).ch_ref == object.uri) {
                message ("Assigning channel `%s' to `%s'", object.uri, trace.id);
                (trace as Dactl.StripChartTrace).channel = (object as Cld.Channel);
            }
            satisfied = (trace as Dactl.StripChartTrace).channel_isset;
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
        refresh ();
    }

    public void highlight_trace (string id) {
        var traces = get_object_map (typeof (Dactl.StripChartTrace));
        foreach (var trace in traces.values) {
            (trace as Dactl.StripChartTrace).highlight = false;
            if ((trace as Dactl.StripChartTrace).ch_ref == id) {
                debug ("Chart `%s' highlighting `%s'", this.id, id);
                (trace as Dactl.StripChartTrace).highlight = true;
            }
        }
    }

    private void update_layout () {
        var axes = get_object_map (typeof (Dactl.Axis));
        foreach (var axis in axes.values) {
            if ((axis as Dactl.Axis).orientation == Dactl.Orientation.HORIZONTAL)
                canvas.t_axis = axis as Dactl.Axis;
            else if ((axis as Dactl.Axis).orientation == Dactl.Orientation.VERTICAL)
                canvas.y_axis = axis as Dactl.Axis;
        }

        var traces = get_object_map (typeof (Dactl.StripChartTrace));
        canvas.traces = traces;
    }

    /**
     * {@inheritDoc}
     */
    protected async void request_data () {
        while (!satisfied) {
            var traces = get_object_map (typeof (Dactl.StripChartTrace));
            foreach (var trace in traces.values) {
                if (!(trace as Dactl.StripChartTrace).channel_isset)
                    request_object ((trace as Dactl.StripChartTrace).ch_ref);
            }
            // Try again in a second
            yield nap (1000);
        }
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

            /* Set all traces to have the same configuration */
            refresh ();
            settings.set_reveal_child (!settings.reveal_child);
        }


        return false;
    }

    private void refresh () {
        update_max_min ();

        var traces = get_children (typeof (Dactl.StripChartTrace));
        foreach (var trace in traces.values) {
            (trace as Dactl.StripChartTrace).window_size = window_size_max;
            if ((trace as Dactl.StripChartTrace).buffer_size < (window_size_max * stride_min)) {
                (trace as Dactl.StripChartTrace).buffer_size = window_size_max * stride_min;
            }
            (trace as Dactl.StripChartTrace).stride = stride_min;
        }

            entry_title.set_text (title);
            entry_y_axis.set_text (canvas.y_axis.label);
            entry_time_axis.set_text (canvas.t_axis.label);
            spinbutton_y_min.set_value (canvas.y_axis.min);
            spinbutton_y_max.set_value (canvas.y_axis.max);
            spinbutton_y_major.set_value (canvas.y_axis.div_major);
            spinbutton_y_minor.set_value (canvas.y_axis.div_minor);
            spinbutton_t_major.set_value (canvas.t_axis.div_major);
            spinbutton_t_minor.set_value (canvas.t_axis.div_minor);
            spinbutton_delta_t.set_value (canvas.t_axis.max - canvas.t_axis.min);
            spinbutton_points.set_value (window_size_max);
    }

    private void update_max_min () {
        window_size_max = 0;
        stride_min = int.MAX;

        var traces = get_children (typeof (Dactl.StripChartTrace));
        foreach (var trace in traces.values) {
            if ((trace as Dactl.StripChartTrace).window_size > window_size_max) {
                window_size_max = (trace as Dactl.StripChartTrace).window_size;
            }
            if ((trace as Dactl.StripChartTrace).stride < stride_min) {
                stride_min = (trace as Dactl.StripChartTrace).stride;
            }
        }
    }

    [GtkCallback]
    public bool canvas_button_release_event_cb (Gdk.EventButton event) {
        return false;
    }

    [GtkCallback]
    private void entry_title_activate_cb () {
        title = entry_title.get_text ();
    }

    [GtkCallback]
    private void entry_y_axis_activate_cb () {
        canvas.y_axis.label = entry_y_axis.get_text ();
    }

    [GtkCallback]
    private void spinbutton_y_min_value_changed_cb () {
        canvas.y_axis.min = spinbutton_y_min.get_value ();
    }

    [GtkCallback]
    private void spinbutton_y_max_value_changed_cb () {
        canvas.y_axis.max = spinbutton_y_max.get_value ();
    }

    [GtkCallback]
    private void spinbutton_y_major_value_changed_cb () {
        canvas.y_axis.div_major = spinbutton_y_major.get_value_as_int ();
    }

    [GtkCallback]
    private void spinbutton_y_minor_value_changed_cb () {
        canvas.y_axis.div_minor = spinbutton_y_minor.get_value_as_int ();
    }

    [GtkCallback]
    private void entry_time_axis_activate_cb () {
        canvas.t_axis.label = entry_time_axis.get_text ();
    }


    [GtkCallback]
    private void spinbutton_t_major_value_changed_cb () {
        canvas.t_axis.div_major = spinbutton_t_major.get_value_as_int ();
    }

    [GtkCallback]
    private void spinbutton_t_minor_value_changed_cb () {
        canvas.t_axis.div_minor = spinbutton_t_minor.get_value_as_int ();
    }

    [GtkCallback]
    private void spinbutton_delta_t_value_changed_cb () {
        double s;
        int stride_new;
        double dt_old = canvas.t_axis.max - canvas.t_axis.min;
        double dt_new = spinbutton_delta_t.get_value ();

        update_max_min ();

        s = pps * spinbutton_delta_t.get_value () / (double) window_size_max;
        stride_new = (int) GLib.Math.ceil (s);
        if (dt_old > dt_new) {
            stride_new -= 1;
        }

        stride_new = stride_new < 1 ? 1 : stride_new;
        canvas.t_axis.max = canvas.t_axis.min + window_size_max * stride_new / pps;
        var traces = get_children (typeof (Dactl.StripChartTrace));
        foreach (var trace in traces.values) {
            (trace as Dactl.StripChartTrace).stride = stride_new;
            if ((trace as Dactl.StripChartTrace).buffer_size < (window_size_max * stride_new)) {
                (trace as Dactl.StripChartTrace).buffer_size = window_size_max * stride_new;
            }
        }
        spinbutton_delta_t.set_value (canvas.t_axis.max - canvas.t_axis.min);
    }

    [GtkCallback]
    private void spinbutton_points_value_changed_cb () {

        int pts = spinbutton_points.get_value_as_int ();
        int pts_old;
        int win_buf;

        update_max_min ();
        pts = pts <=0 ? 1 : pts;
        win_buf = window_size_max * stride_min;

        var traces = get_children (typeof (Dactl.StripChartTrace));
        foreach (var trace in traces.values) {
            pts_old = (trace as Dactl.StripChartTrace).window_size;
            if (pts > win_buf) {
                pts = win_buf;
            }

            int num = win_buf / pts;
            if (pts_old > pts) {

                if ((win_buf % pts) != 0) {
                    for (int i = num + 1; i < win_buf; i ++) {
                        if ((win_buf % i) == 0) {
                            num = i;
                            break;
                        }
                    }
                }
            } else if (pts_old < pts) {

                for (int i = num; i > 0; i--) {
                    if ((win_buf % i) == 0) {
                        num = i;
                        break;
                    }
                }
            } else {

                num = win_buf / pts;
            }

            pts = win_buf / num;
            spinbutton_points.set_value (pts);
            (trace as Dactl.StripChartTrace).stride = (int) ((double) win_buf / (double) pts);
            (trace as Dactl.StripChartTrace).window_size = pts;
        }
    }
}
