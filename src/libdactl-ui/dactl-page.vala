/**
 * Page data model class that is configurable using the application builder.
 */
public class Dactl.PageModel : Dactl.AbstractContainer {

    /**
     * {@inheritDoc}
     */
    public override string id { get; set; default = "pg0"; }

    public int index { get; set; default = 0; }

    public string title { get; set; default = "Page"; }

    public bool visible { get; set; default = true; }

    /**
     * {@inheritDoc}
     */
    private Gee.Map<string, Dactl.Object> _objects;
    public override Gee.Map<string, Dactl.Object> objects {
        get { return _objects; }
        set { update_objects (value); }
    }

    /**
     * Common object construction.
     */
    construct {
        objects = new Gee.TreeMap<string, Dactl.Object> ();
    }

    /**
     * Default construction.
     */
    public PageModel () { }

    /**
     * Construction using an XML node.
     */
    public PageModel.from_xml_node (Xml.Node *node) {
        build_from_xml_node (node);
    }

    /**
     * {@inheritDoc}
     */
    public override void build_from_xml_node (Xml.Node *node) {
        string? value;
        string type;

        if (node->type == Xml.ElementType.ELEMENT_NODE &&
            node->type != Xml.ElementType.COMMENT_NODE) {
            id = node->get_prop ("id");

            /* Iterate through node children */
            for (Xml.Node *iter = node->children; iter != null; iter = iter->next) {
                if (iter->name == "property") {
                    switch (iter->get_prop ("name")) {
                        case "index":
                            value = iter->get_content ();
                            index = int.parse (value);
                            break;
                        case "title":
                            title = iter->get_content ();
                            break;
                        case "visible":
                            value = iter->get_content ();
                            visible = bool.parse (value);
                            break;
                        default:
                            break;
                    }
                } else if (iter->name == "object") {
                    Dactl.Object? object = null;
                    type = iter->get_prop ("type");
                    /**
                     * XXX will need to add checks for pnid and plugin types
                     *     when they get implemented
                     */
                    switch (type) {
                        case "box":
                            var model = new Dactl.BoxModel.from_xml_node (iter);
                            object = new Dactl.Box.with_model (model);
                            break;
                        default:
                            object = null;
                            break;
                    }

                    /* no point adding an object type that isn't recognized */
                    if (object != null) {
                        add (object);
                        message ("Loading object of type `%s' with id `%s'", type, object.id);
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

/**
 * Page class used to populate notebook.
 */
public class Dactl.PageView : GtkClutter.Embed {

    /**
     * Backend data model used to configure the class.
     */
    public PageModel model { get; private set; }

    public Clutter.LayoutManager layout;

    /**
     * Default construction.
     */
    public PageView () {
        model = new PageModel ();
        connect_signals ();
        post_construct ();
    }

    /**
     * Construction using a provided data model.
     */
    public PageView.with_model (PageModel model) {
        this.model = model;
        connect_signals ();
        post_construct ();
    }

    /**
     * Connect any signals including the notifications from the model.
     */
    private void connect_signals () {

        /*
         *model.notify["xxx"].connect (() => {
         *    [> Change the xxx <]
         *});
         */
    }

    private void post_construct () {
        var stage = get_stage () as Clutter.Stage;
        var background = new GtkClutter.Texture ();

        stage.set_user_resizable (true);
        stage.set_background_color (gdk_rgba_to_clutter_color (get_dactl_bg_color ()));

        layout = new Clutter.BinLayout (Clutter.BinAlignment.CENTER,
                                        Clutter.BinAlignment.CENTER);

        stage.set_layout_manager (layout);
        stage.name = "dactl-stage-%s".printf (model.id);
        stage.x_expand = true;
        stage.y_expand = true;

        background.name = "page-background";

        try {
            var pixbuf = load_asset ("dactl-gray.png");
            background.set_from_pixbuf (pixbuf);
        } catch (GLib.Error e) {
            GLib.warning ("Failed to load asset 'dactl-gray.png': %s", e.message);
        }

        background.set_repeat (true, true);
        background.x_align = Clutter.ActorAlign.FILL;
        background.y_align = Clutter.ActorAlign.FILL;
        background.x_expand = true;
        background.y_expand = true;

        stage.add_child (background);
    }
}

public class Dactl.Page : Dactl.AbstractContainer {

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

    public Dactl.PageModel model { get; private set; }
    public Dactl.PageView view { get; private set; }

    /**
     * Default construction.
     */
    public Page () {
        model = new Dactl.PageModel ();
        view = new Dactl.PageView.with_model (model);
    }

    /**
     * Construction using a data model.
     */
    public Page.with_model (Dactl.PageModel model) {
        this.model = model;
        view = new Dactl.PageView.with_model (model);
    }

    /**
     * Add any children that are available in the model.
     *
     * XXX these MVC classes should have a common interface and this really
     *     should be an abstract method
     */
    public void add_children () {
        var boxes = model.get_object_map (typeof (Dactl.Box));
        foreach (var box in boxes.values) {
            GLib.message ("Adding box `%s' to page `%s'", box.id, id);

            var stage = view.get_stage ();

            /* XXX not sure whether or not to allow for multiple boxes within
             *     this container, for now just assuming a single container is
             *     constrained for the width and height */

            /*
             *var width_constraint = new Clutter.BindConstraint (stage, Clutter.BindCoordinate.WIDTH, 0);
             *var height_constraint = new Clutter.BindConstraint (stage, Clutter.BindCoordinate.HEIGHT, 0);
             *(box as Dactl.Box).view.add_constraint (width_constraint);
             *(box as Dactl.Box).view.add_constraint (height_constraint);
             */

            /* XXX possibly check for object.has_children first? */
            (box as Dactl.Box).add_children ();

            stage.add ((box as Dactl.Box).view);
        }

        var grids = model.get_object_map (typeof (Dactl.Grid));
        foreach (var grid in grids.values) {
            GLib.message ("Adding grid `%s' to page `%s'", grid.id, id);

            var stage = view.get_stage ();
            (grid as Dactl.Grid).add_children ();
            stage.add ((grid as Dactl.Grid).view);
        }
    }

    /**
     * {@inheritDoc}
     */
    public override void update_objects (Gee.Map<string, Dactl.Object> val) {
        model.objects = val;
    }
}
