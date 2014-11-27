[GtkTemplate (ui = "/org/coanda/libdactl/ui/ao-control.ui")]
public class Dactl.AOControl : Dactl.CompositeWidget, Dactl.CldAdapter {

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

    [GtkChild]
    private Gtk.Stack content;

    [GtkChild]
    private Gtk.Box box_primary;

    [GtkChild]
    private Gtk.Box box_secondary;

    [GtkChild]
    private Gtk.Button btn_next;

    [GtkChild]
    private Gtk.Button btn_previous;

    [GtkChild]
    private Gtk.Label lbl_tag;

    [GtkChild]
    private Gtk.Label lbl_value;

    [GtkChild]
    private Gtk.Adjustment adjustment_output;

    public string ch_ref { get; set; }

    private weak Cld.Channel _channel;

    public Cld.Channel channel {
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
        id = "ao-ctl0";
        // FIXME: doesn't work from .ui file
        content.transition_type = Gtk.StackTransitionType.SLIDE_LEFT_RIGHT;
        content.transition_duration = 400;

        objects = new Gee.TreeMap<string, Cld.Object> ();
    }

    //public AOControl (string ai_ref) {}

    public AOControl.from_xml_node (Xml.Node *node) {
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
            channel = (object as Cld.Channel);
            satisfied = true;

            lbl_tag.label = channel.tag;
        }
    }

    /**
     * {@inheritDoc}
     */
    protected async void request_data () {
        while (!satisfied) {
            request_object (ch_ref);
            // Try again in a second
            yield nap (1000);
        }
    }

    [GtkCallback]
    private void btn_next_clicked_cb () {
        content.visible_child = box_secondary;
    }

    [GtkCallback]
    private void btn_previous_clicked_cb () {
        content.visible_child = box_primary;
    }

    [GtkCallback]
    private void adjustment_output_value_changed_cb () {
        lbl_value.label = "%.3f".printf (adjustment_output.value);
        (channel as Cld.AOChannel).raw_value = adjustment_output.value;
    }

    /**
     * {@inheritDoc}
     */
    public override void update_objects (Gee.Map<string, Dactl.Object> val) {
        _objects = val;
    }
}
