public class Dactl.ChannelMatrixElement : GLib.Object, Dactl.Object, Dactl.Buildable {

    private Xml.Node* _node;

    private string _xml = """
        <ui:object id=\"pg1chart0tr0ary0p00\" type=\"channel-matrix-element\">
          <ui:property name=\"a\">0.900</ui:property>
          <ui:property name=\"b\">1.00</ui:property>
          <ui:property name=\"chref\">/daqctl0/dev0/ai00</ui:property>
        </ui:object>
    """;

    private string _xsd = """
        <xs:element name="object">
          <xs:attribute name="id" type="xs:string" use="required"/>
          <xs:attribute name="type" type="xs:string" use="required"/>
          <xs:attribute name="ref" type="xs:string" use="required"/>
        </xs:element>
    """;

    /* the uri of the referenced channel */
    private string _chref;
    public string chref {
        get { return _chref; }
        set { _chref = value; }
    }

    /* the first entry of an ordered pair of data */
    private double _a;
    public double a {
        get { return _a; }
        set { _a = value; }
    }


    /* the second entry of an ordered pair of data */
    private double _b;
    public double b {
        get { return _b; }
        set { _b = value; }
    }

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

    public ChannelMatrixElement.from_xml_node (Xml.Node *node) {
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
                if (iter->name == "property") {
                    switch (iter->get_prop ("name")) {
                        case "chref":
                            chref = iter->get_content ();
                            break;
                        case "a":
                            a = double.parse (iter->get_content ());
                            break;
                        case "b":
                            b = double.parse (iter->get_content ());
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
 * Contains a group of Cld.Channels such that the values can be accessed as a 2darray
 * to be used in a heat map, for example.
 */
public class Dactl.ChannelMatrix : GLib.Object, Dactl.Object,
                            Dactl.Container, Dactl.Buildable, Dactl.CldAdapter {

    private Gee.Map<string, Dactl.Object> _objects;

    private Xml.Node* _node;

    private string _xml = """
        <ui:object id=\"hmap-0\" type=\"heatmap\">
          <ui:property name=\"min-color\">rgba(256,0,0,1)</ui:property>
          <ui:property name=\"max-color\">rgba(0,0,256,1)</ui:property>
          <ui:property name=\"min\">-10</ui:property>
          <ui:property name=\"max\">10</ui:property>
          <ui:property name=\"interpolation-type\">none</ui:property>
          <ui:property name=\"grid-rows\">4</ui:property>
          <ui:property name=\"grid-columns\">4</ui:property>
          <ui:object id=\"ary-0" type="channel-matrix\">

            <ui:object id=\"pg1chart0tr0ary0p00\" type=\"channel-matrix-element\">
              <ui:property name=\"a\">0.900</ui:property>
              <ui:property name=\"b\">1.00</ui:property>
              <ui:property name=\"chref\">/daqctl0/dev0/ai00</ui:property>
            </ui:object>

            <ui:object id=\"pg1chart0tr0ary0p01\" type=\"channel-matrix-element\">
              <ui:property name=\"a\">1.00</ui:property>
              <ui:property name=\"b\">2.00</ui:property>
              <ui:property name=\"chref\">/daqctl0/dev0/ai01</ui:property>
            </ui:object>
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
     * A list of channel references.
     */
    private Gee.Map<string, Dactl.TriplePoint?> _data;
    public Gee.Map<string, Dactl.TriplePoint?> data {
        get {
            return _data ;
        }
        private set {
            _data = value;
        }
    }

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
        data = new Gee.TreeMap<string, Dactl.TriplePoint?> ();
    }

    public ChannelMatrix.from_xml_node (Xml.Node *node) {
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
                    if (type == "channel-matrix-element") {
                        var child = new Dactl.ChannelMatrixElement.from_xml_node (iter);
                        child.id = object_id;
                        add_child (child);
                        data.set (child.chref,
                            new Dactl.TriplePoint () { a = child.a,
                                                          b = child.b, c = 0 });
                    }
                }
            }
        }

        request_data.begin ();
    }

    /**
     * {@inheritDoc}
     */
    public void offer_cld_object (Cld.Object object) {
        if (object is Cld.ScalableChannel) {
            (object as Cld.ScalableChannel).
                    new_value.connect ((t, id, value) => {
                        if (t is Cld.ScalableChannel) {
                            new_value_cb ((t as Cld.Object).uri, value);
                        }
            });
        }

        bool test = true;
        foreach (var obj in objects.values) {
            if (obj is Dactl.ChannelMatrixElement) {
                if (!(data.has_key ((obj as Dactl.ChannelMatrixElement).chref))){
                    test = false;
                }
            }
        }
        satisfied = test;
    }

    /**
     * {@inheritDoc}
     */
    protected async void request_data () {
        var elements = get_object_map (typeof (Dactl.ChannelMatrixElement));
        while (!satisfied) {
            foreach (var element in elements.values) {
                Dactl.ChannelMatrixElement e = element as Dactl.ChannelMatrixElement;
                request_object (e.chref);
            }

            // Try again in a second
            yield nap (1000);
        }
    }

    private void new_value_cb (string uri, double value) {
        var point = data.get (uri);
        point.c = value;
        data.set (uri, point);
        /*message ("%s %.3f %d", uri, data.get (uri).z, data.size);*/
    }

    /**
     * {@inheritDoc}
     */
    public void update_objects (Gee.Map<string, Dactl.Object> val) {
        _objects = val;
    }

    public bool get_satisfied () {

        return satisfied;
    }
}
