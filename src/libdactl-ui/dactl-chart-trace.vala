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
        try {
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
        } catch (GLib.RegexError e) {
            error (e.message);
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
    /*private Dactl.Drawable.XYPoint[] _raw_data;*/
    private Dactl.SimplePoint[] _raw_data;
    protected Gee.List<Dactl.Point> _pixel_data;
    protected double x_min;
    protected double x_max;
    protected double y_min;
    protected double y_max;
    protected int width = 100;
    protected int height = 100;
    public bool highlight { get; set; default = false; }

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
    protected virtual Dactl.SimplePoint[] raw_data {
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
    private string color_spec { get; set; default = "black"; }

    protected Gdk.RGBA _color;

    public Gdk.RGBA color  {
        get { return _color; }
        set {
            _color = value;
            color_spec = color.to_string ();
        }
    }

    construct {
        _pixel_data = new Gee.LinkedList<Dactl.Point> ();
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
    internal void build_from_xml_node (Xml.Node *node) {
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
        if (raw_data.length > 2) {
            if (this is Dactl.RTMultiChannelTrace)
                (this as Dactl.RTMultiChannelTrace).update ();
            else
                update ();
        }
    }

    /**
     * {@inheritDoc}
     */
    private void update () {
        /* scale the raw data to non-integer pixel values */
        double[] scaled_xdata = new double[raw_data.length];
        double[] scaled_ydata = new double[raw_data.length];

        /**
         * XXX FIXME It would be more efficient to only scale the data for the
         * points that are needed by the graph
         */
        bool strictly_increasing = false;
        for (int i = 0; i < raw_data.length; i++) {
            scaled_xdata[i] = width * (raw_data[i].x - x_min) / (x_max - x_min);
            if ((i == 0) || (scaled_xdata[i] > scaled_xdata[i - 1])) {
                strictly_increasing = true;
            } else {
                strictly_increasing = false;
            }
            scaled_ydata[i] = height * (1 - (raw_data[i].y - y_min) / (y_max - y_min));
        }
        if (!strictly_increasing)
            return;

        /* Interpolate the scaled data */

        Gsl.InterpAccel accel = new Gsl.InterpAccel ();
        /* XXX Make sure the prototype in the Gsl vapi uses a pointer for argument 1 */
        Gsl.Interp interp_y = new Gsl.Interp (Gsl.InterpTypes.linear, raw_data.length);

        interp_y.init (scaled_xdata, scaled_ydata, raw_data.length);

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
                /* Check if x value is inside the x range of the raw data */
                if ((x <= scaled_xdata[0]) || (x >= scaled_xdata[raw_data.length - 1])) {
                    deque.offer_tail (null);
                } else {
                    if (flags.is_set (Dactl.TraceFlag.SCROLL_LEFT))
                        point.x = width - x;
                    else
                        point.x = x;

                    point.y = (int)interp_y.eval (scaled_xdata, scaled_ydata, x, accel);
                    deque.offer_tail (point);
                }
            }
        }
    }

    /**
     * {@inheritDoc}
     */
    public void draw (Cairo.Context cr) {
        var weight = line_weight;
        if (highlight)
            weight = line_weight * 3;

        var data = pixel_data.to_array ();
        /* XXX FIXME Should not need to do this (remove the first non null data point) */
        /*
         *for (int i = 0; i < data.length; i++) {
         *    if ((data[i] == null) && (i > 2)) {
         *        data[i - 1] = null;
         *        break;
         *    }
         *}
         */

        switch (draw_type) {
            /*
             * XXX FIXME This code no longer works here.
             *case Dactl.TraceDrawType.BAR:
             *    var stencil = new Dactl.Bar (image_surface);
             *    stencil.set_line_width (weight);
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
                stencil.set_line_width (weight);
                stencil.set_source_rgba (color.red, color.green, color.blue, color.alpha);
                stencil.draw (data);
                cr.set_operator (Cairo.Operator.OVER);
                cr.set_source_surface (stencil.get_target (), 0, 0);
                cr.paint ();
                break;
            case Dactl.TraceDrawType.POLYLINE:
                /* XXX FIXME Polyline does not work with X_AXIS_REVERSED */
                var stencil = new Dactl.Polyline (image_surface);
                stencil.set_line_width (weight);
                stencil.set_source_rgba (color.red, color.green, color.blue, color.alpha);
                stencil.draw (data);
                cr.set_operator (Cairo.Operator.OVER);
                cr.set_source_surface (stencil.get_target (), 0, 0);
                cr.paint ();
                break;
            case Dactl.TraceDrawType.SCATTER:
                var stencil = new Dactl.Scatter (image_surface);
                stencil.set_line_width (weight);
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
