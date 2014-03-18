/**
 * Trace data model class that is configurable using the application builder.
 */
public class Dactl.TraceModel : Dactl.AbstractBuildable {

    /**
     * {@inheritDoc}
     */
    public override string id { get; set; default = "trace0"; }

    public string ch_ref { get; set; }

    /**
     * Default construction.
     */
    public TraceModel () { }

    /**
     * Construction using an XML node.
     */
    public TraceModel.from_xml_node (Xml.Node *node) {
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

            /* Iterate through node children */
            for (Xml.Node *iter = node->children; iter != null; iter = iter->next) {
                if (iter->name == "property") {
                    switch (iter->get_prop ("name")) {
                        case "line-weight":
                            // = iter->get_content ();
                            break;
                        case "color":
                            // = iter->get_content ();
                            break;
                        default:
                            break;
                    }
                }
            }
        }
    }
}

/**
 * Trace class to perform the drawing.
 */
public class Dactl.TraceView : Clutter.Actor {

    /**
     * Backend data model used to configure the class.
     */
    public TraceModel model { get; private set; }

    public Clutter.Canvas canvas;

    construct {
        canvas = new Clutter.Canvas ();
        this.set_content (canvas);
    }

    /**
     * Default construction.
     */
    public TraceView () {
        model = new TraceModel ();
        connect_signals ();
    }

    /**
     * Construction using a provided data model.
     */
    public TraceView.with_model (TraceModel model) {
        this.model = model;
        connect_signals ();
    }

    /**
     * Connect any signals including the notifications from the model.
     */
    private void connect_signals () {

        canvas.draw.connect (on_draw);

        /*
         *model.notify["line_weight"].connect (() => {
         *    [> Change the line weight <]
         *});
         */
    }

    /**
     * Draw callback.
     */
    private bool on_draw (Cairo.Context cr, int w, int h) {

        cr.scale (w, h);
        cr.set_source_rgb (0, 0, 0);

        cr.paint();

        return true;
    }
}

public class Dactl.Trace : Dactl.AbstractObject {

    /* Property backing fields */
    private string _id;

    /**
     * {@inheritDoc}
     */
    public override string id {
        get { return model.id; }
        set { _id = model.id; }
    }

    public Dactl.TraceModel model { get; private set; }
    public Dactl.TraceView view { get; private set; }

    /**
     * Default construction.
     */
    public Trace () {
        model = new Dactl.TraceModel ();
        view = new Dactl.TraceView.with_model (model);
    }

    /**
     * Construction using a data model.
     */
    public Trace.with_model (Dactl.TraceModel model) {
        this.model = model;
        view = new Dactl.TraceView.with_model (model);
    }
}
