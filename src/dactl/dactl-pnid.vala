public class Dactl.PnidText : Dactl.AbstractBuildable {

    /**
     * {@inheritDoc}
     */
    public override string id { get; set; default = "txt0"; }

    /**
     * The channel reference that this text field wants to display.
     */
    public string ch_ref { get; set; }

    public double value { get; set; }

    /**
     * Default construction.
     */
    public PnidText () { }

    /**
     * Construction using data provided.
     */
    public PnidText.with_data (string id, string ch_ref) {
        this.id = id;
        this.ch_ref = ch_ref;
    }

    /**
     * Construction using an XML node.
     */
    public PnidText.from_xml_node (Xml.Node *node) {
        build_from_xml_node (node);
    }

    /**
     * {@inheritDoc}
     */
    public override void build_from_xml_node (Xml.Node *node) {
        if (node->type == Xml.ElementType.ELEMENT_NODE &&
            node->type != Xml.ElementType.COMMENT_NODE) {
            id = node->get_prop ("id");
            ch_ref = node->get_prop ("chref");
        }
    }
}

public class Dactl.PnidModel : Dactl.AbstractContainer {

    /**
     * {@inheritDoc}
     */
    public override string id { get; set; default = "pnid0"; }

    /**
     * {@inheritDoc}
     */
    private Gee.Map<string, Dactl.Object> _objects;
    public override Gee.Map<string, Dactl.Object> objects {
        get { return _objects; }
        set { update_objects (value); }
    }

    /**
     * The list of channels that were connected during configuration.
     */
    private Gee.Map<string, Cld.Object> _channels;
    public Gee.Map<string, Cld.Object> channels {
        get { return _channels; }
        set { _channels = value; }
    }

    public string image { get; set; }

    /**
     * This seems like a sensible way for the model to request to have
     * external data added.
     */
    public signal void channel_request (string id);

    public signal void channels_loaded ();

    /**
     * Common object construction.
     */
    construct {
        objects = new Gee.TreeMap<string, Dactl.Object> ();
        channels = new Gee.TreeMap<string, Cld.Object> ();
    }

    /**
     * Default construction.
     */
    public PnidModel () { }

    /**
     * Construction using an XML node.
     */
    public PnidModel.from_xml_node (Xml.Node *node) {
        build_from_xml_node (node);
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
                        case "image":
                            image = iter->get_content ();
                            break;
                        default:
                            break;
                    }
                } else if (iter->name == "object") {
                    var type = iter->get_prop ("type");
                    if (type == "pnid-text") {
                        var text = new PnidText.from_xml_node (iter);
                        add (text);
                    }
                }
            }
        }
    }

    /**
     * {@inheritDoc}
     */
    public override void update_objects (Gee.Map<string, Dactl.Object> val) {
        _objects = val;
    }

    /**
     * Add a specific channel by requesting it from the parent data model. This
     * will probably not be used any time soon as configuration is typically
     * done through XML.
     */
    public void add_channel (string id) {
        channel_request (id);
    }

    /**
     * Iterates the list of objects and wherever a text value exists request the
     * Cld.Channel with the associated id.
     */
    public void add_channels () {
        foreach (var object in objects.values) {
            if (object is Dactl.PnidText) {
                GLib.message ("PNID `%s' requesting channel `%s'",
                              id, (object as Dactl.PnidText).ch_ref);
                channel_request ((object as Dactl.PnidText).ch_ref);
            }
        }

        /* XXX need to spawn an async thread waiting for the channels requested
         *     to be loaded, for now just testing without */
        channels_loaded ();
    }
}

public class Dactl.PnidView : Clutter.Actor {

    private Dactl.PnidModel model;

    private Clutter.Canvas canvas;

    private Clutter.Image image;

    private Xml.Doc *doc;

    private Xml.XPath.Context *ctx;

    private Xml.XPath.Object *obj;

    //private Rsvg.Handle svg;

    public signal void channel_selected (string id);

    construct {
        image = new Clutter.Image ();
        canvas = new Clutter.Canvas ();
        //set_content (canvas);
        set_content (image);
        set_content_gravity (Clutter.ContentGravity.CENTER);
        set_content_scaling_filters (Clutter.ScalingFilter.TRILINEAR, Clutter.ScalingFilter.LINEAR);
    }

    /**
     * Default construction.
     */
    public PnidView () {
        model = new Dactl.PnidModel ();
        setup_stage ();
        connect_signals ();
    }

    /**
     * Construction using a data model, mainly to connect to any signals.
     */
    public PnidView.with_model (Dactl.PnidModel model) {
        this.model = model;
        setup_stage ();
        connect_signals ();
    }

    private void setup_stage () {
        set_background_color (gdk_rgba_to_clutter_color (get_dactl_bg_color ()));

        var stage_bin = new Clutter.BinLayout (Clutter.BinAlignment.START,
                                               Clutter.BinAlignment.START);
        set_layout_manager (stage_bin);
        name = "dactl-pnid-%s".printf (model.id);

        var path = GLib.Path.build_filename (Config.UI_DIR, "pnid.svg");

        /* Load the SVG file that is the PNID */
        doc = Xml.Parser.parse_file (path);
        string xmlstr;
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

        GLib.message ("Loaded SVG file `%s'", path);
        GLib.message ("SVG dimensions: %dx%d", svg.height, svg.width);

        set_size (svg.width, svg.height);

        /* Load the pixbuf backend */
        var pixbuf = svg.get_pixbuf ();
        image.set_data (pixbuf.get_pixels (),
                        pixbuf.get_has_alpha ()
                            ? Cogl.PixelFormat.RGBA_8888
                            : Cogl.PixelFormat.RGB_888,
                        pixbuf.get_width (),
                        pixbuf.get_height (),
                        pixbuf.get_rowstride ());

        (image as Clutter.Content).invalidate ();
        //(canvas as Clutter.Content).invalidate ();
    }

    /**
     * Connect any signals including the notifications from the model.
     */
    private void connect_signals () {
        canvas.draw.connect (on_draw);
        Clutter.Threads.Timeout.add (1000, update);
    }

    /**
     * Draw callback.
     */
    private bool on_draw (Cairo.Context cr, int w, int h) {
        cr.scale (w, h);
        cr.save ();
        //cr.set_operator (Cairo.Operator.CLEAR);
        cr.set_source_rgb (255, 255, 255);
        cr.paint();
        cr.restore ();

        return true;
    }

    /**
     * Callback to perform on the timeout interval.
     */
    private bool update () {
        (canvas as Clutter.Content).invalidate ();

        string xmlstr;

        obj = ctx->eval_expression ("//svg:defs/svg:linearGradient[@id=\"linearGradient162\"]/svg:stop[@id=\"stop164\"]");
        Xml.XPath.NodeSet *nodes = obj->nodesetval;
        Xml.Node *node = nodes->item (0);
        node->set_prop ("style", "stop-color:#00ffff;stop-opacity:1;");

        doc->dump_memory (out xmlstr);
        Rsvg.Handle svg;
        try {
            svg = new Rsvg.Handle.from_data (xmlstr.data);
        } catch (GLib.Error err) {
            error ("%s", err.message);
        }

        var pixbuf = svg.get_pixbuf ();
        image.set_data (pixbuf.get_pixels (),
                        pixbuf.has_alpha
                            ? Cogl.PixelFormat.RGBA_8888
                            : Cogl.PixelFormat.RGB_888,
                        pixbuf.width,
                        pixbuf.height,
                        pixbuf.rowstride);

        (image as Clutter.Content).invalidate ();

        return true;
    }
}

public class Dactl.Pnid : Dactl.AbstractContainer {

    /**
     * {@inheritDoc}
     */
    public override string id {
        get { return model.id; }
        set { model.id = value; }
    }

    /**
     * {@inheritDoc}
     */
    public override Gee.Map<string, Dactl.Object> objects {
        get { return model.objects; }
        set { update_objects (value); }
    }

    public Dactl.PnidModel model { get; private set; }
    public Dactl.PnidView view { get; private set; }

    /**
     * Default construction.
     *
     * XXX currently not possible to create a view without a list of channels
     */
    public Pnid () { }

    /**
     * Construction using a data model.
     */
    public Pnid.with_model (Dactl.PnidModel model) {
        this.model = model;
        /* Can't create the view until the channel map has been loaded */
        this.model.channels_loaded.connect (() => {
            view = new Dactl.PnidView.with_model (model);
        });
    }

    /**
     * {@inheritDoc}
     */
    public override void update_objects (Gee.Map<string, Dactl.Object> val) {
        model.objects = val;
    }
}
