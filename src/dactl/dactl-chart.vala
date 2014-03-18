/**
 * Chart data model class that is configurable using the application builder.
 */
public class Dactl.ChartModel : Dactl.AbstractContainer {

    /**
     * {@inheritDoc}
     */
    public override string id { get; set; default = "chart0"; }

    public string cell_ref { get; set; }

    /* Title */
    public string title { get; set; default = "Chart"; }

    /* Minimum height to support scrollable container */
    public int height_min { get; set; default = 100; }

    /* Minimum width to support scrollable container */
    public int width_min { get; set; default = 100; }

    /**
     * {@inheritDoc}
     */
    private Gee.Map<string, Dactl.Object> _objects;
    public override Gee.Map<string, Dactl.Object> objects {
        get { return _objects; }
        set { update_objects (value); }
    }

    public Gee.List<Dactl.UI.Constraint> constraints = new Gee.ArrayList<Dactl.UI.Constraint> ();

    /**
     * Common object construction.
     */
    construct {
        objects = new Gee.TreeMap<string, Dactl.Object> ();
    }

    /**
     * Default construction.
     */
    public ChartModel () { }

    /**
     * Construction using an XML node.
     */
    public ChartModel.from_xml_node (Xml.Node *node) {
        build_from_xml_node (node);
    }

    /**
     * {@inheritDoc}
     */
    public override void build_from_xml_node (Xml.Node *node) {
        string? value;

        if (node->type == Xml.ElementType.ELEMENT_NODE &&
            node->type != Xml.ElementType.COMMENT_NODE) {
            id = node->get_prop ("id");
            cell_ref = node->get_prop ("cellref");

            /* Iterate through node children */
            for (Xml.Node *iter = node->children; iter != null; iter = iter->next) {
                if (iter->name == "property") {
                    switch (iter->get_prop ("name")) {
                        case "title":
                            title = iter->get_content ();
                            break;
                        case "height-min":
                            value = iter->get_content ();
                            height_min = int.parse (value);
                            break;
                        case "width-min":
                            value = iter->get_content ();
                            width_min = int.parse (value);
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
                    if (type == "chart-axis") {
                        var axis_model = new AxisModel.from_xml_node (iter);
                        var axis = new Axis.with_model (axis_model);
                        this.add (axis);
                    } else if (type == "chart-trace") {
                        var trace_model = new TraceModel.from_xml_node (iter);
                        var trace = new Trace.with_model (trace_model);
                        this.add (trace);
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
 * Chart class to perform the drawing.
 */
public class Dactl.ChartView : Clutter.Actor {

    /**
     * Backend data model used to configure the class.
     */
    public ChartModel model { get; private set; }

    public Clutter.Canvas canvas;

    construct {
        canvas = new Clutter.Canvas ();
        /*
         *set_content (canvas);
         *set_content_gravity (Clutter.ContentGravity.CENTER);
         *set_content_scaling_filters (Clutter.ScalingFilter.TRILINEAR, Clutter.ScalingFilter.LINEAR);
         */
    }

    /**
     * Default construction.
     */
    public ChartView () {
        model = new ChartModel ();
        setup_stage ();
        connect_signals ();
    }

    /**
     * Construction using a provided data model.
     */
    public ChartView.with_model (ChartModel model) {
        this.model = model;
        setup_stage ();
        connect_signals ();
    }

    private void setup_stage () {
        //set_background_color (gdk_rgba_to_clutter_color (get_dactl_bg_color ()));

        var color = Clutter.Color () {
            red = (uint8)GLib.Random.int_range (0, 255),
            green = (uint8)GLib.Random.int_range (0, 255),
            blue = (uint8)GLib.Random.int_range (0, 255),
            alpha = 127
        };
        set_background_color (color);
        GLib.message ("Color: %s", color.to_string ());

        set_size (200, 200);
        reactive = true;

        x_expand = true;
        y_expand = true;
        x_align = Clutter.ActorAlign.CENTER;
        y_align = Clutter.ActorAlign.CENTER;

        /*
         *min_width = model.width_min;
         *min_height = model.height_min;
         */

        var layout = new Clutter.BinLayout (Clutter.BinAlignment.CENTER,
                                            Clutter.BinAlignment.CENTER);
        set_layout_manager (layout);
        name = "dactl-chart-%s".printf (model.id);

        /*
         *(canvas as Clutter.Content).invalidate ();
         */
    }

    /**
     * Connect any signals including the notifications from the model.
     */
    private void connect_signals () {

        /*
         *canvas.draw.connect (on_draw);
         *Clutter.Threads.Timeout.add (100, update);
         */

        this.button_release_event.connect (on_button_release);

        this.notify["x-expand"].connect (on_changed_cb);
        this.notify["y-expand"].connect (on_changed_cb);
        this.notify["x-align"].connect (on_changed_cb);
        this.notify["y-align"].connect (on_changed_cb);

        model.notify["title"].connect (() => {
            /* Change the title */
        });
    }

    /**
     * Button press callback.
     */
    private bool on_button_release (Clutter.ButtonEvent event) {
        Clutter.ActorAlign x_align, y_align;
        bool x_expand, y_expand;

        (this as GLib.Object).get ("x-align", out x_align,
                                   "y-align", out y_align,
                                   "x-expand", out x_expand,
                                   "y-expand", out y_expand);

        switch (event.button) {
            /* CLUTTER_BUTTON_PRIMARY = 1, couldn't find vapi mapping */
            case 1:
                if ((event.modifier_state & Clutter.ModifierType.SHIFT_MASK) != 0) {
                    if (y_align < 3)
                        y_align += 1;
                    else
                        y_align = 0;
                } else {
                    if (x_align < 3)
                        x_align += 1;
                    else
                        x_align = 0;
                }
                break;
            /* CLUTTER_BUTTON_SECONDARY = 3, couldn't find vapi mapping */
            case 3:
                if ((event.modifier_state & Clutter.ModifierType.SHIFT_MASK) != 0) {
                    y_expand = !y_expand;
                } else {
                    x_expand = !x_expand;
                }
                break;
            default:
                break;
        }

        GLib.message ("Button `%d' pressed on `%s'", (int)event.button, name);

        (this as GLib.Object).set ("x-align", x_align,
                                   "y-align", y_align,
                                   "x-expand", x_expand,
                                   "y-expand", y_expand);

        return true;
    }

    private string get_align_name (Clutter.ActorAlign align) {
        switch (align) {
            case Clutter.ActorAlign.FILL:
                return "fill";
            case Clutter.ActorAlign.START:
                return "start";
            case Clutter.ActorAlign.CENTER:
                return "center";
            case Clutter.ActorAlign.END:
                return "end";
            default:
                GLib.assert_not_reached ();
        }
    }

    /**
     * Property changed callback.
     */
    private void on_changed_cb (GLib.ParamSpec param_spec) {
        Clutter.ActorAlign x_align, y_align;
        bool x_expand, y_expand;

        (this as GLib.Object).get ("x-align", out x_align,
                                   "y-align", out y_align,
                                   "x-expand", out x_expand,
                                   "y-expand", out y_expand);

        GLib.message ("Actor `%s' changed: %s, %s - %s, %s",
                      name, x_expand.to_string (), y_expand.to_string (),
                      get_align_name (x_align), get_align_name (y_align));
    }

    /**
     * Draw callback.
     *
     * XXX wondering if spawning an async process would improve overall
     *     application performance in the cases where too many data points were
     *     selected
     */
    private bool on_draw (Cairo.Context cr, int w, int h) {

        cr.scale (w, h);
        cr.save ();
        cr.set_source_rgb (255, 0, 0);
        cr.paint();
        cr.restore ();

        return true;
    }

    /**
     * Callback to perform on the timeout interval.
     */
    private bool update () {
        (canvas as Clutter.Content).invalidate ();

        return true;
    }
}

public class Dactl.Chart : Dactl.AbstractObject {

    /* Property backing fields */
    private string _id;

    /**
     * {@inheritDoc}
     */
    public override string id {
        get { return model.id; }
        set { _id = model.id; }
    }

    public Dactl.ChartModel model { get; private set; }
    public Dactl.ChartView view { get; private set; }

    /**
     * Default construction.
     */
    public Chart () {
        model = new Dactl.ChartModel ();
        view = new Dactl.ChartView.with_model (model);
    }

    /**
     * Construction using a data model.
     */
    public Chart.with_model (Dactl.ChartModel model) {
        this.model = model;
        view = new Dactl.ChartView.with_model (model);
    }
}
