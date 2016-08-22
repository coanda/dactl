/**
 * Might need/want to convert this to a base class and create a
 * PnidTransducerElement, PnidTextElement, PnidVesselElement, etc. to interact
 * with the SVG in different ways.
 */
public class Dactl.PnidElement : GLib.Object, Dactl.Object, Dactl.Buildable {

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
    protected virtual Xml.Node* node {
        get {
            return _node;
        }
        set {
            _node = value;
        }
    }

    private weak Cld.Sensor _sensor;

    /**
     * {@inheritDoc}
     */
    public string id { get; set; default = "txt0"; }

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
     * The sensor reference that this text field wants to display.
     */
    public string cld_ref { get; set; }

    public Cld.Sensor sensor {
        get { return _sensor; }
        set {
            var tokens = cld_ref.split (":");
            if ((value as Cld.Object).uri == tokens[0]) {
                _sensor = value;
                sensor_isset = true;
            }
        }
    }

    /**
     * The SVG element reference that this text field will update.
     */
    public string svg_ref { get; set; }

    public string format { get; set; }

    public double value { get; private set; }

    public bool sensor_isset { get; private set; default = false; }

    public string ptype { get; set; }

    construct {
    }

    /**
     * Default construction.
     */
    public PnidElement () { }

    /**
     * Construction using data provided.
     */
    public PnidElement.with_data (string id, string cld_ref) {
        this.id = id;
        this.cld_ref = cld_ref;
    }

    /**
     * Construction using an XML node.
     */
    public PnidElement.from_xml_node (Xml.Node *node) {
        build_from_xml_node (node);

        notify["sensor-isset"].connect (() => {
            debug ("sensor-isset: `%s'", sensor_isset.to_string ());
        });
    }

    /**
     * {@inheritDoc}
     */
    internal void build_from_xml_node (Xml.Node *node) {
        if (node->type == Xml.ElementType.ELEMENT_NODE &&
            node->type != Xml.ElementType.COMMENT_NODE) {
            id = node->get_prop ("id");
            ptype = node->get_prop ("type");
            cld_ref = node->get_prop ("cld-ref");
            svg_ref = node->get_prop ("svg-ref");
            format = node->get_prop ("format");
        }
    }

    /**
     * Update XML node
     */
    protected void update_node () {
        /* Iterate through node children */
        for (Xml.Node *iter = node->children; iter != null; iter = iter->next) {
            if (iter->name == "property") {
                switch (iter->get_prop ("name")) {
                    case "cld-ref":
                        iter->set_content (cld_ref);
                        break;
                    case "svg-ref":
                        iter->set_content (svg_ref);
                        break;
                    default:
                        break;
                }
            }
        }
    }
}

private class Dactl.PnidCanvas : Dactl.Canvas {

    private Xml.Doc *doc;

    private Xml.XPath.Context *ctx;

    private Xml.XPath.Object *obj;

    public Gee.Map<string, Dactl.Object> elements { get; set; }

    private bool zoom = false;

    private int zoom_x;

    private int zoom_y;

    public PnidCanvas (string image_file) {
        string xmlstr;

        add_events (Gdk.EventMask.BUTTON_PRESS_MASK |
                    Gdk.EventMask.BUTTON_RELEASE_MASK |
                    Gdk.EventMask.POINTER_MOTION_MASK);

        elements = new Gee.TreeMap<string, Dactl.Object> ();

        /* Load the SVG file that is the PNID */
        doc = Xml.Parser.parse_file (image_file);
        ctx = new Xml.XPath.Context (doc);
        ctx->register_ns ("svg", "http://www.w3.org/2000/svg");
        ctx->register_ns ("xlink", "http://www.w3.org/1999/xlink");

        doc->dump_memory (out xmlstr);

        Rsvg.Handle svg;
        try {
            svg = new Rsvg.Handle.from_data (xmlstr.data);
        } catch (GLib.Error err) {
            error ("%s", err.message);
        }

        message ("Loaded SVG file `%s'", image_file);
        message ("SVG dimensions: %dx%d", svg.width, svg.height);

        set_size_request (svg.width, svg.height);

        update ();
    }

    /**
     * Draw callback.
     */
    public override bool draw (Cairo.Context cr) {

        string xmlstr, hi;

        // All of the SVG manipulations happen on each iteration, couldn't find
        // a more efficient way of using XPath on a file stream

        /**
         * Example changing the color of an SVG element:
         *
         *  obj = ctx->eval_expression ("//svg:defs/svg:linearGradient[@id=\"linearGradient162\"]/svg:stop[@id=\"stop164\"]");
         *  Xml.XPath.NodeSet *nodes = obj->nodesetval;
         *  Xml.Node *node = nodes->item (0);
         *  node->set_prop ("style", "stop-color:#00ffff;stop-opacity:1;");
         */

        foreach (var element in elements.values) {
            if ((element as Dactl.PnidElement).ptype == "pnid-text") {
                try {
                    var xpath = "//svg:text[@id=\"%s\"]/svg:tspan".printf ((element as Dactl.PnidElement).svg_ref);
                    obj = ctx->eval_expression (xpath);
                    var nodes = obj->nodesetval;
                    var node = nodes->item (0);

                    var tokens = (element as Dactl.PnidElement).cld_ref.split (":");
                    var prop = (tokens.length > 1) ? tokens[1] : "value";
                    debug (" > %s : %d", (element as Dactl.PnidElement).cld_ref, tokens.length);

                    /* Check if a property was requested, use the channel scaled value if not */
                    double fval;
                    (element as Dactl.PnidElement).sensor.get (prop, out fval);
                    string val ="";

                    if ((element as Dactl.PnidElement).format == null) {
                        val = "%.2f".printf (fval);
                    } else {
                        val = (element as Dactl.PnidElement).format.printf (fval);
                    }
                    var value = val;

                    debug ("%s - %s value: %s", tokens[0], prop, val);
                    node->set_content (value);
                } catch (Cld.XmlError e) {
                    warning (e.message);
                }
            } else if ((element as Dactl.PnidElement).ptype == "pnid-rect") {

                // Change the backgound color if in range
                var sp = (element as Dactl.PnidElement).sensor.threshold_sp;
                if (sp != double.NAN) {
                    try {
                        var xpath = "//svg:rect[@id=\"%s\"]".printf ("rect-"+(element as Dactl.PnidElement).svg_ref);
                        obj = ctx->eval_expression (xpath);
                        var nodes = obj->nodesetval;
                        var node = nodes->item (0);
                        var style = node->get_prop ("style");
                        Regex regex = new Regex ("fill:#......");
                        if ((element as Dactl.PnidElement).sensor.threshold_alarm_state) {
                            debug ("1) alarm state: %s", (element as Dactl.PnidElement).sensor.threshold_alarm_state.to_string());
                            style = regex.replace (style, style.length, 0, "fill:#00ff00");
                        } else {
                            debug ("2) alarm state: %s", (element as Dactl.PnidElement).sensor.threshold_alarm_state.to_string());
                            style = regex.replace (style, style.length, 0, "fill:#ffffff");
                        }
                        node->set_prop ("style", style);
                    } catch (Cld.XmlError e) {
                        warning (e.message);
                    }
                }
            }
        }

        doc->dump_memory (out xmlstr);
        Rsvg.Handle svg;
        try {
            svg = new Rsvg.Handle.from_data (xmlstr.data);
        } catch (GLib.Error err) {
            error ("%s", err.message);
        }

        /* Load the pixbuf backend */
        var pixbuf = svg.get_pixbuf ();

        var surface = Gdk.cairo_surface_create_from_pixbuf (pixbuf, 1, get_window ());
        cr.set_source_surface (surface, 0, 1);
        cr.paint ();

        if (zoom) {
            //var zoom_surface = new Cairo.Surface.similar (surface, Cairo.Content.COLOR, 120, 90);
            //var zoom_window = new Dactl.ZoomWindow (zoom_surface);
            //zoom_window.draw ();

            //cr.set_operator (Cairo.Operator.OVER);
            //cr.set_source_surface (zoom_window.get_target (), zoom_x, zoom_y);
            //cr.paint ();

            /* XXX not sure if this is worth the effort
             *var zoom_surface = new Cairo.ImageSurface (Cairo.Format.ARGB32, get_allocated_width (), get_allocated_height ());
             *var zoom_window = new Cairo.Context (zoom_surface);
             *cr.translate (-zoom_x, -zoom_y);
             *zoom_window.set_source_surface (cr.get_target (), zoom_x, zoom_y);
             *zoom_window.set_operator (Cairo.Operator.SOURCE);
             *zoom_window.paint ();
             *cr.translate (zoom_x, zoom_y);
             *zoom_window.set_source_rgba (0.0, 0.0, 0.0, 1.0);
             *zoom_window.set_line_width (1.0);
             *zoom_window.move_to (0, 0);
             *zoom_window.line_to (120, 0);
             *zoom_window.line_to (120, 90);
             *zoom_window.line_to (0, 90);
             *zoom_window.line_to (0, 0);
             *zoom_window.stroke ();
             *
             *cr.set_operator (Cairo.Operator.OVER);
             *cr.set_source_surface (zoom_window.get_target (), zoom_x, zoom_y);
             *cr.paint ();
             */
        }

        return false;
    }

    public override bool button_press_event (Gdk.EventButton event) {
        if (event.button == Gdk.BUTTON_PRIMARY)
            zoom = !zoom;

        return false;
    }

    public override bool button_release_event (Gdk.EventButton event) {
        return false;
    }

    public override bool motion_notify_event (Gdk.EventMotion event) {
        zoom_x = (int) event.x;
        zoom_y = (int) event.y;

        if (zoom)
            update ();

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

        var region = window.get_clip_region ();
        // redraw the cairo canvas completely by exposing it
        window.invalidate_region (region, true);
        window.process_updates (true);
    }
}

public class Dactl.Pnid : Dactl.CompositeWidget, Dactl.CldAdapter {

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
    public int timeout { get; set; default = 1000; }

    public string image_file { get; set; }

    private PnidCanvas canvas;

    public signal void channels_loaded ();

    /**
     * Common object construction.
     */
    construct {
        id = "pnid0";
        objects = new Gee.TreeMap<string, Dactl.Object> ();
    }

    /**
     * Default construction.
     */
    public Pnid (string image_file) {
        this.image_file = image_file;
        canvas = new PnidCanvas (image_file);
        canvas.id = "%s-canvas0".printf (id);
        add_child (canvas);
        add (canvas);

        // Request the required Cld data
        request_data.begin ();
    }

    /**
     * Construction using an XML node.
     */
    public Pnid.from_xml_node (Xml.Node *node) {
        build_from_xml_node (node);
        canvas = new PnidCanvas (image_file);
        canvas.id = "%s-canvas0".printf (id);
        add_child (canvas);
        add (canvas);

        // Request the required Cld data
        request_data.begin ();

        // FIXME: doing this means that only a PNID constructed this way can
        //        have elements that are updated through XPath
        canvas.elements = get_object_map (typeof (Dactl.PnidElement));
    }

    /**
     * {@inheritDoc}
     */
    public override void build_from_xml_node (Xml.Node *node) {
        if (node->type == Xml.ElementType.ELEMENT_NODE &&
            node->type != Xml.ElementType.COMMENT_NODE) {
            id = node->get_prop ("id");

            this.node = node;

            /* Iterate through node children */
            for (Xml.Node *iter = node->children; iter != null; iter = iter->next) {
                if (iter->name == "property") {
                    switch (iter->get_prop ("name")) {
                        case "image-file":
                            image_file = iter->get_content ();
                            break;
                        case "expand":
                            var value = iter->get_content ();
                            expand = bool.parse (value);
                            break;
                        case "fill":
                            var value = iter->get_content ();
                            fill = bool.parse (value);
                            break;
                        case "timeout":
                            var value = iter->get_content ();
                            timeout = int.parse (value);
                            break;
                        default:
                            break;
                    }
                } else if (iter->name == "object") {
                    var type = iter->get_prop ("type");
                    if (type == "pnid-text") {
                        var text = new PnidElement.from_xml_node (iter);
                        add_child (text);
                    } else if (type == "pnid-rect") {
                        var rect = new PnidElement.from_xml_node (iter);
                        add_child (rect);
                    }
                }
            }
        }
    }

    /**
     * {@inheritDoc}
     */
    public virtual void offer_cld_object (Cld.Object object) {
        message ("Offering CLD data `%s' to `%s'", object.id, id);

        var elements = get_object_map (typeof (Dactl.PnidElement));
        foreach (var element in elements.values) {
            var tokens = (element as Dactl.PnidElement).cld_ref.split (":");

            if (tokens[0] == object.uri) {
                message (" > Assigning `%s' to `%s'", object.uri, element.id);
                (element as Dactl.PnidElement).sensor = (object as Cld.Sensor);
            }
            satisfied = (element as Dactl.PnidElement).sensor_isset;
        }

        message ("PNID requirements for `%s' satisfied: %s", id, satisfied.to_string ());

        if (satisfied) {
            channels_loaded ();

            Timeout.add (timeout, update);
            show_all ();
        }
    }

    /**
     * {@inheritDoc}
     */
    protected async void request_data () {
        message ("Initiating CLD data request routine");
        while (!satisfied) {
            message (" > `%s' still not satisfied", id);
            var elements = get_object_map (typeof (Dactl.PnidElement));
            foreach (var element in elements.values) {
                if (!(element as Dactl.PnidElement).sensor_isset) {
                    message ("   > `%s' sensor_isset: %s",
                             element.id, (element as Dactl.PnidElement).sensor_isset.to_string ());
                    var tokens = (element as Dactl.PnidElement).cld_ref.split (":");
                    message ("   > Requesting object `%s' for `%s'", tokens[0], element.id);
                    request_object (tokens[0]);
                }
            }

            // Try again in a second
            yield nap (1000);
        }
        message ("`%s' satisfied now", id);
    }

    /**
     * Connect any signals including the notifications from the model.
     */
    private void connect_signals () {
        /*
         *canvas.draw.connect (on_draw);
         */
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
}
