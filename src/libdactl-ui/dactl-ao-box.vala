public class Dactl.AOBox : Dactl.CompositeWidget, Dactl.CldAdapter {

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

    private Cld.AOChannel channel;

    private string ch_ref;

    //private Gtk.Box box;

    private Gtk.Adjustment manual_adjustment;

    private Gtk.Scale manual_scale;

    private Gtk.SpinButton manual_spin_button;

    private string xml_template = """
        <object id="aobox0" type="aobox" chref="ao0" />
    """;

    construct {
        id = "aobox0";
        orientation = Gtk.Orientation.HORIZONTAL;
        //box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 10);
        //add (box);
    }

    public AOBox (string ch_ref) {
        this.ch_ref = ch_ref;
        create_widgets ();

        // Request the channel
        request_data.begin ();
    }

    public AOBox.from_xml_node (Xml.Node *node) {
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
    public virtual void offer_cld_object (Cld.Object object) {
        if (object.id == ch_ref) {
            channel = (object as Cld.AOChannel);
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
        manual_adjustment = new Gtk.Adjustment (0.0, 0.0, 100.0, 0.5, 0.5, 0.0);
        manual_scale = new Gtk.Scale (Gtk.Orientation.HORIZONTAL, manual_adjustment);
        manual_scale.draw_value = false;
        manual_spin_button = new Gtk.SpinButton (manual_adjustment, 1.0, 2);

        /* Layout widgets */
        var r1hbox = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 5);
        var desc = new Gtk.Label (channel.desc);
        desc.justify = Gtk.Justification.LEFT;
        r1hbox.pack_start (desc, false, false, 0);
        r1hbox.pack_start (manual_scale, true, true, 0);

        var r2hbox = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 10);
        r2hbox.pack_start (new Gtk.Label ("Output\n[% of max.]"), false, false, 0);
        r2hbox.pack_start (manual_spin_button, false, false, 0);

        var vbox = new Gtk.Box (Gtk.Orientation.VERTICAL, 10);
        vbox.pack_start (r1hbox, false, false, 0);
        vbox.pack_start (r2hbox, false, false, 0);

        pack_start (vbox, true, true, 0);

        show_all ();
    }

    private void connect_signals () {
        manual_scale.sensitive = true;
        manual_spin_button.sensitive = true;
        /* for now the manual adjustment on the control is from 0 - 100 %,
         * hence the divide by 10 */
        manual_adjustment.value_changed.connect (() => {
            channel.raw_value = manual_adjustment.value;
        });
    }

    /**
     * {@inheritDoc}
     */
    public override void update_objects (Gee.Map<string, Dactl.Object> val) {
        _objects = val;
    }
}
