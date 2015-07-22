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

public class Dactl.Trace : GLib.Object, Dactl.Object, Dactl.Buildable {

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

    /* FIXME: Couldn't use a Gdk.RGBA here for some unknown reason */
    /**
     * Textual representation of the color to use, could be anything from
     * the file rgb.txt, a hexadecimal value as eg. #FFF/#FF00FF/#FF00FF00,
     * or decimal value as eg. rgb(255,0,255)/rgba(255,0,255,0.0).
     */
    public string color_spec { get; set; default = "black"; }

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

    private bool _show_avg = false;
    /**
     * Plot the averaged value if true
     */
    public bool show_avg {
        get { return _show_avg; }
        set { _show_avg = value; }
    }

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
    public Trace () {
        buffer = new double[buffer_size];
        connect_signals ();
    }

    /**
     * Construction using an XML node.
     */
    public Trace.from_xml_node (Xml.Node *node) {
        build_from_xml_node (node);
        buffer = new double[buffer_size];
        connect_signals ();
    }

    /**
     * {@inheritDoc}
     */
    public void build_from_xml_node (Xml.Node *node) {
        if (node->type == Xml.ElementType.ELEMENT_NODE &&
            node->type != Xml.ElementType.COMMENT_NODE) {
            id = node->get_prop ("id");
            ch_ref = node->get_prop ("ref");
            this.node = node;

            /* Iterate through node children */
            for (Xml.Node *iter = node->children; iter != null; iter = iter->next) {
                if (iter->name == "property") {
                    switch (iter->get_prop ("name")) {
                        case "show-avg":
                            _show_avg = bool.parse (iter->get_content ());
                            break;
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
                        case "show-avg":
                            iter->set_content ("%s".printf (show_avg.to_string ()));
                            break;
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
        /**
         * show the averaged value if flag is set
          */
        if (((channel.get_type ()).is_a (typeof (Cld.AChannel))) && show_avg) {
            var calibration = (channel as Cld.ScalableChannel).calibration;
            value = calibration.apply ((channel as Cld.AChannel).avg_value);
        }

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
