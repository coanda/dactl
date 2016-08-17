/**
 * A chart trace that accesses a dataseries
 */
public class Dactl.RTTrace : Dactl.Trace, Dactl.Container {

    private Gee.Map<string, Dactl.Object> _objects;
    public Dactl.DataSeries dataseries { get; private set; }
    private Dactl.SimplePoint [] points_array;

    /**
     * {@inheritDoc}
     */
    public Gee.Map<string, Dactl.Object> objects {
        get { return _objects; }
        set { update_objects (value); }
    }

    construct {
        objects = new Gee.TreeMap<string, Dactl.Object> ();
    }

    public RTTrace (Xml.Ns* ns,
                    string id,
                    int points,
                    Dactl.TraceDrawType draw_type,
                    int line_weight,
                    Gdk.RGBA color) {

        this.id = id;
        this.points = points;
        this.draw_type = draw_type;
        this.line_weight = line_weight;
        this.color = color;

        this.node = new Xml.Node (ns, id);
        node->new_prop ("id", id);
        node->new_prop ("type", "trace");
        node->new_prop ("ttype", "real-time");

        Xml.Node* color_node = new Xml.Node (ns, "property");
        color_node->new_prop ("name", "color");
        color_node->add_content (color.to_string ());

        node->add_child (color_node);
    }

    /**
     * Construction using an XML node.
     */
    public RTTrace.from_xml_node (Xml.Node *node) {
        base.from_xml_node (node);
        build_from_xml_node (node);
        /* Create a points array for improved performance */
        points_array = new Dactl.SimplePoint[dataseries.buffer_size + 1];
        for (int i = 0; i < dataseries.buffer_size + 1; i++) {
            points_array [i] = Dactl.SimplePoint () { x = 0, y = 0 };
        }
    }

    /**
     * {@inheritDoc}
     */
    internal void build_from_xml_node (Xml.Node *node) {
        if (node->type == Xml.ElementType.ELEMENT_NODE &&
            node->type != Xml.ElementType.COMMENT_NODE) {
            this.node = node;
            id = node->get_prop ("id");
            /* Iterate through node children */
            for (Xml.Node *iter = node->children; iter != null; iter = iter->next) {
                if (iter->name == "property") {
                    switch (iter->get_prop ("name")) {
                        /* XXX TBD */
                        /*
                         *case "":
                         *    break;
                         */
                        default:
                            break;
                    }
                } else if (iter->name == "object") {
                    var type = iter->get_prop ("type");
                    if (type == "dataseries") {
                        dataseries = new Dactl.DataSeries.from_xml_node (iter);
                        this.add_child (dataseries);
                    }
                }
            }
        }
    }

    /**
     * Update the trace data
     */
    public void refresh () {
        double sum = 0;
        var ds_array = dataseries.to_array ();
        if (ds_array.length <= 2)
          return;

        var _raw = new Dactl.SimplePoint[ds_array.length];
        /* offset the x value by 2 samples to allow for end point interpolation */
        if (ds_array.length > 2 ) {
            sum = -1 * (ds_array[0].x + ds_array[1].x) / 1e6;
        }

        for (int t = 0; t < ds_array.length; t++) {
            var x = ds_array[t].x / 1e6;
            /* Convert to seconds and accumulate */
            sum = sum + x;
            var y = ds_array[t].y;
            points_array [t].x = sum;
            points_array [t].y = y;
            _raw[t] = points_array [t];
        }
        raw_data = _raw;
    }

    /**
     * {@inheritDoc}
     */
    public void update_objects (Gee.Map<string, Dactl.Object> val) {
        _objects = val;
    }
}
