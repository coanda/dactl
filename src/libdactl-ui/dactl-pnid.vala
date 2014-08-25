/**
 * Might need/want to convert this to a base class and create a
 * PnidTransducerElement, PnidTextElement, PnidVesselElement, etc. to interact
 * with the SVG in different ways.
 */
public class Dactl.PnidElement : GLib.Object, Dactl.Object, Dactl.Buildable {

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

    private weak Cld.Channel _channel;

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
     * The channel reference that this text field wants to display.
     */
    public string ch_ref { get; set; }

    public Cld.Channel channel {
        get { return _channel; }
        set {
            if ((value as Cld.Object).uri == ch_ref) {
                _channel = value;
                channel_isset = true;
            }
        }
    }

    /**
     * The SVG element reference that this text field will update.
     */
    public string svg_ref { get; set; }

    public double value { get; private set; }

    public bool channel_isset { get; private set; default = false; }

    /**
     * Default construction.
     */
    public PnidElement () { }

    /**
     * Construction using data provided.
     */
    public PnidElement.with_data (string id, string ch_ref) {
        this.id = id;
        this.ch_ref = ch_ref;
    }

    /**
     * Construction using an XML node.
     */
    public PnidElement.from_xml_node (Xml.Node *node) {
        build_from_xml_node (node);
    }

    /**
     * {@inheritDoc}
     */
    public void build_from_xml_node (Xml.Node *node) {
        if (node->type == Xml.ElementType.ELEMENT_NODE &&
            node->type != Xml.ElementType.COMMENT_NODE) {
            id = node->get_prop ("id");
            ch_ref = node->get_prop ("chref");
            svg_ref = node->get_prop ("svgref");
        }
    }
}

private class Dactl.PnidCanvas : Dactl.CustomWidget {

    /**
     * {@inheritDoc}
     */
    protected override string xml { get { return "<object />"; } }

    /**
     * {@inheritDoc}
     */
    protected override string xsd { get { return "<object />"; } }

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

        GLib.message ("Loaded SVG file `%s'", image_file);
        GLib.message ("SVG dimensions: %dx%d", svg.width, svg.height);

        set_size_request (svg.width, svg.height);

        update ();
    }

    // FIXME: Didn't expect to need internal CustomWidget classes
    public override void build_from_xml_node (Xml.Node *node) { }

    /**
     * Draw callback.
     */
    public override bool draw (Cairo.Context cr) {

        string xmlstr;

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
            try {
                var xpath = "//svg:text[@id=\"%s\"]/svg:tspan".printf ((element as Dactl.PnidElement).svg_ref);
                obj = ctx->eval_expression (xpath);
                var nodes = obj->nodesetval;
                var node = nodes->item (0);
                var value = "%.2f".printf (((element as Dactl.PnidElement).channel as Cld.ScalableChannel).scaled_value);
                node->set_content (value);
            } catch (Cld.XmlError e) {
                warning (e.message);
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
                    }
                }
            }
        }
    }

    /**
     * {@inheritDoc}
     */
    public virtual void offer_cld_object (Cld.Object object) {
        var elements = get_object_map (typeof (Dactl.PnidElement));
        foreach (var element in elements.values) {
            if ((element as Dactl.PnidElement).ch_ref == object.uri) {
                message ("Assigning channel `%s' to `%s'", object.uri, element.id);
                (element as Dactl.PnidElement).channel = (object as Cld.Channel);
            }
            satisfied = (element as Dactl.PnidElement).channel_isset;
        }

        message ("PNID requirements satisfied: %s", satisfied.to_string ());

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
        while (!satisfied) {
            var entries = get_object_map (typeof (Dactl.PnidElement));
            foreach (var entry in entries.values) {
                if (!(entry as Dactl.PnidElement).channel_isset)
                    request_object ((entry as Dactl.PnidElement).ch_ref);
            }
            // Try again in a second
            yield nap (1000);
        }
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
