private class Dactl.ChartCanvas : Dactl.CustomWidget {

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

    public weak Dactl.Axis x_axis { get; set; }

    public weak Dactl.Axis y_axis { get; set; }

    private int padding_top = 40;

    private int padding_right = 40;

    private int padding_bottom = 80;

    private int padding_left = 80;

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

    construct {
        margin_top = 5;
        margin_right = 5;
        margin_bottom = 5;
        margin_left = 5;
    }

    public ChartCanvas () {
        add_events (Gdk.EventMask.BUTTON_PRESS_MASK |
                    Gdk.EventMask.BUTTON_RELEASE_MASK |
                    Gdk.EventMask.POINTER_MOTION_MASK |
                    Gdk.EventMask.KEY_PRESS_MASK |
                    Gdk.EventMask.KEY_RELEASE_MASK |
                    Gdk.EventMask.SCROLL_MASK);

        update ();

        set_size_request (320, 240);
    }

    // FIXME: Didn't expect to need internal CustomWidget classes
    public override void build_from_xml_node (Xml.Node *node) { }

    /**
     * Draw callback.
     */
    public override bool draw (Cairo.Context cr) {

        var parent = get_parent ();

        var w = get_allocated_width ();
        var h = get_allocated_height ();

        var grid_x = padding_left;
        var grid_y = padding_top;
        var grid_width = w - padding_left - padding_right;
        var grid_height = h - padding_top - padding_bottom;

        /* FIXME: probably won't work if min and max y are negative */

        var y_pos_range = Math.fabs ((y_axis.max / (y_axis.max - y_axis.min)) * grid_height);
        var y_neg_range = Math.fabs ((y_axis.min / (y_axis.max - y_axis.min)) * grid_height);
        var y_offset = y_pos_range;

        cr.set_antialias (Cairo.Antialias.SUBPIXEL);

        /* Grid */
        var grid_surface = new Cairo.ImageSurface (Cairo.Format.ARGB32, w, h);
        var grid_color = Gdk.RGBA () {
            red = 0.5,
            green = 0.5,
            blue = 0.5,
            alpha = 1.0
        };
        var grid = new Dactl.ChartGrid (grid_surface);
        grid.draw (x_axis, y_axis, grid_color, grid_width, grid_height);

        cr.set_operator (Cairo.Operator.OVER);
        cr.set_source_surface (grid.get_target (), grid_x, grid_y);
        cr.paint ();

        /* Axes */

        /* Labels */
        cr.set_source_rgb (0.5, 0.5, 0.5);
        cr.select_font_face ("sans-serif", Cairo.FontSlant.NORMAL, Cairo.FontWeight.BOLD);
        cr.set_font_size (12);
        cr.move_to (padding_left, padding_top - 5);
        cr.show_text ((parent as Dactl.Chart).title);

        /* Legend */

        return false;
    }

    public override bool button_press_event (Gdk.EventButton event) {
        return false;
    }

    public override bool button_release_event (Gdk.EventButton event) {
        return false;
    }

    public override bool motion_notify_event (Gdk.EventMotion event) {
        return false;
    }

    private bool update () {
        redraw ();
        return true;
    }

    public void redraw () {
        var window = get_window ();
        if (window == null) {
            return;
        }

        var region = window.get_clip_region ();
        // redraw the cairo canvas completely by exposing it
        window.invalidate_region (region, true);
        window.process_updates (true);
    }
}

[GtkTemplate (ui = "/org/coanda/libdactl/ui/chart.ui")]
public class Dactl.Chart : Dactl.CompositeWidget, Dactl.CldAdapter {

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

    /* Title */
    public string title { get; set; default = "Chart"; }

    /* Minimum height to support scrollable container */
    public int height_min { get; set; default = 100; }

    /* Minimum width to support scrollable container */
    public int width_min { get; set; default = 100; }

    [GtkChild]
    private Dactl.ChartCanvas canvas;

    /**
     * Common object construction.
     */
    construct {
        id = "chart0";
        canvas.id = "%s-canvas0".printf (id);
        objects = new Gee.TreeMap<string, Dactl.Object> ();

        hexpand = true;
        vexpand = true;
        halign = Gtk.Align.FILL;
        valign = Gtk.Align.FILL;
    }

    /**
     * Default construction.
     */
    public Chart () {
        var x_axis = new Dactl.Axis ();
        var y_axis = new Dactl.Axis ();
        x_axis.orientation = Dactl.Orientation.HORIZONTAL;
        y_axis.orientation = Dactl.Orientation.VERTICAL;
        add_child (x_axis);
        add_child (y_axis);
        canvas.x_axis = x_axis;
        canvas.y_axis = y_axis;
        request_data.begin ();
    }

    /**
     * Construction using an XML node.
     */
    public Chart.from_xml_node (Xml.Node *node) {
        build_from_xml_node (node);
        canvas.id = "%s-canvas0".printf (id);
        request_data.begin ();
    }

    /**
     * {@inheritDoc}
     */
    public override void build_from_xml_node (Xml.Node *node) {
        string? value;

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
                        case "expand":
                            value = iter->get_content ();
                            expand = bool.parse (value);
                            break;
                        case "fill":
                            value = iter->get_content ();
                            fill = bool.parse (value);
                            break;
                        case "height-min":
                            value = iter->get_content ();
                            height_min = int.parse (value);
                            break;
                        case "width-min":
                            value = iter->get_content ();
                            width_min = int.parse (value);
                            break;
                        default:
                            break;
                    }
                } else if (iter->name == "object") {
                    var type = iter->get_prop ("type");
                    if (type == "chart-axis") {
                        var axis = new Dactl.Axis.from_xml_node (iter);
                        this.add_child (axis);
                    }
                }
            }
        }
    }

    /**
     * {@inheritDoc}
     */
    public virtual void offer_cld_object (Cld.Object object) {

        if (satisfied) {
            /*
             *channels_loaded ();
             */

            message ("Updating the layout for `%s' using configured data", id);
            update_layout ();

            show_all ();
        }
    }

    private void update_layout () {
        var axes = get_object_map (typeof (Dactl.Axis));
        foreach (var axis in axes.values) {
            if ((axis as Dactl.Axis).orientation == Dactl.Orientation.HORIZONTAL) {
                /*
                 *bottom_axis_box.pack_start (axis as Gtk.Widget);
                 */
                canvas.x_axis = axis as Dactl.Axis;
            } else if ((axis as Dactl.Axis).orientation == Dactl.Orientation.VERTICAL) {
                /*
                 *left_axis_box.pack_start (axis as Gtk.Widget);
                 */
                canvas.y_axis = axis as Dactl.Axis;
            }
        }
    }

    /**
     * {@inheritDoc}
     */
    protected async void request_data () {
        /* XXX */
        satisfied = true;

        while (!satisfied) {
            // Try again in a second
            yield nap (1000);
        }
    }

    /**
     * Connect any signals including the notifications from the model.
     */
    private void connect_signals () {

        notify["title"].connect (() => {
            /* Change the title */
        });
    }

    /**
     * {@inheritDoc}
     */
    public override void update_objects (Gee.Map<string, Dactl.Object> val) {
        _objects = val;
    }
}
