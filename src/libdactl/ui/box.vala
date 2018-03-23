/**
 * Box class used to act as a layout for other interface classes.
 */
[GtkTemplate (ui = "/org/coanda/libdactl/ui/box.ui")]
public class Dactl.Box : Dactl.CompositeWidget {

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

    //private Dactl.Orientation _orientation = Dactl.Orientation.HORIZONTAL;

    //public int spacing { get; set; default = 0; }

    /*
     *public Dactl.Orientation orientation {
     *    get { return _orientation; }
     *    set {
     *        _orientation = value;
     *        box.orientation = _orientation.to_gtk ();
     *    }
     *}
     */

    //public bool homogeneous { get; set; default = false; }

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

    /*
     *[GtkChild]
     *private Gtk.Box box;
     */

    /**
     * Common object construction.
     */
    construct {
        id = "box0";
        objects = new Gee.TreeMap<string, Dactl.Object> ();
        spacing = 0;
        margin_top = 0;
        margin_right = 0;
        margin_bottom = 0;
        margin_left = 0;

        /*
         *this.notify["homogeneous"].connect (() => {
         *    box.homogeneous = homogeneous;
         *});
         */
    }

    /**
     * Default construction.
     */
    public Box () {
        debug ("empty construction");
    }

    /**
     * Construction using an XML node.
     */
    public Box.from_xml_node (Xml.Node *node) {
        build_from_xml_node (node);
    }

    /**
     * {@inheritDoc}
     */
    public override void build_from_xml_node (Xml.Node *node) {
        string type;
        string? value;

        if (node->type == Xml.ElementType.ELEMENT_NODE &&
            node->type != Xml.ElementType.COMMENT_NODE) {
            id = node->get_prop ("id");

            /* Iterate through node children */
            for (Xml.Node *iter = node->children; iter != null; iter = iter->next) {
                if (iter->name == "property") {
                    switch (iter->get_prop ("name")) {
                        case "homogeneous":
                            value = iter->get_content ();
                            homogeneous = bool.parse (value);
                            break;
                        case "orientation":
                            Dactl.Orientation _orientation;
                            if (iter->get_content () == "horizontal")
                                _orientation = Dactl.Orientation.HORIZONTAL;
                            else
                                _orientation = Dactl.Orientation.VERTICAL;
                            orientation = _orientation.to_gtk ();
                            break;
                        case "expand":
                            value = iter->get_content ();
                            expand = bool.parse (value);
                            break;
                        case "fill":
                            value = iter->get_content ();
                            fill = bool.parse (value);
                            break;
                        case "spacing":
                            value = iter->get_content ();
                            spacing = int.parse (value);
                            break;
                        case "margin-top":
                            value = iter->get_content ();
                            margin_top = int.parse (value);
                            break;
                        case "margin-right":
                            value = iter->get_content ();
                            margin_right = int.parse (value);
                            break;
                        case "margin-bottom":
                            value = iter->get_content ();
                            margin_bottom = int.parse (value);
                            break;
                        case "margin-left":
                            value = iter->get_content ();
                            margin_left = int.parse (value);
                            break;
                        case "hexpand":
                            value = iter->get_content ();
                            hexpand = bool.parse (value);
                            break;
                        case "vexpand":
                            value = iter->get_content ();
                            vexpand = bool.parse (value);
                            break;
                        default:
                            break;
                    }
                } else if (iter->name == "object") {
                    Dactl.Object? object = null;
                    type = iter->get_prop ("type");
                    /**
                     * XXX will need to add checks for plugin widget types
                     *     when they get implemented
                     */
                    switch (type) {
                        case "box":
                            object = new Dactl.Box.from_xml_node (iter);
                            break;
                        case "chart":
                            object = new Dactl.Chart.from_xml_node (iter);
                            break;
                        case "rt-chart":
                            object = new Dactl.RTChart.from_xml_node (iter);
                            break;
                        case "stripchart":
                            object = new Dactl.StripChart.from_xml_node (iter);
                            break;
                        case "tree":
                            object = new Dactl.ChannelTreeView.from_xml_node (iter);
                            break;
                        case "pnid":
                            object = new Dactl.Pnid.from_xml_node (iter);
                            break;
                        case "pid":
                            object = new Dactl.PidControl.from_xml_node (iter);
                            break;
                        case "ai":
                            object = new Dactl.AIControl.from_xml_node (iter);
                            break;
                        case "ao":
                            object = new Dactl.AOControl.from_xml_node (iter);
                            break;
                        case "digital":
                            object = new Dactl.DigitalControl.from_xml_node (iter);
                            break;
                        case "exec":
                            object = new Dactl.ExecControl.from_xml_node (iter);
                            break;
                        case "log":
                            object = new Dactl.LogControl.from_xml_node (iter);
                            break;
                        case "polar-chart":
                            object = new Dactl.PolarChart.from_xml_node (iter);
                            break;
                        case "video":
                            object = new Dactl.VideoProcessor.from_xml_node (iter);
                            break;
                        case "rich-content":
                            object = new Dactl.UI.RichContent.from_xml_node (iter);
                            break;
                        default:
                            object = null;
                            break;
                    }
                    /* no point adding an object type that isn't recognized */
                    if (object != null) {
                        debug ("Loading object of type `%s' with id `%s'", type, object.id);
                        add_child (object);
                    }
                }
            }
        }
    }

    public void add_child (Dactl.Object object) {
        // For testing
        /*
         *if (object.id == "box0-0") {
         *    (object as Gtk.Widget).get_style_context ().add_class ("test1");
         *} else if (object.id == "box0-1") {
         *    (object as Gtk.Widget).get_style_context ().add_class ("test2");
         *}
         */

        var type = (object as GLib.Object).get_type ();
        var type_name = type.name ();
        debug ("Packing object of type `%s' into `%s'", type_name, id);

        // FIXME: shouldn't have to do this
        if (object is Dactl.ChannelTreeView) {
            (this as Gtk.Widget).width_request = (object as Gtk.Widget).width_request;
        }

        objects.set (object.id, object);
        // FIXME: could probably just add them all as a Dactl.Widget
        if (object is Dactl.CustomWidget) {
            debug ("Pack custom widget");
            pack_start (object as Dactl.CustomWidget,
                            (object as Gtk.Widget).expand,
                            (object as Dactl.Widget).fill, 0);
        } else if (object is Dactl.CompositeWidget) {
            debug ("Pack composite widget");
            pack_start (object as Dactl.CompositeWidget,
                            (object as Gtk.Widget).expand,
                            (object as Dactl.Widget).fill, 0);
        } else if (object is Dactl.SimpleWidget) {
            debug ("Pack simple widget");
            pack_start (object as Dactl.SimpleWidget,
                            (object as Gtk.Widget).expand,
                            (object as Dactl.Widget).fill, 0);
        }

        /**
         * Without this the scaling of packed widgets doesn't always do what
         * you think it should.
         */
        if (object is Dactl.UI.RichContent) {
            debug ("Pack WebKit widget");
            (parent as Gtk.Container).child_set_property (this as Gtk.Widget, "expand", true);
            child_set_property (object as Gtk.Widget, "expand", true);
        } else if (object is Dactl.Box) {
            debug ("Pack box widget");
            //child_set_property (object as Gtk.Widget, "expand", true);
            child_set_property (object as Gtk.Widget, "fill", true);
        }

        show_all ();
    }

    /**
     * {@inheritDoc}
     */
    public override void update_objects (Gee.Map<string, Dactl.Object> val) {
        _objects = val;
    }
}
