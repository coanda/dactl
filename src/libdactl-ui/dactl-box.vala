public class Dactl.UI.Constraint {
    public Clutter.BindCoordinate coordinate { get; set; default = Clutter.BindCoordinate.ALL; }
    public int offset { get; set; default = 0; }
}

/**
 * Box data model class that is configurable using the application builder.
 */
public class Dactl.BoxModel : Dactl.AbstractContainer {

    /**
     * {@inheritDoc}
     */
    public override string id { get; set; default = "box0"; }

    public int spacing { get; set; default = 0; }

    public string orientation { get; set; default = "horizontal"; }

    public bool homogeneous { get; set; default = true; }

    public int margin_top { get; set; default = 0; }

    public int margin_right { get; set; default = 0; }

    public int margin_bottom { get; set; default = 0; }

    public int margin_left { get; set; default = 0; }

    public bool x_expand { get; set; default = true; }

    public bool y_expand { get; set; default = true; }

    public Gee.List<Dactl.UI.Constraint> constraints = new Gee.ArrayList<Dactl.UI.Constraint> ();

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
    public BoxModel () { }

    /**
     * Construction using an XML node.
     */
    public BoxModel.from_xml_node (Xml.Node *node) {
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
                            orientation = iter->get_content ();
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
                        case "x-expand":
                            value = iter->get_content ();
                            x_expand = bool.parse (value);
                            break;
                        case "y-expand":
                            value = iter->get_content ();
                            y_expand = bool.parse (value);
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
                            constraints.add (constraint);
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
                        case "chart":
                            var model = new Dactl.ChartModel.from_xml_node (iter);
                            object = new Dactl.Chart.with_model (model);
                            break;
                        case "tree":
                            var model = new Dactl.ChannelTreeModel.from_xml_node (iter);
                            object = new Dactl.ChannelTree.with_model (model);
                            break;
                        case "pnid":
                            var model = new Dactl.PnidModel.from_xml_node (iter);
                            object = new Dactl.Pnid.with_model (model);
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
 * Box class used to act as a layout for other interface classes.
 *
 * XXX not sure how yet but this should contain a BoxLayout, either by extending
 *     one or by using one as a GtkClutter.Actor
 */
public class Dactl.BoxView : Clutter.Actor {

    /**
     * Backend data model used to configure the class.
     */
    public BoxModel model { get; private set; }

    private Clutter.Actor box;

    private Clutter.BoxLayout layout;

    /**
     * Default construction.
     */
    public BoxView () {
        model = new BoxModel ();
        connect_signals ();
        post_construct ();
    }

    /**
     * Construction using a provided data model.
     */
    public BoxView.with_model (BoxModel model) {
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
        box = new Clutter.Actor ();
        layout = new Clutter.BoxLayout ();

        layout.homogeneous = model.homogeneous;
        layout.spacing = model.spacing;
        layout.pack_start = true;
        layout.orientation = (model.orientation == "horizontal") ?
            Clutter.Orientation.HORIZONTAL : Clutter.Orientation.VERTICAL;

        box.layout_manager = layout;
        name = "dactl-box-%s".printf (model.id);

        x_expand = true;
        y_expand = true;
        x_align = Clutter.ActorAlign.FILL;
        y_align = Clutter.ActorAlign.FILL;

        /*
         *box.margin_top = model.margin_top;
         *box.margin_right = model.margin_right;
         *box.margin_bottom = model.margin_bottom;
         *box.margin_left = model.margin_left;
         */

        box.x_align = Clutter.ActorAlign.FILL;
        box.y_align = Clutter.ActorAlign.FILL;
        box.x_expand = model.x_expand;
        box.y_expand = model.y_expand;

        add (box);
    }

    public void add_child (Clutter.Actor child) {
        box.add_child (child);
    }
}

public class Dactl.Box : Dactl.AbstractContainer {

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

    public Dactl.BoxModel model { get; private set; }
    public Dactl.BoxView view { get; private set; }

    /**
     * Default construction.
     */
    public Box () {
        model = new Dactl.BoxModel ();
        view = new Dactl.BoxView.with_model (model);
    }

    /**
     * Construction using a data model.
     */
    public Box.with_model (Dactl.BoxModel model) {
        this.model = model;
        view = new Dactl.BoxView.with_model (model);
    }

    /**
     * Add the views for any children that are available in the model.
     *
     * XXX these MVC classes should have a common interface and this really
     *     should be an abstract method
     */
    public void add_children () {
        var boxes = model.get_children (typeof (Dactl.Box));
        foreach (var box in boxes.values) {
            GLib.message ("Adding box `%s' to box `%s'", box.id, id);
            foreach (var constraint in (box as Dactl.Box).model.constraints) {
                var bind_constraint = new Clutter.BindConstraint (view, constraint.coordinate, constraint.offset);
                (box as Dactl.Box).view.add_constraint (bind_constraint);
            }
            view.add_child ((box as Dactl.Box).view);

            /* XXX possibly check for object.has_children first? */
            (box as Dactl.Box).add_children ();
        }

        var trees = model.get_children (typeof (Dactl.ChannelTree));
        foreach (var tree in trees.values) {
            GLib.message ("Adding tree `%s' to box `%s'", tree.id, id);
            foreach (var constraint in (tree as Dactl.ChannelTree).model.constraints) {
                var bind_constraint = new Clutter.BindConstraint (view, constraint.coordinate, constraint.offset);
                (tree as Dactl.ChannelTree).view.add_constraint (bind_constraint);
            }
            view.add_child ((tree as Dactl.ChannelTree).view);
        }

        var pnids = model.get_children (typeof (Dactl.Pnid));
        foreach (var pnid in pnids.values) {
            GLib.message ("Adding PNID `%s' to box `%s'", pnid.id, id);
            view.add_child ((pnid as Dactl.Pnid).view);
        }

        var charts = model.get_children (typeof (Dactl.Chart));
        foreach (var chart in charts.values) {
            GLib.message ("Adding chart `%s' to box `%s'", chart.id, id);
            foreach (var constraint in (chart as Dactl.Chart).model.constraints) {
                var bind_constraint = new Clutter.BindConstraint (view, constraint.coordinate, constraint.offset);
                (chart as Dactl.Chart).view.add_constraint (bind_constraint);
            }
            view.add_child ((chart as Dactl.Chart).view);
        }
    }

    /**
     * {@inheritDoc}
     */
    public override void update_objects (Gee.Map<string, Dactl.Object> val) {
        model.objects = val;
    }
}
