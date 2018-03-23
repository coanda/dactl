[GtkTemplate (ui = "/org/coanda/libdactl/ui/video-processor.ui")]
public class Dactl.VideoProcessor : Dactl.CompositeWidget, Dactl.CldAdapter {

    [GtkChild]
    private Gtk.Image img_capture;

    private Gee.Map<string, Dactl.Object> _objects;

    private string _xml = """
        <object id=\"vid-proc0\" type=\"vid\" ref=\"cld://vid0\"/>
    """;

    private string _xsd = """
        <xs:element name="object">
          <xs:attribute name="id" type="xs:string" use="required"/>
          <xs:attribute name="type" type="xs:string" use="required"/>
          <xs:attribute name="ref" type="xs:string" use="required"/>
        </xs:element>
    """;

    //public string ch_ref { get; set; }

    //private weak Cld.Channel _channel;

    //public Cld.Channel channel {
        //get { return _channel; }
        //set {
            //if ((value as Cld.Object).uri == ch_ref) {
                //_channel = value;
                //channel_isset = true;
            //}
        //}
    //}

    //private bool channel_isset { get; private set; default = false; }

    /**
     * {@inheritDoc}
     */
    protected override string xml {
        get { return _xml; }
    }

    /**
     * {@inheritDoc}
     */
    protected override string xsd {
        get { return _xsd; }
    }

    /**
     * {@inheritDoc}
     */
    public override Gee.Map<string, Dactl.Object> objects {
        get { return _objects; }
        set { update_objects (value); }
    }

    /**
     * {@inheritDoc}
     */
    protected bool satisfied { get; set; default = false; }

    construct {
        id = "vid-proc0";

        objects = new Gee.TreeMap<string, Dactl.Object> ();
    }

    public VideoProcessor () {
        //this.ch_ref = ai_ref;

        // Request CLD data
        request_data.begin ();
    }

    public VideoProcessor.from_xml_node (Xml.Node *node) {
        build_from_xml_node (node);

        // Request CLD data
        request_data.begin ();
    }

    /**
     * {@inheritDoc}
     */
    public override void build_from_xml_node (Xml.Node *node) {
        if (node->type == Xml.ElementType.ELEMENT_NODE &&
            node->type != Xml.ElementType.COMMENT_NODE) {
            id = node->get_prop ("id");

        }
    }

    /**
     * {@inheritDoc}
     */
    public void offer_cld_object (Cld.Object object) {
        //if (object.uri == ch_ref) {
            //channel = (object as Cld.Channel);
            //satisfied = true;

            //Timeout.add (1000, update);
            //lbl_tag.label = channel.tag;
        //}
    }

    /**
     * {@inheritDoc}
     */
    protected async void request_data () {
        satisfied = true;
        while (!satisfied) {
            //request_object (ch_ref);
            // Try again in a second
            yield nap (1000);
        }
    }

    /**
     * {@inheritDoc}
     */
    public override void update_objects (Gee.Map<string, Dactl.Object> val) {
        _objects = val;
    }
}
