/**
 * Contains a group of Cld.Channels such that the values can be accessed as a vector
 * to be used in a multi-channel chart trace.
 */
public class Dactl.ChannelVector : GLib.Object, Dactl.Object, Dactl.Buildable, Dactl.CldAdapter {

    private Xml.Node* _node;

    private string _xml = """
        <ui:object id=\"cv-0\" type=\"channel-vector\">
            <ui:property name=\"chref\" xvalue=\"0.9\">/daqctl0/dev0/ai00</ui:property>
            <ui:property name=\"chref\" xvalue=\"1.0\">/daqctl0/dev0/ai01</ui:property>
            <ui:property name=\"chref\" xvalue=\"1.125\">/daqctl0/dev0/ai02</ui:property>
            <ui:property name=\"chref\" xvalue=\"1.286\">/daqctl0/dev0/ai03</ui:property>
            <ui:property name=\"chref\" xvalue=\"1.5\">/daqctl0/dev0/ai04</ui:property>
            <ui:property name=\"chref\" xvalue=\"1.8\">/daqctl0/dev0/ai05</ui:property>
            <ui:property name=\"chref\" xvalue=\"2.25\">/daqctl0/dev0/ai06</ui:property>
            <ui:property name=\"chref\" xvalue=\"3.0\">/daqctl0/dev0/ai07</ui:property>
            <ui:property name=\"chref\" xvalue=\"4.5\">/daqctl0/dev0/ai08</ui:property>
            <ui:property name=\"chref\" xvalue=\"9\">/daqctl0/dev0/ai09</ui:property>
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
    }

    public ChannelVector.from_xml_node (Xml.Node *node) {
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
                if (iter->name == "property") {
                    switch (iter->get_prop ("name")) {
                        case "chref":
                            var uri = iter->get_content ();
                            references.add (uri);
                            var xvalue = double.parse(iter->get_prop ("xvalue"));
                            channel_xvalues.set (uri, xvalue);
                            data+= new Dactl.SimplePoint ();
                            channel_indexes.set (uri, data.length - 1);
                            break;
                        default:
                            break;
                    }
                }
            }
            /* sort x values XXX This does not work yet so xvalues must be ascending */
            /*
             *foreach (var entry in (channel_xvalues as Gee.TreeMap).ascending_entries)
             *    message ("key: %s", (entry as Gee.Map.Entry<string, double>).key);
             */
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
        while (!satisfied) {
            foreach (var reference in references) {
                request_object (reference);
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
}
