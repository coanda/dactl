public class Dactl.ChannelTreeEntry : GLib.Object, Dactl.Object, Dactl.Buildable {

    private Xml.Node* _node;

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

    private weak Cld.Channel _channel;

    /**
     * {@inheritDoc}
     */
    public string id { get; set; default = "entry0"; }

    /**
     * The channel reference that this entry wants to display.
     */
    public string ch_ref { get; set; }

    public Cld.Channel channel {
        get { return _channel; }
        set {
            if ((value as Cld.Object).uri == ch_ref) {
                _channel = value;
                channel_isset = true;
            }
        }
    }

    public double value { get; private set; }

    public bool channel_isset { get; private set; default = false; }

    /**
     * {@inheritDoc}
     */
    protected virtual string xml {
        get { return _xml; }
    }

    /**
     * {@inheritDoc}
     */
    protected virtual string xsd {
        get { return _xsd; }
    }

    /**
     * Default construction.
     */
    public ChannelTreeEntry () { }

    /**
     * Construction using data provided.
     */
    public ChannelTreeEntry.with_data (string id, string ch_ref) {
        this.id = id;
        this.ch_ref = ch_ref;
    }

    /**
     * Construction using an XML node.
     */
    public ChannelTreeEntry.from_xml_node (Xml.Node *node) {
        build_from_xml_node (node);
    }

    /**
     * {@inheritDoc}
     */
    internal void build_from_xml_node (Xml.Node *node) {
        if (node->type == Xml.ElementType.ELEMENT_NODE &&
            node->type != Xml.ElementType.COMMENT_NODE) {
            id = node->get_prop ("id");
            /**
             * FIXME: change to ref
             */
            ch_ref = node->get_prop ("chref");
        }
    }
}

public class Dactl.ChannelTreeCategory : GLib.Object, Dactl.Object, Dactl.Buildable, Dactl.Container {

    private Xml.Node* _node;

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

    /**
     * {@inheritDoc}
     */
    public string id { get; set; default = "category0"; }

    /**
     * {@inheritDoc}
     */
    protected virtual string xml {
        get { return _xml; }
    }

    /**
     * {@inheritDoc}
     */
    protected virtual string xsd {
        get { return _xsd; }
    }

    /**
     * {@inheritDoc}
     */
    private Gee.Map<string, Dactl.Object> _objects;
    public Gee.Map<string, Dactl.Object> objects {
        get { return _objects; }
        set { update_objects (value); }
    }

    public string title { get; set; default = "Category"; }

    /**
     * Common object construction.
     */
    construct {
        objects = new Gee.TreeMap<string, Dactl.Object> ();
    }

    /**
     * Default construction.
     */
    public ChannelTreeCategory () { }

    /**
     * Construction using an XML node.
     */
    public ChannelTreeCategory.from_xml_node (Xml.Node *node) {
        build_from_xml_node (node);
    }

    /**
     * {@inheritDoc}
     */
    internal void build_from_xml_node (Xml.Node *node) {
        if (node->type == Xml.ElementType.ELEMENT_NODE &&
            node->type != Xml.ElementType.COMMENT_NODE) {
            id = node->get_prop ("id");

            /* Iterate through node children */
            for (Xml.Node *iter = node->children; iter != null; iter = iter->next) {
                if (iter->name == "property") {
                    switch (iter->get_prop ("name")) {
                        case "title":
                            title = iter->get_content ();
                            break;
                        default:
                            break;
                    }
                } else if (iter->name == "object") {
                    var type = iter->get_prop ("type");
                    if (type == "tree-category") {
                        var category = new Dactl.ChannelTreeCategory.from_xml_node (iter);
                        add_child (category);
                    } else if (type == "tree-entry") {
                        var entry = new Dactl.ChannelTreeEntry.from_xml_node (iter);
                        add_child (entry);
                    }
                }
            }
        }
    }

    /**
     * {@inheritDoc}
     */
    public void update_objects (Gee.Map<string, Dactl.Object> val) {
        _objects = val;
    }
}

[GtkTemplate (ui = "/org/coanda/libdactl/ui/channel-tree.ui")]
public class Dactl.ChannelTreeView : Dactl.CompositeWidget, Dactl.CldAdapter {

    private Gee.List<int> columns;
    private int hidden_id;

    public enum Columns {
        //CATEGORY,
        TAG,
        DESCRIPTION,
        VALUE,
        AVG,
        SSDEV,
        UNITS,
        SSIZE,
        HIDDEN_ID;

        public string to_string () {
            switch (this) {
                case TAG:           return "Tag";
                case DESCRIPTION:   return "Description";
                case VALUE:         return "Value";
                case AVG:           return "Average";
                case SSDEV:         return "σ";
                case UNITS:         return "Units";
                case SSIZE:         return "Samples";
                case HIDDEN_ID:     return "Hidden ID";
                default: assert_not_reached ();
            }
        }
    }

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

    public bool show_header { get; set; default = true; }

    private int width = 200;

    [GtkChild]
    private Gtk.TreeView treeview;

    [GtkChild]
    private Gtk.ScrolledWindow scrolledwindow;

    //[GtkChild]
    //private Gtk.TreeSelection selection;

    public signal void channels_loaded ();

    public signal void channel_selected (string id);

    /**
     * Common object construction.
     */
    construct {
        id = "tree0";
        objects = new Gee.TreeMap<string, Dactl.Object> ();
        columns = new Gee.ArrayList<int> ();
    }

    /**
     * Default construction.
     */
    public ChannelTreeView () {
        // Request the required Cld data
        request_data.begin ();
    }

    /**
     * Construction using an XML node.
     */
    public ChannelTreeView.from_xml_node (Xml.Node *node) {
        build_from_xml_node (node);

        // Request the required Cld data
        request_data.begin ();
    }

    /**
     * {@inheritDoc}
     */
    public override void build_from_xml_node (Xml.Node *node) {
        if (node->type == Xml.ElementType.ELEMENT_NODE &&
            node->type != Xml.ElementType.COMMENT_NODE) {
            id = node->get_prop ("id");

            /* Iterate through node children */
            for (Xml.Node *iter = node->children; iter != null; iter = iter->next) {
                if (iter->name == "property") {
                    switch (iter->get_prop ("name")) {
                        case "width-request":
                            var value = iter->get_content ();
                            width = int.parse (value);
                            break;
                        case "show-header":
                            var value = iter->get_content ();
                            show_header = bool.parse (value);
                            break;
                        case "expand":
                            var value = iter->get_content ();
                            expand = bool.parse (value);
                            break;
                        case "fill":
                            var value = iter->get_content ();
                            fill = bool.parse (value);
                            break;
                        case "show-tag":
                            var value = iter->get_content ();
                            if (bool.parse (value))
                                columns.add (Columns.TAG);
                            break;
                        case "show-desc":
                            var value = iter->get_content ();
                            if (bool.parse (value))
                                columns.add (Columns.DESCRIPTION);
                            break;
                        case "show-value":
                            var value = iter->get_content ();
                            if (bool.parse (value))
                                columns.add (Columns.VALUE);
                            break;
                        case "show-avg":
                            var value = iter->get_content ();
                            if (bool.parse (value))
                                columns.add (Columns.AVG);
                            break;
                        case "show-sample-sdev":
                            var value = iter->get_content ();
                            if (bool.parse (value))
                                columns.add (Columns.SSDEV);
                            break;
                        case "show-sample-size":
                            var value = iter->get_content ();
                            if (bool.parse (value))
                                columns.add (Columns.SSIZE);
                            break;
                        case "show-units":
                            var value = iter->get_content ();
                            if (bool.parse (value))
                                columns.add (Columns.UNITS);
                            break;
                        default:
                            break;
                    }
                } else if (iter->name == "object") {
                    var type = iter->get_prop ("type");
                    if (type == "tree-category") {
                        var category = new ChannelTreeCategory.from_xml_node (iter);
                        add_child (category);
                    } else if (type == "tree-entry") {
                        var entry = new ChannelTreeEntry.from_xml_node (iter);
                        add_child (entry);
                    }
                }
            }
        }
        columns.add (Columns.HIDDEN_ID);
    }

    /**
     * {@inheritDoc}
     */
    public virtual void offer_cld_object (Cld.Object object) {
        var entries = get_object_map (typeof (Dactl.ChannelTreeEntry));
        foreach (var entry in entries.values) {
            if ((entry as Dactl.ChannelTreeEntry).ch_ref == object.uri) {
                debug ("Assigning channel `%s' to `%s'", object.uri, entry.id);
                (entry as Dactl.ChannelTreeEntry).channel = (object as Cld.Channel);
            }
            satisfied = (entry as Dactl.ChannelTreeEntry).channel_isset;
        }

        debug ("ChannelTreeView requirements satisfied: %s", satisfied.to_string ());

        if (satisfied) {
            channels_loaded ();

            debug ("Creating treeview");
            create_treeview ();

            treeview.cursor_changed.connect (treeview_cursor_changed_cb);
            Timeout.add (1000, update);
            show_all ();
        }
    }

    /**
     * {@inheritDoc}
     */
    protected async void request_data () {
        while (!satisfied) {
            var entries = get_object_map (typeof (Dactl.ChannelTreeEntry));
            foreach (var entry in entries.values) {
                if (!(entry as Dactl.ChannelTreeEntry).channel_isset)
                    request_object ((entry as Dactl.ChannelTreeEntry).ch_ref);
            }
            // Try again in a second
            yield nap (1000);
        }
    }

    /**
     * {@inheritDoc}
     */
/*
 *    public void add_child (Dactl.Object object) {
 *        // XXX This probably won't work as-is
 *
 *        objects.set (object.id, object);
 *        // Recreate the treeview
 *        remove (treeview);
 *        treeview = null;
 *        create_treeview ();
 *        add (treeview);
 *    }
 */

    /**
     * Constructions the Gtk data model for the tree/list store.
     */
    private void create_treeview () {

        GLib.Type[] column_types = new GLib.Type[columns.size];
        int i = 0;

        foreach (var column in columns) {
            switch (column) {
                case Columns.TAG:
                    column_types[i] = typeof (string);
                    break;
                case Columns.DESCRIPTION:
                    column_types[i] = typeof (string);
                    break;
                case Columns.VALUE:
                    column_types[i] = typeof (string);
                    break;
                case Columns.AVG:
                    column_types[i] = typeof (string);
                    break;
                case Columns.SSDEV:
                    column_types[i] = typeof (string);
                    break;
                case Columns.SSIZE:
                    column_types[i] = typeof (string);
                    break;
                case Columns.UNITS:
                    column_types[i] = typeof (string);
                    break;
                case Columns.HIDDEN_ID:
                    column_types[i] = typeof (string);
                    /* This should be the last column */
                    hidden_id = i;
                    break;
                default:
                    break;
            }

            debug ("Column %d: %s type: %s",
                     i, ((Columns)column).to_string (), column_types[i].name ());
            i++;
        }

        var treemodel = new Gtk.TreeStore.newv (column_types);
        treeview.headers_visible = show_header;
        treeview.set_model (treemodel);

        i = 0;
        foreach (var column in columns) {
            if (i != hidden_id) {
                var cell = new Gtk.CellRendererText ();
                if (column == Columns.SSDEV || column == Columns.AVG)
                    cell.xalign = 0.5f;

                var treeview_column = new Gtk.TreeViewColumn.with_attributes (((Columns)column).to_string (),
                                                                              cell,
                                                                              "text",
                                                                              i);
                if (column == Columns.SSDEV || column == Columns.AVG)
                    treeview_column.alignment = 0.5f;

                treeview.append_column (treeview_column);
            }
            i++;
        }

        var categories = get_object_map (typeof (Dactl.ChannelTreeCategory));
        foreach (var category in categories.values) {
            Gtk.TreeIter iter;

            debug ("TreeView `%s' adding category `%s'", id, category.id);
            treemodel.append (out iter, null);

            for (i = 0; i <= columns.size; i++) {
                if (i == 0)
                    treemodel.set (iter, i, (category as Dactl.ChannelTreeCategory).title, -1);
                else
                    treemodel.set (iter, i, null, -1);
            }

            var entries = (category as Dactl.Container).get_object_map (typeof (Dactl.ChannelTreeEntry));
            foreach (var entry in entries.values) {
                Gtk.TreeIter child_iter;
                var channel = (entry as Dactl.ChannelTreeEntry).channel;
                debug ("TreeView `%s' adding channel `%s' to `%s'", id, channel.id, entry.id);

                if (channel is Cld.ScalableChannel) {
                    var cal = (channel as Cld.ScalableChannel).calibration;
                    treemodel.append (out child_iter, iter);
                    i= 0;
                    foreach (var column in columns) {
                        switch (column) {
                            case Columns.TAG:
                                var value =  (channel as Cld.Channel).tag;
                                treemodel.set (child_iter, i, value);
                                break;
                            case Columns.DESCRIPTION:
                                var value = (channel as Cld.Channel).desc;
                                treemodel.set (child_iter, i, value);
                                break;
                            case Columns.VALUE:
                                var value = "%5.3f".printf (
                                        (channel as Cld.ScalableChannel).scaled_value);
                                treemodel.set (child_iter, i, value);
                                break;
                            case Columns.AVG:
                                var calibration =
                                    (channel as Cld.ScalableChannel).calibration;
                                var value = "%5.3f".printf (calibration.apply (
                                        (channel as Cld.AChannel).avg_value));
                                treemodel.set (child_iter, i, value);
                                break;
                            case Columns.SSDEV:
                                var value = "%5.3f".printf (
                                        (channel as Cld.AChannel).ssdev_value);
                                treemodel.set (child_iter, i, value);
                                break;
                            case Columns.SSIZE:
                                var value = (channel as Cld.AIChannel).raw_value_list_size;
                                treemodel.set (child_iter, i, "%5d".printf (value));
                                break;
                            case Columns.UNITS:
                                var value = (cal as Cld.Calibration).units;
                                treemodel.set (child_iter, i, value);
                                break;
                            case Columns.HIDDEN_ID:
                                var value = entry.id;
                                treemodel.set (child_iter, i, value);
                                break;
                            default:
                                break;
                        }
                        i++;
                    }
                }
            }
        }
        scrolledwindow.width_request = width;
        /* FIXME: allow setting to be controlled using configuration */
        treeview.expand_all ();
    }

    //[GtkCallback]
    private void treeview_cursor_changed_cb () {
        string selection_id;
        Gtk.TreeModel model;
        Gtk.TreeIter iter;

        var selection = (treeview as Gtk.TreeView).get_selection ();
        selection.get_selected (out model, out iter);
        model.get (iter, hidden_id, out selection_id);
        debug ("Selected: %s", selection_id);

        var entry = get_object (selection_id) as Dactl.ChannelTreeEntry;
        channel_selected (entry.ch_ref);
    }

    /**
     * Callback to perform on the timeout interval.
     */
    private bool update () {
        Gtk.TreeModel treemodel = treeview.get_model ();
        treemodel.foreach (update_row);
        return true;
    }

    /**
     * Updates each row using the tree/list store's foreach iterator.
     */
    private bool update_row (Gtk.TreeModel treemodel,
                             Gtk.TreePath path,
                             Gtk.TreeIter iter) {
        string id;
        char[] buf = new char[double.DTOSTR_BUF_SIZE];
        string val = "0.0";
        Cld.Object? cal = null;

        treemodel.get (iter, hidden_id, out id);
        if (id != null) {
            var entry = get_object (id);
            var channel = (entry as Dactl.ChannelTreeEntry).channel;
            if (channel is Cld.ScalableChannel) {
                val = ((channel as Cld.ScalableChannel).scaled_value).format (buf, "%.3f");
                cal = (channel as Cld.ScalableChannel).calibration;
            }

            int i= 0;
            foreach (var column in columns) {
                switch (column) {
                    case Columns.TAG:
                        var value =  (channel as Cld.Channel).tag;
                        (treemodel as Gtk.TreeStore).set (iter, i, value);
                        break;
                    case Columns.DESCRIPTION:
                        var value = (channel as Cld.Channel).desc;
                        (treemodel as Gtk.TreeStore).set (iter, i, value);
                        break;
                    case Columns.VALUE:
                        var value = "%5.3f".printf (
                                (channel as Cld.ScalableChannel).scaled_value);
                        (treemodel as Gtk.TreeStore).set (iter, i, value);
                        break;
                    case Columns.AVG:
                        var calibration =
                            (channel as Cld.ScalableChannel).calibration;
                        var value = "%5.3f".printf (calibration.apply (
                                (channel as Cld.AChannel).avg_value));
                        (treemodel as Gtk.TreeStore).set (iter, i, value);
                        break;
                    case Columns.SSDEV:
                        var value = "%5.3f".printf (
                                (channel as Cld.AChannel).ssdev_value);
                        (treemodel as Gtk.TreeStore).set (iter, i, value);
                        break;
                    case Columns.SSIZE:
                        var value = (channel as Cld.AIChannel).
                                                    raw_value_list_size;
                        (treemodel as Gtk.TreeStore).set (iter, i, "%5d".printf (value));
                        break;
                    case Columns.UNITS:
                        var value = (cal as Cld.Calibration).units;
                        (treemodel as Gtk.TreeStore).set (iter, i, value);
                        break;
                    case Columns.HIDDEN_ID:
                        var value = entry.id;
                        (treemodel as Gtk.TreeStore).set (iter, i, value);
                        break;
                    default:
                        break;
                }
                i++;
            }

        }

        return false;
    }

    //[GtkCallback]
    //private void selection_changed_cb () {
        //[> XXX future home of multiple selection highlighting for charts <]
    //}

    /**
     * {@inheritDoc}
     */
    public override void update_objects (Gee.Map<string, Dactl.Object> val) {
        _objects = val;
    }
}
