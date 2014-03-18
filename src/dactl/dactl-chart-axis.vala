/**
 * Chart data model class that is configurable using the application builder.
 */
public class Dactl.AxisModel : Dactl.AbstractBuildable {

    /**
     * {@inheritDoc}
     */
    public override string id { get; set; default = "chart0"; }

    /* Axis label */
    public string label { get; set; default = "Axis"; }

    /* Orientation of the axis */
    public Axis.Orientation orientation { get; set; default = Axis.Orientation.HORIZONTAL; }

    public int min { get; set; }

    public int max { get; set; }

    public int div_major { get; set; }

    public int div_minor { get; set; }

    /**
     * Default construction.
     */
    public AxisModel () { }

    /**
     * Construction using an XML node.
     */
    public AxisModel.from_xml_node (Xml.Node *node) {
        build_from_xml_node (node);
    }

    /**
     * {@inheritDoc}
     */
    public override void build_from_xml_node (Xml.Node *node) {

        string value;

        if (node->type == Xml.ElementType.ELEMENT_NODE &&
            node->type != Xml.ElementType.COMMENT_NODE) {
            id = node->get_prop ("id");

            /* Iterate through node children */
            for (Xml.Node *iter = node->children; iter != null; iter = iter->next) {
                if (iter->name == "property") {
                    switch (iter->get_prop ("name")) {
                        case "label":
                            label = iter->get_content ();
                            break;
                        case "orientation":
                            value = iter->get_content ();
                            orientation = Axis.Orientation.parse (value);
                            break;
                        case "min":
                            value = iter->get_content ();
                            min = int.parse (value);
                            break;
                        case "max":
                            value = iter->get_content ();
                            max = int.parse (value);
                            break;
                        case "div-major":
                            value = iter->get_content ();
                            div_major = int.parse (value);
                            break;
                        case "div-minor":
                            value = iter->get_content ();
                            div_minor = int.parse (value);
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
 * Axis class to perform the drawing.
 *
 * XXX see here for example - http://goo.gl/UBq7cM
 */
public class Dactl.AxisView : Clutter.Actor {

    /**
     * Backend data model used to configure the class.
     */
    public AxisModel model { get; private set; }

    public Clutter.Canvas canvas;

    construct {
        canvas = new Clutter.Canvas ();
        this.set_content (canvas);
    }

    /**
     * Default construction.
     */
    public AxisView () {
        model = new AxisModel ();
        connect_signals ();
    }

    /**
     * Construction using a provided data model.
     */
    public AxisView.with_model (AxisModel model) {
        this.model = model;
        connect_signals ();
    }

    /**
     * Connect any signals including the notifications from the model.
     */
    private void connect_signals () {

        canvas.draw.connect (on_draw);

        model.notify["label"].connect (() => {
            /* Change the label */
        });
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

public class Dactl.Axis : Dactl.AbstractObject {

    /**
     * Orientation options for the axis.
     */
    public enum Orientation {
        HORIZONTAL,
        VERTICAL;

        public string to_string () {
            switch (this) {
                case HORIZONTAL: return "horizontal";
                case VERTICAL:   return "vertical";
                default: assert_not_reached ();
            }
        }

        public static Orientation[] all () {
            return {
                HORIZONTAL,
                VERTICAL
            };
        }

        public static Orientation parse (string value) {
            try {
                var regex_horiz = new Regex ("horizontal", RegexCompileFlags.CASELESS);
                var regex_vert = new Regex ("vertical", RegexCompileFlags.CASELESS);
                if (regex_horiz.match (value)) {
                    return HORIZONTAL;
                } else if (regex_vert.match (value)) {
                    return VERTICAL;
                }
            } catch (RegexError e) {
                message ("Orientation regex error: %s", e.message);
            }

            return HORIZONTAL;
        }
    }

    /* Property backing fields */
    private string _id;

    /**
     * {@inheritDoc}
     */
    public override string id {
        get { return model.id; }
        set { _id = model.id; }
    }

    public Dactl.AxisModel model { get; private set; }
    public Dactl.AxisView view { get; private set; }

    /**
     * Default construction.
     */
    public Axis () {
        model = new Dactl.AxisModel ();
        view = new Dactl.AxisView.with_model (model);
    }

    /**
     * Construction using a data model.
     */
    public Axis.with_model (Dactl.AxisModel model) {
        this.model = model;
        view = new Dactl.AxisView.with_model (model);
    }
}
