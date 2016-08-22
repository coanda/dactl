public class Dactl.PolarAxis : GLib.Object, Dactl.Buildable, Dactl.Object {
    /**
     * XXX this axis is not itself drawable but rather, will have within it
     *rules that ca be drawn on the edge of the graph
     */

    /**
     * {@inheritDoc}
     */
    public virtual string id { get; set; }

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

    /* Axis label */
    private string _label;
    public string label {
        get {
            return _label;
        }
        set {
            _label = value;
        }
        default = "Axis";
    }

    public Dactl.AxisFlag flags { get; set; }

    public bool show_label { get; set; default = true; }

    /* Orientation of the axis */
    public Dactl.PolarAxisType axis_type { get; set; }

    /* minimum value if the axis */
    private double _min;
    public double min {
        get {
            if (axis_type == Dactl.PolarAxisType.ANGLE) {
                var value = Dactl.UI.degrees_to_positive (_min);
                if (value == 360)
                    return 0;
                else
                    return value;
            } else {
                return _min;
            }
        }
        set {
            _min = value;
        }
    }


    /* maximum value if the axis */
    private double _max;
    public double max {
        get {
            if (axis_type == Dactl.PolarAxisType.ANGLE) {
                var value = Dactl.UI.degrees_to_positive (_max);
                if (value == 0)
                    return 360;
                else
                    return value;
            } else {
                return _max;
            }
        }
        set {
            _max = value;
        }
    }

    /**
     * The value at which this axis intersects its alternate
     */
    private double _intersect;
    public double intersect {
        get {
            if (axis_type == Dactl.PolarAxisType.ANGLE) {
                var value = Dactl.UI.degrees_to_positive (_intersect);
                return value;
            } else {
                return _intersect;
            }
        }
        set {
            _intersect = value;
        }
    }

    private string color_spec { get; set; default = "black"; }

    protected Gdk.RGBA _color;

    public Gdk.RGBA color  {
        get { return _color; }
        set {
            _color = value;
            _color_spec = _color.to_string ();
        }
    }

    public int div_major { get; set; default = 10; }

    public int div_minor { get; set; default = 2; }

    private bool dragging = false;

    public signal void range_changed (double min, double max);

    public signal void label_changed (string label);

    public signal void orientation_changed (Dactl.Orientation orientation);

    private double start_drag_x;

    private double start_drag_y;

    private bool reversed = false;

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

    construct {
        id = "axis0";

        flags = Dactl.AxisFlag.DRAW_LABEL |
                Dactl.AxisFlag.DRAW_MINOR_TICKS |
                Dactl.AxisFlag.DRAW_MAJOR_TICKS |
                Dactl.AxisFlag.DRAW_MINOR_LABELS |
                Dactl.AxisFlag.DRAW_MAJOR_LABELS |
                Dactl.AxisFlag.DRAW_START_LABEL |
                Dactl.AxisFlag.DRAW_END_LABEL;
    }

    /**
     * Default construction.
     */
    public PolarAxis () {
        //update ();
    }

    /**
     * Construction using an XML node.
     */
    public PolarAxis.from_xml_node (Xml.Node *node) {
        build_from_xml_node (node);
    }

    /**
     * {@inheritDoc}
     */
    internal void build_from_xml_node (Xml.Node *node) {

        string value;

        this.node = node;

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
                        case "polar-axis-type":
                            value = iter->get_content ();
                            axis_type = Dactl.PolarAxisType.parse (value);
                            break;
                        case "min":
                            value = iter->get_content ();
                            min = double.parse (value);
                            break;
                        case "max":
                            value = iter->get_content ();
                            max = double.parse (value);
                            break;
                        case "intersect-value":
                            value = iter->get_content ();
                            intersect = double.parse (value);
                            break;
                        case "div-major":
                            value = iter->get_content ();
                            div_major = int.parse (value);
                            break;
                        case "div-minor":
                            value = iter->get_content ();
                            div_minor = int.parse (value);
                            break;
                        case "color":
                            color_spec = iter->get_content ();
                            _color.parse (color_spec);
                            break;
                        case "show-major-ticks":
                            value = iter->get_content ();
                            flags = (bool.parse (value))
                                  ? flags.set (Dactl.AxisFlag.DRAW_MAJOR_TICKS)
                                  : flags.unset (Dactl.AxisFlag.DRAW_MAJOR_TICKS);
                            break;
                        case "show-major-labels":
                            value = iter->get_content ();
                            flags = (bool.parse (value))
                                  ? flags.set (Dactl.AxisFlag.DRAW_MAJOR_LABELS)
                                  : flags.unset (Dactl.AxisFlag.DRAW_MAJOR_LABELS);
                            break;
                        default:
                            break;
                    }
                }
            }
        }
        do_flags ();
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

        notify["flags"].connect ((s, p) => {
            do_flags ();
        });
    }

    private void do_flags () {

    }

    /**
     * Update the XML Node for this object.
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
                        case "label":
                            iter->set_content (label);
                            break;
                        case "type":
                            iter->set_content (axis_type.to_string ());
                            break;
                        case "min":
                            iter->set_content ("%.6f".printf (min));
                            break;
                        case "max":
                            iter->set_content ("%.6f".printf (max));
                            break;
                        case "intersect-value":
                            iter->set_content ("%.6f".printf (intersect));
                            break;
                        case "div-major":
                            iter->set_content ("%d".printf (div_major));
                            break;
                        case "div-minor":
                            iter->set_content ("%d".printf (div_minor));
                            break;
                        case "color":
                            iter->set_content (color_spec);
                            break;
                        case "show-major-ticks":
                            iter->set_content ("%s".printf (flags.is_set (
                                Dactl.AxisFlag.DRAW_MAJOR_TICKS).to_string ()));
                            break;
                        case "show-major-labels":
                            iter->set_content ("%s".printf (flags.is_set (
                               Dactl.AxisFlag.DRAW_MAJOR_LABELS).to_string ()));
                            break;
                        default:
                            break;
                    }
                }
            }
        }
    }
}
