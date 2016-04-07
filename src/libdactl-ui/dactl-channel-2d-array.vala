public class Dactl.Channel2dArrayElement : GLib.Object, Dactl.Object, Dactl.Buildable {

    private Xml.Node* _node;

    private string _xml = """
        <ui:object id=\"pg1chart0tr0ary0p00\" type=\"channel-2darray-element\" xyvalue=\"1.000, 1.0\" chref=\"/udp00\"/>
    """;

    private string _xsd = """
        <xs:element name="object">
          <xs:attribute name="id" type="xs:string" use="required"/>
          <xs:attribute name="type" type="xs:string" use="required"/>
          <xs:attribute name="ref" type="xs:string" use="required"/>
        </xs:element>
    """;

    /* the uri of the referenced channel */
    public string chref;

    /* the associated x value for this */
    public double xvalue;

    /* the associated y value for this */
    public double yvalue;

    /**
     * {@inheritDoc}
     */
    public string id { get; set; default = "trace0"; }

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

    public Channel2dArrayElement.from_xml_node (Xml.Node *node) {
        build_from_xml_node (node);
    }

    /**
     * {@inheritDoc}
     */
    public void build_from_xml_node (Xml.Node *node) {
        if (node->type == Xml.ElementType.ELEMENT_NODE &&
            node->type != Xml.ElementType.COMMENT_NODE) {
            this.node = node;
            id = node->get_prop ("id");
            chref = node->get_prop ("chref");
            xvalue = double.parse (node->get_prop ("xvalue"));
        }
    }
}

/**
 * Contains a group of Cld.Channels such that the values can be accessed as a 2darray
 * to be used in a heat map, for example.
 */
public class Dactl.Channel2dArray : GLib.Object, Dactl.Object,
                            Dactl.Container, Dactl.Buildable, Dactl.CldAdapter {

    private Gee.Map<string, Dactl.Object> _objects;

    private Xml.Node* _node;

    private string _xml = """
        <ui:object id=\"pg1chart0tr0ary0\" type=\"channel-2darray\">
          <ui:object id=\"pg1chart0tr0ary0p00\" type=\"channel-2darray-element\" xyvalue=\"1.000, 1.0\" chref=\"/udp00\"/>
          <ui:object id=\"pg1chart0tr0ary0p01\" type=\"channel-2darray-element\" xyvalue=\"1.125, 2.0\" chref=\"/udp01\"/>
          <ui:object id=\"pg1chart0tr0ary0p02\" type=\"channel-2darray-element\" xyvalue=\"1.286, 3.0\" chref=\"/udp02\"/>
          <ui:object id=\"pg1chart0tr0ary0p03\" type=\"channel-2darray-element\" xyvalue=\"1.500, 4.0\" chref=\"/udp03\"/>
          <ui:object id=\"pg1chart0tr0ary0p04\" type=\"channel-2darray-element\" xyvalue=\"1.800, 5.0\" chref=\"/udp04\"/>
          <ui:object id=\"pg1chart0tr0ary0p05\" type=\"channel-2darray-element\" xyvalue=\"2.250, 6.0\" chref=\"/udp05\"/>
          <ui:object id=\"pg1chart0tr0ary0p06\" type=\"channel-2darray-element\" xyvalue=\"3.000, 7.0\" chref=\"/udp06\"/>
          <ui:object id=\"pg1chart0tr0ary0p07\" type=\"channel-2darray-element\" xyvalue=\"4.500, 8.0\" chref=\"/udp07\"/>
          <ui:object id=\"pg1chart0tr0ary0p08\" type=\"channel-2darray-element\" xyvalue=\"9.000, 9.0\" chref=\"/udp08\"/>
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
     * A list of channel references.
     */
    private Gee.List<string> references = new Gee.LinkedList<string> ();

    private Gee.Map<string, Cld.Channel> channels = new Gee.HashMap<string, Cld.Channel> ();

    private Gee.Map<string, double?> channel_xvalues = new Gee.TreeMap<string, double?> ();

    private Gee.Map<string, int?> channel_indexes = new Gee.HashMap<string, int?> ();

    private Dactl.SimplePoint [] data;

    /**
     * {@inheritDoc}
     */
    public string id { get; set; default = "trace0"; }

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

    private int index = 0;

    /**
     * {@inheritDoc}
     */
    protected bool satisfied { get; set; default = false; }

    construct {
        objects = new Gee.TreeMap<string, Dactl.Object> ();
    }

    public Channel2dArray.from_xml_node (Xml.Node *node) {
        build_from_xml_node (node);
    }

    /**
     * {@inheritDoc}
     */
    public void build_from_xml_node (Xml.Node *node) {
        if (node->type == Xml.ElementType.ELEMENT_NODE &&
            node->type != Xml.ElementType.COMMENT_NODE) {
            this.node = node;
            id = node->get_prop ("id");
            /* Iterate through node children */
            for (Xml.Node *iter = node->children; iter != null; iter = iter->next) {
                if (iter->name == "object"){
                    var object_id = (iter->get_prop ("id"));
                    var type = (iter->get_prop ("type"));
                    if (type == "channel-2darray-element") {
                        var child = new Dactl.Channel2dArrayElement.from_xml_node (iter);
                        child.id = object_id;
                        add_child (child);
                    }
                }
            }
        }

        var elements = get_object_map (typeof (Dactl.Channel2dArrayElement));
        foreach (var element in elements.values) {
            Dactl.Channel2dArrayElement e = element as Dactl.Channel2dArrayElement;
            references.add (e.chref);
            channel_xvalues.set (e.chref, e.xvalue);
            data+= new Dactl.SimplePoint ();
            channel_indexes.set (e.chref, data.length - 1);
        }

        request_data.begin ();
    }

    /**
     * {@inheritDoc}
     */
    public void offer_cld_object (Cld.Object object) {
        if (references.contains (object.uri)) {
            channels.set (object.uri, object as Cld.Channel);
            if (object is Cld.ScalableChannel) {
                (object as Cld.ScalableChannel).
                        new_value.connect ((t, id, value) => {
                            if (t is Cld.ScalableChannel) {
                                new_value_cb ((t as Cld.Object).uri, value);
                            }
                });
            }
        }
        if (references.size == channels.size)
            satisfied = true;
    }

    /**
     * {@inheritDoc}
     */
    protected async void request_data () {
        var elements = get_object_map (typeof (Dactl.Channel2dArrayElement));
        while (!satisfied) {
            foreach (var element in elements.values) {
                Dactl.Channel2dArrayElement e = element as Dactl.Channel2dArrayElement;
                request_object (e.chref);
            }

            // Try again in a second
            yield nap (1000);
        }
    }

    int count = 0;
    private void new_value_cb (string uri, double value) {
        var xvalue = channel_xvalues.get (uri);
        int ix = channel_indexes.get (uri);
        data[ix] = new Dactl.SimplePoint () { x = xvalue, y = value };
    }

    public Dactl.SimplePoint[] to_array () {

        return data;
    }

    /**
     * {@inheritDoc}
     */
    public void update_objects (Gee.Map<string, Dactl.Object> val) {
        _objects = val;
    }
}
