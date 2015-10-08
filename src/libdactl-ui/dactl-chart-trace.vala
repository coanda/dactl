[Flags]
public enum Dactl.TraceFlag {
    SCROLL_LEFT          = 0x001;

    public Dactl.TraceFlag set (Dactl.TraceFlag flag) {
        return (this | flag);
    }

    public Dactl.TraceFlag unset (Dactl.TraceFlag flag) {
        return (this & ~flag);
    }

    public bool is_set (Dactl.TraceFlag flag) {
        return (flag in this);
    }
}

public enum Dactl.TraceDrawType {
    BAR,
    LINE,
    POLYLINE,
    SCATTER;

    public string to_string () {
        switch (this) {
            case BAR:      return "bar";
            case LINE:     return "line";
            case POLYLINE: return "polyline";
            case SCATTER:  return "scatter";
            default: assert_not_reached ();
        }
    }

    public static TraceDrawType parse (string value) {
        var regex = new Regex ("bar|line|polyline|scatter",
                               RegexCompileFlags.CASELESS, 0);
        MatchInfo match;
        regex.match (value, 0, out match);
        switch (match.fetch (0)) {
            case "bar":      return BAR;
            case "line":     return LINE;
            case "polyline": return POLYLINE;
            case "scatter":  return SCATTER;
        }

        return LINE;
    }

    public static TraceDrawType[] all () {
        return { BAR, LINE, POLYLINE, SCATTER };
    }
}

/**
 * A graphical representation of  ordered pair data
 * XXX TBD This only works for increasing values of x. A more general approach
 * would be to interpolate both x and y to a third vatiable, t, the plot x
 * versus y.
 *
 * Setting the x-axis-reversed property causes the axix values to be increasing
 * to the left.
 */
public class Dactl.Trace : GLib.Object, Dactl.Object,
                                               Dactl.Buildable, Dactl.Drawable {

    private Xml.Node* _node;
    private Dactl.Point[] _raw_data;
    protected Gee.List<Dactl.Point> _pixel_data;
    private double x_min;
    private double x_max;
    private double y_min;
    private double y_max;
    private int width = 100;
    private int height = 100;

    private string _xml = """
        <ui:object id=\"trace-0\" type=\"chart-trace\" ttype=\"xy\"/>
          <ui:property name=\"points\">100</ui:property>
          <ui:property name=\"draw-type\">line</ui:property>
          <ui:property name=\"line-weight\">1</ui:property>
          <ui:property name=\"color\">red</ui:property>
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
    protected string xml {
        get { return _xml; }
    }

    /**
     * {@inheritDoc}
     */
    protected string xsd {
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

    /**
     * {@inheritDoc}
     */
    protected virtual Dactl.Point[] raw_data {
        get {
            return _raw_data;
        }
        set {
            _raw_data = value;
        }
    }

    /**
     * {@inheritDoc}
     */
    protected virtual Gee.List<Dactl.Point> pixel_data {
        get {
            return _pixel_data;
        }
        set {
            _pixel_data = value;
        }
    }

    /**
     * {@inheritDoc}
     */
    public string id { get; set; default = "trace0"; }

    /**
     * The number of data points in the trace
     */
    private int _points;
    public int points {
        get { return _points; }
        set {
            _points = value;
        }
    }

    public Dactl.TraceFlag flags { get; set; }

    /**
     * {@inheritDoc}
     */
    public unowned Cairo.ImageSurface image_surface { get; set; }

    /**
     * Which simple drawing type to use to display the trace data.
     */
    public Dactl.TraceDrawType draw_type { get; set; default = Dactl.TraceDrawType.BAR; }

    /**
     * Line width to use for drawing.
     */
    public double line_weight { get; set; default = 1.0; }

    protected double initial_line_weight = 1.0;

    /**
     * Textual representation of the color to use, could be anything from
     * the file rgb.txt, a hexadecimal value as eg. #FFF/#FF00FF/#FF00FF00,
     * or decimal value as eg. rgb(255,0,255)/rgba(255,0,255,0.0).
     */
    protected string color_spec { get; set; default = "black"; }

    protected Gdk.RGBA _color;

    public Gdk.RGBA color  {
        get { return _color; }
        set {
            _color = value;
            color_spec = color.to_string ();
        }
    }

    /**
     * Construction using an XML node.
     */
    public Trace.from_xml_node (Xml.Node *node) {
        build_from_xml_node (node);
    }

    /**
     * {@inheritDoc}
     */
    public void build_from_xml_node (Xml.Node *node) {
        if (node->type == Xml.ElementType.ELEMENT_NODE &&
            node->type != Xml.ElementType.COMMENT_NODE) {
            id = node->get_prop ("id");
            this.node = node;

            /* Iterate through node children */
            for (Xml.Node *iter = node->children; iter != null; iter = iter->next) {
                if (iter->name == "property") {
                    switch (iter->get_prop ("name")) {
                        case "points":
                            points = int.parse (iter->get_content ());
                            _pixel_data = new Gee.LinkedList<Dactl.Point> ();
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
            debug ("type: %s spec: %s", type.name (), spec.get_name ());
                update_node ();
            });
        }
    }

    /**
     * {@inheritDoc}
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
                        case "points":
                            iter->set_content (points.to_string ());
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
    private void generate (int w, int h,
                           double x_min, double x_max,
                           double y_min, double y_max) {
        this.x_min = x_min;
        this.x_max = x_max;
        this.y_min = y_min;
        this.y_max = y_max;
        width = w;
        height = h;
        if (raw_data != null)
            update ();
    }

    /**
     * Update the chart data array
     */
    public void update () {
        /* scale the raw data to non-integer pixel values */
        double[] scaled_xdata = new double[raw_data.length];
        double[] scaled_ydata = new double[raw_data.length];
        double[] tdata = new double[raw_data.length];

        debug ("width: %d\theight: %d", width, height);
        /**
         * XXX FIXME It would be more efficient to only scale the data for the
         * points that are needed by the graph
         */
        for (int i = 0; i < raw_data.length; i++) {
            scaled_xdata[i] = width * (raw_data[i].x - x_min) / (x_max - x_min);
            scaled_ydata[i] = height * (1 - (raw_data[i].y - y_min) / (y_max - y_min));
            tdata[i] =  i;
            /*
             *message ("t: %.3f  x:%.3f: %.3f   y:%.3f: %.3f",tdata[i], raw_data[i].x,
             *                                    scaled_xdata[i],
             *                                    raw_data[i].y,
             *                                    scaled_ydata[i]);
             */
        }

        /* Interpolate the scaled data */
        Gsl.InterpAccel accel = new Gsl.InterpAccel ();
        /* XXX Make sure the prototype in the Gsl vapi uses a pointer for argument 1 */
        /*Gsl.Interp interp_x = new Gsl.Interp (Gsl.InterpTypes.linear, raw_data.length);*/
        Gsl.Interp interp_y = new Gsl.Interp (Gsl.InterpTypes.linear, raw_data.length);
        /*interp_x.init (tdata, scaled_xdata, raw_data.length);*/
        interp_y.init (scaled_xdata, scaled_ydata, raw_data.length);
        /*interp_y.init (tdata, scaled_ydata, raw_data.length);*/
        /*
         *Gsl.Spline spline = new Gsl.Spline (Gsl.InterpTypes.cspline, raw_data.length);
         *spline.init (scaled_xdata, scaled_ydata, raw_data.length);
         */

        /* Compute new pixel data */
        lock (pixel_data) {
            pixel_data.clear ();
            for (int i = 0; i < points; i++) {
                var x = (int)(i * width / (points - 1));
                var t1 = accel.find (scaled_xdata, x);
                var x1 = scaled_xdata[t1];
                var x2 = scaled_xdata[t1 + 1];
                var t =(double)t1 * (1 + (x - x1)/(x2 - x1));
                var deque = pixel_data as Gee.Deque<Dactl.Point>;
                var point = new Dactl.Point (0, 0);
/*
 *                if ((t <= tdata[0]) || (t >= tdata[raw_data.length - 1])) {
 *                    deque.offer_tail (null);
 *                } else {
 *
 *                    point.x = (int)interp_x.eval (tdata, scaled_xdata, t, accel);
 *                    point.y = (int)interp_y.eval (tdata, scaled_ydata, t, accel);
 *                    deque.offer_tail (point);
 *                }
 */
                /* Check if x value is inside the x range of the raw data */
                if ((x <= scaled_xdata[0]) || (x >= scaled_xdata[raw_data.length - 1])) {
                    deque.offer_tail (null);
                } else {
                    if (flags.is_set (Dactl.TraceFlag.SCROLL_LEFT))
                        point.x = width - x;
                    else
                        point.x = x;

                    debug ("x: %d scaled x: %.3f -> %.3f", x, scaled_xdata[0]
                                           , scaled_xdata[raw_data.length - 1]);
                    /*point.y = (int)spline.eval (point.x, accel_y);*/
                    point.y = (int)interp_y.eval (scaled_xdata, scaled_ydata, x, accel);
                    deque.offer_tail (point);
                }
                debug ("%d/%d: t: %.3f  x: %.3f y: %.3f", i + 1, points, t, point.x, point.y);
            }
        }
    }

    /**
     * {@inheritDoc}
     */
    public void draw (Cairo.Context cr) {
        /*
         *var trace_surface = new Cairo.ImageSurface (Cairo.Format.ARGB32,
         *                                                         width, height);
         */
        var data = pixel_data.to_array ();

        switch (draw_type) {
            /*
             * XXX FIXME This code no longer works here.
             *case Dactl.TraceDrawType.BAR:
             *    var stencil = new Dactl.Bar (image_surface);
             *    stencil.set_line_width (line_weight);
             *    stencil.set_source_rgba (color.red, color.green, color.blue, color.alpha);
             *    var y_origin = grid_h * (1 - ((0 - y_axis.min) /
             *                                    (y_axis.max - y_axis.min)));
             *    if (y_origin > grid_h)
             *        y_origin = grid_h;
             *    else if (y_origin < 0)
             *        y_origin = 0;
             *    stencil.draw (data, new Dactl.Point (0.0, y_origin), true);
             *    cr.set_operator (Cairo.Operator.OVER);
             *    cr.set_source_surface (stencil.get_target (), 0, 0);
             *    cr.paint ();
             *    break;
             */
            case Dactl.TraceDrawType.LINE:
                var stencil = new Dactl.Line (image_surface);
                stencil.set_line_width (line_weight);
                stencil.set_source_rgba (color.red, color.green, color.blue, color.alpha);
                stencil.draw (data);
                cr.set_operator (Cairo.Operator.OVER);
                cr.set_source_surface (stencil.get_target (), 0, 0);
                cr.paint ();
                break;
            case Dactl.TraceDrawType.POLYLINE:
                /* XXX FIXME Polyline does not work with X_AXIS_REVERSED */
                var stencil = new Dactl.Polyline (image_surface);
                stencil.set_line_width (line_weight);
                stencil.set_source_rgba (color.red, color.green, color.blue, color.alpha);
                stencil.draw (data);
                cr.set_operator (Cairo.Operator.OVER);
                cr.set_source_surface (stencil.get_target (), 0, 0);
                cr.paint ();
                break;
            case Dactl.TraceDrawType.SCATTER:
                var stencil = new Dactl.Scatter (image_surface);
                stencil.set_line_width (line_weight);
                stencil.set_source_rgba (color.red, color.green, color.blue, color.alpha);
                stencil.draw (data);
                cr.set_operator (Cairo.Operator.OVER);
                cr.set_source_surface (stencil.get_target (), 0, 0);
                cr.paint ();
                break;
            default:
                assert_not_reached ();
        }

    }
}

/**
 * A chart trace that accesses a dataseries
 */
public class Dactl.RTTrace : Dactl.Trace, Dactl.Container {

    private Gee.Map<string, Dactl.Object> _objects;
    public Dactl.DataSeries dataseries { get; private set; }
    public bool highlight { get; set; default = false; }


    /**
     * {@inheritDoc}
     */
    public Gee.Map<string, Dactl.Object> objects {
        get { return _objects; }
        set { update_objects (value); }
    }

    construct {
        objects = new Gee.TreeMap<string, Dactl.Object> ();
        connect_signals ();
    }

    public RTTrace (Xml.Ns* ns,
                    string id,
                    int points,
                    Dactl.TraceDrawType draw_type,
                    int line_weight,
                    Gdk.RGBA color) {

        this.id = id;
        this.points = points;
        this.draw_type = draw_type;
        this.line_weight = line_weight;
        this.color = color;

        this.node = new Xml.Node (ns, id);
        node->new_prop ("id", id);
        node->new_prop ("type", "trace");
        node->new_prop ("ttype", "real-time");

        Xml.Node* color_node = new Xml.Node (ns, "property");
        color_node->new_prop ("name", "color");
        color_node->add_content (color.to_string ());

        node->add_child (color_node);
    }

    /**
     * Construction using an XML node.
     */
    public RTTrace.from_xml_node (Xml.Node *node) {
        base.from_xml_node (node);
        build_from_xml_node (node);
    }

    /**
     * {@inheritDoc}
     */
    public void build_from_xml_node (Xml.Node *node) {
        if (node->type == Xml.ElementType.ELEMENT_NODE &&
            node->type != Xml.ElementType.COMMENT_NODE) {
            this.node = node;
            id = node->get_prop ("id");
            /* Iterate through node children */
            for (Xml.Node *iter = node->children; iter != null; iter = iter->next) {
                if (iter->name == "property") {
                    switch (iter->get_prop ("name")) {
                        /* XXX TBD */
                        /*
                         *case "":
                         *    break;
                         */
                        default:
                            break;
                    }
                } else if (iter->name == "object") {
                    var type = iter->get_prop ("type");
                    if (type == "dataseries") {
                        dataseries = new Dactl.DataSeries.from_xml_node (iter);
                        this.add_child (dataseries);
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

    /**
     * Update the data and redraw the trace
     */
    public void refresh () {
        double sum = 0;

        var ds_array = dataseries.to_array ();
        var _raw = new Dactl.Point[ds_array.length];
        double total = 0;
        /*
         *foreach (var point in ds_array) {
         *    total += point.x;
         *}
         *var dx = 1e-6 * total / ds_array.length;
         */
        /* offset the x value by 2 samples to allow for end point interpolation */
        if (ds_array.length > 2)
            sum = -1 * (ds_array[0].x + ds_array[1].x) / 1e6;
        for (int t = 0; t < ds_array.length; t++) {
            var x = ds_array[t].x / 1e6;
            /* Convert to seconds and accumulate */
            var test = sum;
            sum = sum + x;
            var y = ds_array[t].y;
            /*debug ("%.3f   %.3f", x, y);*/
            var point = new Dactl.Point (sum, y);
            _raw[t] = point;
        }
        debug ("raw length: %d", raw_data.length);

        if (_raw.length > 5) {
            raw_data = _raw;
        }
    }

    /**
     * {@inheritDoc}
     */
    public void update_objects (Gee.Map<string, Dactl.Object> val) {
        _objects = val;
    }
}
