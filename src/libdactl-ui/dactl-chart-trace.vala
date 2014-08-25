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

    public bool channel_isset { get; private set; default = false; }

    /**
     * Timeout in milliseconds duration to accumulate values over.
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
                        buffer.resize (n);
                    } else {
                        buffer.resize (n);
                        for (int i = 0; i < n - _buffer_size; i++) {
                            for (int j = n; j > 0; j--)
                                buffer[i] = buffer[j - 1];
                            buffer[0] = 0.0;
                        }
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
            if (value != _window_size) {
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
            }
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
        set { _stride = (value > 0) ? value : 1; }
    }

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
    public Trace () {
        buffer = new double[buffer_size];
    }

    /**
     * Construction using an XML node.
     */
    public Trace.from_xml_node (Xml.Node *node) {
        build_from_xml_node (node);
        buffer = new double[buffer_size];
    }

    /**
     * {@inheritDoc}
     */
    public void build_from_xml_node (Xml.Node *node) {
        if (node->type == Xml.ElementType.ELEMENT_NODE &&
            node->type != Xml.ElementType.COMMENT_NODE) {
            id = node->get_prop ("id");
            ch_ref = node->get_prop ("ref");

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

            /* Update the window with the required data */
            lock (window) {
                /*
                 *for (int i = 0; i < _window_size; i++) {
                 *    int offset = _buffer_size - ((_window_size - 1) * stride);
                 *    int pos = offset + (i * stride);
                 *    var point = _window.get (i);
                 *    point.y = buffer[pos];
                 *}
                 */

                for (int i = 0; i < window.size; i++) {

                    /* source */
                    int pos = buffer.length - (i * stride);
                    var point = _window.get ((window.size - 1) - i);
                    point.y = buffer[pos];
//                    if (this.id == "test-tr0") {
//                        stdout.printf ("i: %d trace: %s channel: %s time_us: %lld y: %.3f \n",
//                                            i, this.channel.uri, this.id, GLib.get_monotonic_time (), point.y);
//                    }
                }
            }

                /*
                stdout.printf ("%.3f %.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f\n",
                    window[window_size-10].y,
                    window[window_size-9].y,
                    window[window_size-8].y,
                    window[window_size-7].y,
                    window[window_size-6].y,
                    window[window_size-5].y,
                    window[window_size-4].y,
                    window[window_size-3].y,
                    window[window_size-2].y,
                    window[window_size-1].y,
                    window[window_size].y);
                */
        }
    }
}
