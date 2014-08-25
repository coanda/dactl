public class Dactl.DOBox : Dactl.CompositeWidget, Dactl.CldAdapter {

    private Gee.Map<string, Dactl.Object> _objects;

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

    private Cld.DOChannel channel;

    private string ch_ref;

    //private Gtk.Box box;

    private Gtk.ToggleButton button;

    private string xml_template = """
        <object id="dobox0" type="dobox" chref="do0" />
    """;

    construct {
        id = "dobox0";
        /*
         *box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 10);
         *add (box);
         */
        orientation = Gtk.Orientation.HORIZONTAL;
    }

    public DOBox (string ch_ref) {
        this.ch_ref = ch_ref;
        create_widgets ();

        // Request the channel
        request_data.begin ();
    }

    public DOBox.from_xml_node (Xml.Node *node) {
        build_from_xml_node (node);
        create_widgets ();

        // Request the channel
        request_data.begin ();
    }

    /**
     * {@inheritDoc}
     */
    public override void build_from_xml_node (Xml.Node *node) {
        if (node->type == Xml.ElementType.ELEMENT_NODE &&
            node->type != Xml.ElementType.COMMENT_NODE) {
            id = node->get_prop ("id");
            ch_ref = node->get_prop ("chref");
        }
    }

    /**
     * {@inheritDoc}
     */
    public void offer_cld_object (Cld.Object object) {
        if (object.id == ch_ref) {
            channel = (object as Cld.DOChannel);
            satisfied = true;
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

        // No point doing anything without the required data
        connect_signals ();
    }

    private void create_widgets () {
        /* Create and setup widgets */
        button = new Gtk.ToggleButton.with_label ("LOW");

        /* Layout widgets */
        var r1hbox = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 5);
        var desc = new Gtk.Label (channel.desc);
        desc.justify = Gtk.Justification.LEFT;
        r1hbox.pack_start (desc, false, false, 0);
        r1hbox.pack_start (button, true, true, 0);

        var vbox = new Gtk.Box (Gtk.Orientation.VERTICAL, 10);
        vbox.pack_start (r1hbox, false, false, 0);
        pack_start (vbox, true, true, 0);

        show_all ();
    }

    private void connect_signals () {
        (button as Gtk.ToggleButton).toggled.connect (() => {
            if ((button as Gtk.ToggleButton).active) {
                (button as Gtk.Button).set_label ("HIGH");
                channel.state = true;
            } else {
                (button as Gtk.Button).set_label ("LOW");
                channel.state = false;
            }
        });
    }

    /**
     * {@inheritDoc}
     */
    public override void update_objects (Gee.Map<string, Dactl.Object> val) {
        _objects = val;
    }
}
