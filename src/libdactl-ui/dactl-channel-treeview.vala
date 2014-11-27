public class Dactl.ChannelTreeEntry : GLib.Object, Dactl.Object, Dactl.Buildable {

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
    public void build_from_xml_node (Xml.Node *node) {
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
    public void build_from_xml_node (Xml.Node *node) {
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

    public enum Columns {
        //CATEGORY,
        TAG,
        VALUE,
        UNITS,
        DESCRIPTION,
        HIDDEN_ID
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

    [GtkChild]
    private Gtk.TreeView treeview;

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
    }

    /**
     * {@inheritDoc}
     */
    public virtual void offer_cld_object (Cld.Object object) {
        var entries = get_object_map (typeof (Dactl.ChannelTreeEntry));
        foreach (var entry in entries.values) {
            if ((entry as Dactl.ChannelTreeEntry).ch_ref == object.uri) {
                message ("Assigning channel `%s' to `%s'", object.uri, entry.id);
                (entry as Dactl.ChannelTreeEntry).channel = (object as Cld.Channel);
            }
            satisfied = (entry as Dactl.ChannelTreeEntry).channel_isset;
        }

        message ("ChannelTreeView requirements satisfied: %s", satisfied.to_string ());

        if (satisfied) {
            channels_loaded ();

            message ("Creating treeview");
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
        int n = get_object_map (typeof (Dactl.ChannelTreeCategory)).size;
        bool has_categories = (n > 0) ? true : false;

        /* XXX currently default to 5 column headers but will likely control
         *     which are added through configuration in the future */
        n = (n > 0) ? n / n + 5 : 5;
        GLib.Type[] column_types = new GLib.Type[n];
        for (int i = 0; i < n; i++)
            column_types[i] = typeof (string);

        var treemodel = new Gtk.TreeStore.newv (column_types);

        treeview.headers_visible = show_header;
        treeview.set_model (treemodel);

        treeview.insert_column_with_attributes (-1, "Tag", new Gtk.CellRendererText (), "text", Columns.TAG);
        treeview.insert_column_with_attributes (-1, "Value", new Gtk.CellRendererText (), "text", Columns.VALUE);
        treeview.insert_column_with_attributes (-1, "Units", new Gtk.CellRendererText (), "text", Columns.UNITS);
        treeview.insert_column_with_attributes (-1, "Description", new Gtk.CellRendererText (), "text", Columns.DESCRIPTION);

        foreach (var category in get_object_map (typeof (Dactl.ChannelTreeCategory)).values) {
            Gtk.TreeIter iter;
            debug ("create_treeview adding `%s'", category.id);
            treemodel.append (out iter, null);
            treemodel.set (iter, Columns.TAG, (category as Dactl.ChannelTreeCategory).title,
                                 Columns.VALUE, null,
                                 Columns.UNITS, null,
                                 Columns.DESCRIPTION, null,
                                 Columns.HIDDEN_ID, null);

            foreach (var entry in (category as Dactl.Container).get_object_map (typeof (Dactl.ChannelTreeEntry)).values) {
                debug ("create_treeview adding `%s'", entry.id);
                Gtk.TreeIter child_iter;
                char[] buf = new char[double.DTOSTR_BUF_SIZE];
                string scaled_as_string;

                var channel = (entry as Dactl.ChannelTreeEntry).channel;
                debug ("create_treeview adding `%s'", channel.id);
                if (channel is Cld.ScalableChannel) {
                    var cal = (channel as Cld.ScalableChannel).calibration;
                    scaled_as_string = ((channel as Cld.ScalableChannel).scaled_value).format (buf, "%.3f");
                    treemodel.append (out child_iter, iter);
                    treemodel.set (child_iter, Columns.TAG, (channel as Cld.Channel).tag,
                                               Columns.VALUE, scaled_as_string,
                                               Columns.UNITS, (cal as Cld.Calibration).units,
                                               Columns.DESCRIPTION, (channel as Cld.Channel).desc,
                                               Columns.HIDDEN_ID, entry.id);
                }
            }
        }

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
        model.get (iter, Columns.HIDDEN_ID, out selection_id);

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
        string value = "0.0";
        Cld.Object? cal = null;

        treemodel.get (iter, Columns.HIDDEN_ID, out id);
        if (id != null) {
            var entry = get_object (id);
            var channel = (entry as Dactl.ChannelTreeEntry).channel;
            if (channel is Cld.ScalableChannel) {
                value = ((channel as Cld.ScalableChannel).scaled_value).format (buf, "%.3f");
                cal = (channel as Cld.ScalableChannel).calibration;

                //message ("Entry: %s / Channel: %s - %s", entry.id, channel.id, value);
            }

            (treemodel as Gtk.TreeStore).set (iter, Columns.VALUE, value,
                                              Columns.UNITS, (cal as Cld.Calibration).units,
                                              -1);
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
