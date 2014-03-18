using Cld;
using Gee;
using Gtk;

public class Dactl.ChannelTreeEntry : Dactl.AbstractBuildable {

    /**
     * {@inheritDoc}
     */
    public override string id { get; set; default = "entry0"; }

    /**
     * The channel reference that this entry wants to display.
     */
    public string ch_ref { get; set; }

    public weak Channel channel { get; set; }

    public double value { get; set; }

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
    public override void build_from_xml_node (Xml.Node *node) {
        if (node->type == Xml.ElementType.ELEMENT_NODE &&
            node->type != Xml.ElementType.COMMENT_NODE) {
            id = node->get_prop ("id");
            ch_ref = node->get_prop ("chref");
        }
    }
}

public class Dactl.ChannelTreeCategory : Dactl.AbstractContainer {

    /**
     * {@inheritDoc}
     */
    public override string id { get; set; default = "category0"; }

    /**
     * {@inheritDoc}
     */
    private Gee.Map<string, Dactl.Object> _objects;
    public override Gee.Map<string, Dactl.Object> objects {
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
    public override void build_from_xml_node (Xml.Node *node) {
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
                        var category = new ChannelTreeCategory.from_xml_node (iter);
                        add (category);
                    } else if (type == "tree-entry") {
                        var entry = new ChannelTreeEntry.from_xml_node (iter);
                        add (entry);
                    }
                }
            }
        }
    }

    /**
     * {@inheritDoc}
     */
    public override void update_objects (Gee.Map<string, Dactl.Object> val) {
        _objects = val;
    }
}

public class Dactl.ChannelTreeModel : Dactl.AbstractContainer {

    /**
     * {@inheritDoc}
     */
    public override string id { get; set; default = "tree0"; }

    /**
     * {@inheritDoc}
     */
    private Gee.Map<string, Dactl.Object> _objects;
    public override Gee.Map<string, Dactl.Object> objects {
        get { return _objects; }
        set { update_objects (value); }
    }

    /**
     * The list of channels that were connected during configuration.
     */
    private Map<string, Cld.Object> _channels;
    public Map<string, Cld.Object> channels {
        get { return _channels; }
        set { _channels = value; }
    }

    public bool show_header { get; set; default = true; }

    public Gee.List<Dactl.UI.Constraint> constraints = new Gee.ArrayList<Dactl.UI.Constraint> ();

    /**
     * This seems like a sensible way for the model to request to have
     * external data added.
     */
    public signal void channel_request (string id);

    public signal void channels_loaded ();

    /**
     * Common object construction.
     */
    construct {
        objects = new Gee.TreeMap<string, Dactl.Object> ();
        channels = new Gee.TreeMap<string, Cld.Object> ();
    }

    /**
     * Default construction.
     */
    public ChannelTreeModel () {
        add_channels ();
    }

    /**
     * Construction using an XML node.
     */
    public ChannelTreeModel.from_xml_node (Xml.Node *node) {
        build_from_xml_node (node);
        //add_channels ();
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
                        case "constraint":
                            var constraint = new Dactl.UI.Constraint ();
                            switch (iter->get_prop ("coordinate")) {
                                case "width":
                                    constraint.coordinate = Clutter.BindCoordinate.WIDTH;
                                    break;
                                case "height":
                                    constraint.coordinate = Clutter.BindCoordinate.HEIGHT;
                                    break;
                                case "x":
                                    constraint.coordinate = Clutter.BindCoordinate.X;
                                    break;
                                case "y":
                                    constraint.coordinate = Clutter.BindCoordinate.Y;
                                    break;
                                case "all":
                                    constraint.coordinate = Clutter.BindCoordinate.ALL;
                                    break;
                                default:
                                    break;
                            }
                            constraint.offset = int.parse (iter->get_prop ("offset"));
                            constraints.add (constraint);
                            break;
                        default:
                            break;
                    }
                } else if (iter->name == "object") {
                    var type = iter->get_prop ("type");
                    if (type == "tree-category") {
                        var category = new ChannelTreeCategory.from_xml_node (iter);
                        add (category);
                    } else if (type == "tree-entry") {
                        var entry = new ChannelTreeEntry.from_xml_node (iter);
                        add (entry);
                    }
                }
            }
        }
    }

    /**
     * {@inheritDoc}
     */
    public override void update_objects (Gee.Map<string, Dactl.Object> val) {
        _objects = val;
    }

    /**
     * Add a specific channel by requesting it from the parent data model. This
     * will probably not be used any time soon as configuration is typically
     * done through XML.
     */
    public void add_channel (string id) {
        channel_request (id);
    }

    /**
     * Iterates the list of objects and wherever a TreeEntry exists request the
     * Cld.Channel with the associated id.
     */
    public void add_channels () {
        foreach (var object in objects.values) {
            if (object is Dactl.ChannelTreeCategory) {
                foreach (var entry in (object as Dactl.AbstractContainer).objects.values) {
                    if (entry is Dactl.ChannelTreeEntry) {
                        GLib.message ("ChannelTree `%s' requesting channel `%s'",
                                      id, (entry as Dactl.ChannelTreeEntry).ch_ref);
                        channel_request ((entry as Dactl.ChannelTreeEntry).ch_ref);
                    }
                }
            }
        }

        /* XXX need to spawn an async thread waiting for the channels requested
         *     to be loaded, for now just testing without */
        channels_loaded ();
    }
}

public class Dactl.ChannelTreeView : Clutter.Actor {

    public enum Columns {
        //CATEGORY,
        TAG,
        VALUE,
        UNITS,
        DESCRIPTION,
        HIDDEN_ID
    }

    /*
     *private Map<string, Cld.Object> _channels;
     *public Map<string, Cld.Object> channels {
     *    get { return _channels; }
     *    set { _channels = value; }
     *}
     */

    //private Clutter.Stage? _stage = null;
    //public Clutter.Stage stage { get; private set; }

    private Dactl.ChannelTreeModel model;

    private Gtk.TreeView treeview;

    public signal void channel_selected (string id);

    /**
     * Default construction.
     */
    public ChannelTreeView () {
        /*
         *this.channels = channels;
         */
        model = new Dactl.ChannelTreeModel ();
        create_treeview ();
        setup_stage ();
        treeview.cursor_changed.connect (cursor_changed_cb);
        Timeout.add (1000, update);
    }

    /**
     * Construction using a data model, mainly to connect to any signals.
     */
    public ChannelTreeView.with_model (Dactl.ChannelTreeModel model) {
        this.model = model;
        create_treeview ();
        treeview.cursor_changed.connect (cursor_changed_cb);
        setup_stage ();
        Timeout.add (1000, update);
    }

    /**
     * Constructions the Gtk data model for the tree/list store.
     */
    private void create_treeview () {
        int n = model.get_object_map (typeof (Dactl.ChannelTreeCategory)).size;
        bool has_categories = (n > 0) ? true : false;

        /* XXX currently default to 5 column headers but will likely control
         *     which are added through configuration in the future */
        n = (n > 0) ? n / n + 5 : 5;
        GLib.Type[] column_types = new GLib.Type[n];
        for (int i = 0; i < n; i++)
            column_types[i] = typeof (string);

        var tree_model = new TreeStore.newv (column_types);

        treeview = new Gtk.TreeView ();
        treeview.headers_visible = model.show_header;
        treeview.set_model (tree_model);

        treeview.insert_column_with_attributes (-1, "Tag", new CellRendererText (), "text", Columns.TAG);
        treeview.insert_column_with_attributes (-1, "Value", new CellRendererText (), "text", Columns.VALUE);
        treeview.insert_column_with_attributes (-1, "Units", new CellRendererText (), "text", Columns.UNITS);
        treeview.insert_column_with_attributes (-1, "Description", new CellRendererText (), "text", Columns.DESCRIPTION);

        Gtk.TreeIter iter;

        foreach (var category in model.get_object_map (typeof (Dactl.ChannelTreeCategory)).values) {
            tree_model.append (out iter, null);
            tree_model.set (iter, Columns.TAG, (category as Dactl.ChannelTreeCategory).title,
                                  Columns.VALUE, null,
                                  Columns.UNITS, null,
                                  Columns.DESCRIPTION, null,
                                  Columns.HIDDEN_ID, null);

            foreach (var entry in (category as Dactl.AbstractContainer).get_object_map (typeof (Dactl.ChannelTreeEntry)).values) {
                Gtk.TreeIter child_iter;
                char[] buf = new char[double.DTOSTR_BUF_SIZE];
                string scaled_as_string;

                var channel = model.channels.get ((entry as Dactl.ChannelTreeEntry).ch_ref);
                if (channel is Cld.ScalableChannel) {
                    var cal = (channel as Cld.ScalableChannel).calibration;
                    scaled_as_string = ((channel as Cld.ScalableChannel).scaled_value).format (buf, "%.3f");
                    tree_model.append (out child_iter, iter);
                    tree_model.set (child_iter, Columns.TAG, (channel as Channel).tag,
                                                Columns.VALUE, scaled_as_string,
                                                Columns.UNITS, (cal as Calibration).units,
                                                Columns.DESCRIPTION, (channel as Channel).desc,
                                                Columns.HIDDEN_ID, (channel as Cld.Object).id);
                }
            }
        }

        /* XXX possibly control using configuration later */
        treeview.realize.connect (() => {
            treeview.expand_all ();
        });
    }

    private void setup_stage () {
        //var stage = get_stage () as Clutter.Stage;
        set_background_color (gdk_rgba_to_clutter_color (get_dactl_bg_color ()));

        var layout = new Clutter.BinLayout (Clutter.BinAlignment.START,
                                            Clutter.BinAlignment.START);
        set_layout_manager (layout);
        name = "dactl-frame-stage";

        x_align = Clutter.ActorAlign.FILL;
        y_align = Clutter.ActorAlign.FILL;
        x_expand = true;
        y_expand = true;

        var actor = new GtkClutter.Actor.with_contents (treeview);
        actor.x_align = Clutter.ActorAlign.FILL;
        actor.y_align = Clutter.ActorAlign.FILL;
        actor.x_expand = true;
        actor.y_expand = true;

        add_child (actor as Clutter.Actor);

        treeview.show_all ();
    }

    private void cursor_changed_cb () {
        string id;
        TreeModel model;
        TreeIter iter;
        TreeSelection selection;

        selection = (treeview as Gtk.TreeView).get_selection ();
        selection.get_selected (out model, out iter);
        model.get (iter, Dactl.ChannelTreeView.Columns.HIDDEN_ID, out id);

        channel_selected (id);
    }

    /**
     * Callback to perform on the timeout interval.
     */
    private bool update () {
        TreeModel tree_model = treeview.get_model ();
        tree_model.foreach (update_row);
        return true;
    }

    /**
     * Updates each row using the tree/list store's foreach iterator.
     */
    private bool update_row (TreeModel tree_model, TreePath path, TreeIter iter) {
        string id;
        char[] buf = new char[double.DTOSTR_BUF_SIZE];
        string value = "0.0";
        Cld.Object? cal = null;

        tree_model.get (iter, Columns.HIDDEN_ID, out id);
        if (id != null) {
            var channel = model.channels.get (id);
            if (channel is ScalableChannel) {
                value = ((channel as ScalableChannel).scaled_value).format (buf, "%.3f");
                cal = (channel as ScalableChannel).calibration;
            }

            (tree_model as Gtk.TreeStore).set (iter, Columns.VALUE, value,
                                                    Columns.UNITS, (cal as Calibration).units,
                                                    -1);
        }

        return false;
    }
}

public class Dactl.ChannelTree : Dactl.AbstractContainer {

    /* Property backing fields */
    private string _id;

    /**
     * {@inheritDoc}
     */
    public override string id {
        get { return model.id; }
        set { model.id = value; }
    }

    /**
     * {@inheritDoc}
     */
    public override Gee.Map<string, Dactl.Object> objects {
        get { return model.objects; }
        set { update_objects (value); }
    }

    public Dactl.ChannelTreeModel model { get; private set; }
    public Dactl.ChannelTreeView view { get; private set; }

    /**
     * Default construction.
     *
     * XXX currently not possible to create a view without a list of channels
     */
    public ChannelTree () {
        /*
         *model = new Dactl.ChannelTreeModel ();
         *view = new Dactl.ChannelTreeView.with_model (model);
         */
    }

    /**
     * Construction using a data model.
     */
    public ChannelTree.with_model (Dactl.ChannelTreeModel model) {
        this.model = model;
        /* Can't create the treeview until the channel map has been loaded */
        this.model.channels_loaded.connect (() => {
            view = new Dactl.ChannelTreeView.with_model (model);
        });
    }

    /**
     * {@inheritDoc}
     */
    public override void update_objects (Gee.Map<string, Dactl.Object> val) {
        model.objects = val;
    }
}
