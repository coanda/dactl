public class Dactl.ChannelVectorElement : GLib.Object, Dactl.Object, Dactl.Buildable {

    private Xml.Node* _node;

    private string _xml = """
        <ui:object id=\"pg1chart0tr0cv0p00\" type=\"channel-vector-element\" xvalue=\"1.000\" chref=\"/udp00\"/>
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

    public ChannelVectorElement.from_xml_node (Xml.Node *node) {
        build_from_xml_node (node);
    }

    /**
     * {@inheritDoc}
     */
    internal void build_from_xml_node (Xml.Node *node) {
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
 * Contains a group of Cld.Channels such that the values can be accessed as a vector
 * to be used in a multi-channel chart trace.
 */
public class Dactl.ChannelVector : GLib.Object, Dactl.Object,
                            Dactl.Container, Dactl.Buildable, Dactl.CldAdapter {

    private Gee.Map<string, Dactl.Object> _objects;

    private Xml.Node* _node;

    private string _xml = """
        <ui:object id=\"pg1chart0tr0cv0\" type=\"channel-vector\">
          <ui:object id=\"pg1chart0tr0cv0p00\" type=\"channel-vector-element\" xvalue=\"1.000\" chref=\"/udp00\"/>
          <ui:object id=\"pg1chart0tr0cv0p01\" type=\"channel-vector-element\" xvalue=\"1.125\" chref=\"/udp01\"/>
          <ui:object id=\"pg1chart0tr0cv0p02\" type=\"channel-vector-element\" xvalue=\"1.286\" chref=\"/udp02\"/>
          <ui:object id=\"pg1chart0tr0cv0p03\" type=\"channel-vector-element\" xvalue=\"1.500\" chref=\"/udp03\"/>
          <ui:object id=\"pg1chart0tr0cv0p04\" type=\"channel-vector-element\" xvalue=\"1.800\" chref=\"/udp04\"/>
          <ui:object id=\"pg1chart0tr0cv0p05\" type=\"channel-vector-element\" xvalue=\"2.250\" chref=\"/udp05\"/>
          <ui:object id=\"pg1chart0tr0cv0p06\" type=\"channel-vector-element\" xvalue=\"3.000\" chref=\"/udp06\"/>
          <ui:object id=\"pg1chart0tr0cv0p07\" type=\"channel-vector-element\" xvalue=\"4.500\" chref=\"/udp07\"/>
          <ui:object id=\"pg1chart0tr0cv0p08\" type=\"channel-vector-element\" xvalue=\"9.000\" chref=\"/udp08\"/>
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

    public ChannelVector.from_xml_node (Xml.Node *node) {
        build_from_xml_node (node);
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
                if (iter->name == "object"){
                    var object_id = (iter->get_prop ("id"));
                    var type = (iter->get_prop ("type"));
                    if (type == "channel-vector-element")
                        objects.set (object_id, new Dactl.ChannelVectorElement.from_xml_node (iter));
                }
            }
        }

        var elements = get_object_map (typeof (Dactl.ChannelVectorElement));
        foreach (var element in elements.values) {
            Dactl.ChannelVectorElement e = element as Dactl.ChannelVectorElement;
            references.add (e.chref);
            channel_xvalues.set (e.chref, e.xvalue);
            data += Dactl.SimplePoint ();
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
        var elements = get_object_map (typeof (Dactl.ChannelVectorElement));
        while (!satisfied) {
            foreach (var element in elements.values) {
                Dactl.ChannelVectorElement e = element as Dactl.ChannelVectorElement;
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
