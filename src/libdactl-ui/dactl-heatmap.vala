public class Dactl.Heatmap : GLib.Object, Dactl.Object, Dactl.Container,
                                               Dactl.Buildable, Dactl.Drawable {

    private Gee.Map<string, Dactl.Object> _objects;
    private Xml.Node* _node;

    /**
     * {@inheritDoc}
     */
    public string id { get; set; default = "heatmap0"; }
    /* compute grid */

    private string _xml = """
              <ui:object id=\"surf1-0\" type=\"surface\" ttype=\"heatmap\">
                <ui:property name=\"min-color\">rgb(256,0,0)</ui:property>
                <ui:property name=\"max-color\">rgb(0,0,256)</ui:property>
                <ui:property name=\"min\">-10</ui:property>
                <ui:property name=\"max\">10</ui:property>
                <ui:property name=\"interpolation-type\">none</ui:property>
                <ui:property name=\"grid-rows\">4</ui:property>
                <ui:property name=\"grid-columns\">4</ui:property>
                <ui:object id=\"ary-0\" type=\"channel-2darray\">
                  <ui:object id=\"pg1chart0tr0ary0p00\" type=\"channel-2darray-element\" xyvalue=\"0.900, 1.00\" chref="/daqctl0/dev0/ai00\"/>
                  <ui:object id=\"pg1chart0tr0ary0p01\" type=\"channel-2darray-element\" xyvalue=\"1.000, 2.00\" chref="/daqctl0/dev0/ai01\"/>
                  <ui:object id=\"pg1chart0tr0ary0p02\" type=\"channel-2darray-element\" xyvalue=\"1.125, 3.00\" chref="/daqctl0/dev0/ai02\"/>
                  <ui:object id=\"pg1chart0tr0ary0p03\" type=\"channel-2darray-element\" xyvalue=\"1.286, 4.00\" chref="/daqctl0/dev0/ai03\"/>
                  <ui:object id=\"pg1chart0tr0ary0p04\" type=\"channel-2darray-element\" xyvalue=\"1.500, 5.00\" chref="/daqctl0/dev0/ai04\"/>
                  <ui:object id=\"pg1chart0tr0ary0p05\" type=\"channel-2darray-element\" xyvalue=\"1.800, 6.00\" chref="/daqctl0/dev0/ai05\"/>
                  <ui:object id=\"pg1chart0tr0ary0p06\" type=\"channel-2darray-element\" xyvalue=\"2.250, 7.00\" chref="/daqctl0/dev0/ai06\"/>
                  <ui:object id=\"pg1chart0tr0ary0p07\" type=\"channel-2darray-element\" xyvalue=\"3.000, 8.00\" chref="/daqctl0/dev0/ai07\"/>
                  <ui:object id=\"pg1chart0tr0ary0p08\" type=\"channel-2darray-element\" xyvalue=\"4.500, 9.00\" chref="/daqctl0/dev0/ai08\"/>
                  <ui:object id=\"pg1chart0tr0ary0p98\" type=\"channel-2darray-element\" xyvalue=\"9.000, 10.0\" chref="/daqctl0/dev0/ai09\"/>
                </ui:object>
              </ui:object>
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
    public Gee.Map<string, Dactl.Object> objects {
        get { return _objects; }
        set { update_objects (value); }
    }

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
    public unowned Cairo.ImageSurface image_surface { get; set; }

    /* The minimum value to be mapped to a color */
    private double min;

    /* The maximum value to be mapped to a color */
    private double max;

    /* The color that min is mapped to */
    protected string min_color_spec { get; set; default = "black"; }

    protected Gdk.RGBA _min_color;

    public Gdk.RGBA min_color  {
        get { return _min_color; }
        set {
            _min_color = value;
            min_color_spec = min_color.to_string ();
        }
    }

    /* The color that max is mapped to */
    protected string max_color_spec { get; set; default = "white"; }

    protected Gdk.RGBA _max_color;

    public Gdk.RGBA max_color  {
        get { return _max_color; }
        set {
            _max_color = value;
            max_color_spec = max_color.to_string ();
        }
    }

    /* Specifies the method used for interpolation */
    protected string interpolation_type { get; set; default = "none"; }

    /* Specifies the horizontal resolution of the generated image */
    protected int grid_columns { get; set; default = 4; }

    /* Specifies the vertical resolution of the generated image */
    protected int grid_rows { get; set; default = 4; }

    construct {

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
                        case "min-color":
                            min_color_spec = iter->get_content ();
                            min_color.parse (min_color_spec);
                            break;
                        case "max-color":
                            max_color_spec = iter->get_content ();
                            max_color.parse (max_color_spec);
                            break;
                        case "min":
                            min = double.parse (iter->get_content ());
                            break;
                        case "max":
                            max = double.parse (iter->get_content ());
                            break;
                        case "grid-rows":
                            grid_rows = int.parse (iter->get_content ());
                            break;
                        case "grid-columns":
                            grid_columns = int.parse (iter->get_content ());
                            break;
                        default:
                            break;
                    }
                }
            }
        }
        connect_notify_signals ();
    }
    private void grid () {

    }

    /* fill in the empty squares */
    private void interpolate () {

    }

    /**
     * {@inheritDoc}
     */
    public void connect_notify_signals () {
    }

    /**
     * {@inheritDoc}
     */
    private void generate (int w, int h,
                           double x_min, double x_max,
                           double y_min, double y_max) {
    }

    /**
     * {@inheritDoc}
     */
    public void draw (Cairo.Context cr) {
    }

    /**
     * {@inheritDoc}
     */
    public void update_objects (Gee.Map<string, Dactl.Object> val) {
        _objects = val;
    }
}
