/**
 * Digital channel user interface control
 *
 * This control displays the state of a digital channel.
 * If the channel is an output it will allow the user to change the output value
 **/
[GtkTemplate (ui = "/org/coanda/libdactl/ui/digital-control.ui")]
public class Dactl.DigitalControl : Dactl.CompositeWidget, Dactl.CldAdapter {

    [GtkChild]
    private Gtk.ToggleButton togglebutton;

    private string _xml = """
        <object id=\"d-ctl0\" type=\"digital\" ref=\"cld://do00\"/>
    """;

    private string _xsd = """
        <xs:element name="object">
          <xs:attribute name="id" type="xs:string" use="required"/>
          <xs:attribute name="type" type="xs:string" use="required"/>
          <xs:attribute name="ref" type="xs:string" use="required"/>
        </xs:element>
    """;

    public string ch_ref { get; set; }

    private weak Cld.DChannel _channel;

    public Cld.DChannel channel {
        get { return _channel; }
        set {
            if ((value as Cld.Object).uri == ch_ref) {
                _channel = value;
                channel_isset = true;
            }
        }
    }

    private bool channel_isset { get; private set; default = false; }

    private Gee.Map<string, Dactl.Object> _objects;

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
        id = "d-ctl0";
        objects = new Gee.TreeMap<string, Cld.Object> ();
    }

    //public AOControl (string ai_ref) {}

    public DigitalControl.from_xml_node (Xml.Node *node) {
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
            ch_ref = node->get_prop ("ref");
        }
    }

    /**
     * {@inheritDoc}
     */
    public void offer_cld_object (Cld.Object object) {
        if (object.uri == ch_ref) {
            debug ("uri: %s id: %s", object.uri, object.id);
            if (!(object is Cld.DChannel)) {
                warning ("Object %s is not a digital channel", object.uri);
            } else {
                channel = (object as Cld.DChannel);
                togglebutton.label = channel.tag;
                if (object is Cld.DIChannel) {
                    togglebutton.set_sensitive (false);
                    (object as Cld.DIChannel).new_value.connect ((id, value) => {
                        if (value)
                            togglebutton.set_active (true);
                        else
                            togglebutton.set_active (false);
                    });
                }

                satisfied = true;
            }
        }
    }

    /**
     * {@inheritDoc}
     */
    protected async void request_data () {
        while (!satisfied) {
            debug ("requesting %s", ch_ref);
            request_object (ch_ref);
            // Try again in a second
            yield nap (1000);
        }
    }

    [GtkCallback]
    private void togglebutton_toggled_cb () {
        if (channel is Cld.DOChannel)
            (channel as Cld.DOChannel).state = togglebutton.get_active ();

        var context = togglebutton.get_style_context ();
        if ((togglebutton as Gtk.ToggleButton).get_active ())
            context.add_class ("suggested-action");
        else
            context.remove_class ("suggested-action");
    }

    /**
     * {@inheritDoc}
     */
    public override void update_objects (Gee.Map<string, Dactl.Object> val) {
        _objects = val;
    }
}
