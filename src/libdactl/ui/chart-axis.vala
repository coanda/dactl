[Flags]
public enum Dactl.AxisFlag {
    DRAW_LABEL          = 0x001,
    DRAW_MINOR_TICKS    = 0x002,
    DRAW_MAJOR_TICKS    = 0x004,
    DRAW_MINOR_LABELS   = 0x008,
    DRAW_MAJOR_LABELS   = 0x010,
    DRAW_START_LABEL    = 0x020,
    DRAW_END_LABEL      = 0x040,
    ROTATE_LABEL        = 0x080,
    REVERSE_ORDER       = 0x100;

    public Dactl.AxisFlag set (Dactl.AxisFlag flag) {
        return (this | flag);
    }

    public Dactl.AxisFlag unset (Dactl.AxisFlag flag) {
        return (this & ~flag);
    }

    public bool is_set (Dactl.AxisFlag flag) {
        return (flag in this);
    }
}

public class Dactl.Axis : Dactl.Canvas, Dactl.Buildable, Dactl.Object {

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

    /* Axis label */
    private string _label;
    public string label {
        get {
            return _label;
        }
        set {
            _label = value;
        }
        default = "Axis";
    }

    public Dactl.AxisFlag flags { get; set; }

    public bool show_label { get; set; default = true; }

    /* Orientation of the axis */
    public Dactl.Orientation orientation { get; set; default = Dactl.Orientation.HORIZONTAL; }

    private double _min;
    public double min {
        get {
            return _min;
        }
        set {
            _min = value;
        }
    }

    public double _max;
    public double max {
        get {
            return _max;
        }
        set {
            _max = value;
        }
    }

    public int div_major { get; set; default = 10; }

    public int div_minor { get; set; default = 2; }

    private bool dragging = false;

    public signal void range_changed (double min, double max);

    public signal void label_changed (string label);

    public signal void orientation_changed (Dactl.Orientation orientation);

    private double start_min;

    private double start_max;

    //private double cursor_x;

    //private double cursor_y;

    private double start_drag_x;

    private double start_drag_y;

    private bool reversed = false;

    /**
     * {@inheritDoc}
     */
    protected string xml {
        get { return _xml; }
    }

    /**
     * {@inheritDoc}
     */
    protected string xsd {
        get { return _xsd; }
    }

    construct {
        id = "axis0";
        start_min = min;
        start_max = max;

        /*
         *add_events (Gdk.EventMask.BUTTON_PRESS_MASK |
         *            Gdk.EventMask.BUTTON_RELEASE_MASK |
         *            Gdk.EventMask.POINTER_MOTION_MASK |
         *            Gdk.EventMask.KEY_PRESS_MASK |
         *            Gdk.EventMask.KEY_RELEASE_MASK |
         *            Gdk.EventMask.SCROLL_MASK);
         */

        flags = Dactl.AxisFlag.DRAW_LABEL |
                Dactl.AxisFlag.DRAW_MINOR_TICKS |
                Dactl.AxisFlag.DRAW_MAJOR_TICKS |
                Dactl.AxisFlag.DRAW_MINOR_LABELS |
                Dactl.AxisFlag.DRAW_MAJOR_LABELS |
                Dactl.AxisFlag.DRAW_START_LABEL |
                Dactl.AxisFlag.DRAW_END_LABEL;
    }

    /**
     * Default construction.
     */
    public Axis () {
        //update ();
    }

    /**
     * Construction using an XML node.
     */
    public Axis.from_xml_node (Xml.Node *node) {
        build_from_xml_node (node);
        start_min = min;
        start_max = max;
        //update ();
    }

    /**
     * {@inheritDoc}
     */
    internal void build_from_xml_node (Xml.Node *node) {

        string value;

        this.node = node;

        if (node->type == Xml.ElementType.ELEMENT_NODE &&
            node->type != Xml.ElementType.COMMENT_NODE) {
            id = node->get_prop ("id");

            /* Iterate through node children */
            for (Xml.Node *iter = node->children; iter != null; iter = iter->next) {
                if (iter->name == "property") {
                    switch (iter->get_prop ("name")) {
                        case "label":
                            label = iter->get_content ();
                            break;
                        case "orientation":
                            value = iter->get_content ();
                            orientation = Dactl.Orientation.parse (value);
                            break;
                        case "min":
                            value = iter->get_content ();
                            min = double.parse (value);
                            break;
                        case "max":
                            value = iter->get_content ();
                            max = double.parse (value);
                            break;
                        case "div-major":
                            value = iter->get_content ();
                            div_major = int.parse (value);
                            break;
                        case "div-minor":
                            value = iter->get_content ();
                            div_minor = int.parse (value);
                            break;
                        case "show-label":
                            value = iter->get_content ();
                            show_label = bool.parse (value);
                            flags = (bool.parse (value))
                                  ? flags.set (Dactl.AxisFlag.DRAW_LABEL)
                                  : flags.unset (Dactl.AxisFlag.DRAW_LABEL);
                            break;
                        case "show-minor-ticks":
                            value = iter->get_content ();
                            flags = (bool.parse (value))
                                  ? flags.set (Dactl.AxisFlag.DRAW_MINOR_TICKS)
                                  : flags.unset (Dactl.AxisFlag.DRAW_MINOR_TICKS);
                            break;
                        case "show-major-ticks":
                            value = iter->get_content ();
                            flags = (bool.parse (value))
                                  ? flags.set (Dactl.AxisFlag.DRAW_MAJOR_TICKS)
                                  : flags.unset (Dactl.AxisFlag.DRAW_MAJOR_TICKS);
                            break;
                        case "show-minor-labels":
                            value = iter->get_content ();
                            flags = (bool.parse (value))
                                  ? flags.set (Dactl.AxisFlag.DRAW_MINOR_LABELS)
                                  : flags.unset (Dactl.AxisFlag.DRAW_MINOR_LABELS);
                            break;
                        case "show-major-labels":
                            value = iter->get_content ();
                            flags = (bool.parse (value))
                                  ? flags.set (Dactl.AxisFlag.DRAW_MAJOR_LABELS)
                                  : flags.unset (Dactl.AxisFlag.DRAW_MAJOR_LABELS);
                            break;
                        case "show-start-label":
                            value = iter->get_content ();
                            flags = (bool.parse (value))
                                  ? flags.set (Dactl.AxisFlag.DRAW_START_LABEL)
                                  : flags.unset (Dactl.AxisFlag.DRAW_START_LABEL);
                            break;
                        case "show-end-label":
                            value = iter->get_content ();
                            flags = (bool.parse (value))
                                  ? flags.set (Dactl.AxisFlag.DRAW_END_LABEL)
                                  : flags.unset (Dactl.AxisFlag.DRAW_END_LABEL);
                            break;
                        case "rotate-label":
                            message ("setting rotate label");
                            value = iter->get_content ();
                            message ("%s", value);
                            flags = (bool.parse (value))
                                  ? flags.set (Dactl.AxisFlag.ROTATE_LABEL)
                                  : flags.unset (Dactl.AxisFlag.ROTATE_LABEL);
                            if (this != null)
                                message ("flags is not null");

                            break;
                        default:
                            break;
                    }
                }
            }
        }
        do_flags ();
        connect_notify_signals ();
    }

    /**
     * Connect all notify signals to update node
     */
    protected void connect_notify_signals () {
        Type type = get_type ();
        ObjectClass ocl = (ObjectClass)type.class_ref ();

        foreach (ParamSpec spec in ocl.list_properties ()) {
            notify[spec.get_name ()].connect ((s, p) => {
                update_node ();
                queue_draw ();
            });
        }

        notify["flags"].connect ((s, p) => {
            do_flags ();
        });
    }

    private void do_flags () {


    }

    /**
     * Update the XML Node for this object.
     */
    protected void update_node () {
        if (node->type == Xml.ElementType.ELEMENT_NODE &&
            node->type != Xml.ElementType.COMMENT_NODE) {
            /* iterate through node children */
            for (Xml.Node *iter = node->children;
                 iter != null;
                 iter = iter->next) {
                if (iter->name == "property") {
                    switch (iter->get_prop ("name")) {
                        case "label":
                            iter->set_content (label);
                            break;
                        case "orientation":
                            iter->set_content (orientation.to_string ());
                            break;
                        case "min":
                            iter->set_content ("%.6f".printf (min));
                            break;
                        case "max":
                            iter->set_content ("%.6f".printf (max));
                            break;
                        case "div-major":
                            iter->set_content ("%d".printf (div_major));
                            break;
                        case "div-minor":
                            iter->set_content ("%d".printf (div_minor));
                            break;
                        case "show-label":
                            iter->set_content ("%s".printf (flags.is_set (
                                      Dactl.AxisFlag.DRAW_LABEL).to_string ()));
                            break;
                        case "show-minor-ticks":
                            iter->set_content ("%s".printf (flags.is_set (
                                Dactl.AxisFlag.DRAW_MINOR_TICKS).to_string ()));
                            break;
                        case "show-major-ticks":
                            iter->set_content ("%s".printf (flags.is_set (
                                Dactl.AxisFlag.DRAW_MAJOR_TICKS).to_string ()));
                            break;
                        case "show-minor-labels":
                            iter->set_content ("%s".printf (flags.is_set (
                               Dactl.AxisFlag.DRAW_MINOR_LABELS).to_string ()));
                            break;
                        case "show-major-labels":
                            iter->set_content ("%s".printf (flags.is_set (
                               Dactl.AxisFlag.DRAW_MAJOR_LABELS).to_string ()));
                            break;
                        case "show-start-label":
                            iter->set_content ("%s".printf (flags.is_set (
                                Dactl.AxisFlag.DRAW_START_LABEL).to_string ()));
                            break;
                        case "show-end-label":
                            iter->set_content ("%s".printf (flags.is_set (
                                  Dactl.AxisFlag.DRAW_END_LABEL).to_string ()));
                            break;
                        case "rotate-label":
                            iter->set_content ("%s".printf (flags.is_set (
                                    Dactl.AxisFlag.ROTATE_LABEL).to_string ()));
                            break;
                        default:
                            break;
                    }
                }
            }
        }
    }

    /**
     * Draw callback.
     */
    public override bool draw (Cairo.Context cr) {
        var w = get_allocated_width ();
        var h = get_allocated_height ();

        int major_tick_height = 8;
        int minor_tick_height = 5;

        // ticks
        var x = 0;
        var y = 0;

        GLib.List<Pango.Layout> tick_layout_list = new GLib.List<Pango.Layout> ();

        for (var i = 0; i <= div_major; i++) {
            string tick_label;
            if (this.flags.is_set (Dactl.AxisFlag.REVERSE_ORDER)) {
                if ((min < -9999) || (max > 9999)) {
                    tick_label = "%.3e".printf (min);
                    if (i > 0)
                        tick_label = "%.3e".printf (min + (((max - min) / div_major) * i));
                } else {
                    tick_label = "%.1f".printf (min);
                    if (i > 0)
                        tick_label = "%.1f".printf (min + (((max - min) / div_major) * i));
                }
            } else {
                if ((min < -9999) || (max > 9999)) {
                    tick_label = "%.3e".printf (max);
                    if (i > 0)
                        tick_label = "%.3e".printf (max - (((max - min) / div_major) * i));
                } else {
                    tick_label = "%.1f".printf (max);
                    if (i > 0)
                        tick_label = "%.1f".printf (max - (((max - min) / div_major) * i));
                }
            }
            var layout = create_pango_layout (tick_label);

            var desc = Pango.FontDescription.from_string ("Normal 100");
            layout.set_font_description (desc);
            string markup = "<span font='8'>%s</span>".printf (tick_label);
            layout.set_markup (markup, -1);
            var context = layout.get_context ();
            /* XXX Label rotate does not work */
            if (flags.is_set (Dactl.AxisFlag.ROTATE_LABEL)) {
                context.set_base_gravity (Pango.Gravity.SOUTH);
            } else {
                context.set_base_gravity (Pango.Gravity.WEST);
            }

            tick_layout_list.append (layout);
        }

        cr.set_source_rgba (1.0, 1.0, 1.0, 1.0);
        if (orientation == Dactl.Orientation.HORIZONTAL) {
            for (var i = 0; i <= div_major; i++) {
                x = i * w / div_major;
                /* Shift the first one over a bit */
                if (i == 0) {
                    x += 1;
                }

                if (this.flags.is_set (Dactl.AxisFlag.DRAW_MAJOR_TICKS)) {
                    cr.move_to (x, y);
                    cr.line_to (x, major_tick_height);
                    cr.set_line_width (1);
                    cr.stroke ();
                }

                /* Draw label */
                if (((i != 0) && (i != div_major) && flags.is_set (Dactl.AxisFlag.DRAW_MAJOR_LABELS)) ||
                    (flags.is_set (Dactl.AxisFlag.DRAW_START_LABEL) && (i == 0)) ||
                    (flags.is_set (Dactl.AxisFlag.DRAW_END_LABEL) && (i == div_major))) {

                    int fontw, fonth;
                    var layout = tick_layout_list.nth_data (div_major - i);
                    layout.get_pixel_size (out fontw, out fonth);
                    if (i == div_major)
                        cr.move_to (x - fontw, y + major_tick_height + 2);
                    else
                        cr.move_to (x, y + major_tick_height + 2);
                    Pango.cairo_update_layout (cr, layout);
                    Pango.cairo_show_layout (cr, layout);
                }

            }

            /* Draw minor ticks */
            if (this.flags.is_set (Dactl.AxisFlag.DRAW_MINOR_TICKS)) {
                for (var i = 0; i <= (div_major * div_minor); i++) {
                    x = i * w / (div_major * div_minor);
                    cr.move_to (x, y);
                    cr.line_to (x, minor_tick_height);
                    cr.set_line_width (0.5);
                    cr.stroke ();
                }
            }
        } else if (orientation == Dactl.Orientation.VERTICAL) {
            x = w - major_tick_height;
            for (var i = 0; i <= div_major; i++) {
                y = i * h / div_major;
                /* Shift the first one over a bit */
                if (i == 0) {
                    y += 1;
                }

                if (this.flags.is_set (Dactl.AxisFlag.DRAW_MAJOR_TICKS)) {
                    cr.move_to (x, y);
                    cr.line_to (w, y);
                    cr.set_line_width (1);
                    cr.stroke ();
                }

                /* Draw label */
                if (((i != 0) && (i != div_major) && flags.is_set (Dactl.AxisFlag.DRAW_MAJOR_LABELS)) ||
                    (flags.is_set (Dactl.AxisFlag.DRAW_START_LABEL) && (i == 0)) ||
                    (flags.is_set (Dactl.AxisFlag.DRAW_END_LABEL) && (i == div_major))) {

                    int fontw, fonth;
                    /*var layout = tick_layout_list.nth_data (div_major - i);*/
                    var layout = tick_layout_list.nth_data (i);
                    layout.get_pixel_size (out fontw, out fonth);
                    if (i == div_major)
                        cr.move_to (0, y - fonth);
                    else if (i == 0)
                        cr.move_to (0, y);
                    else
                        cr.move_to (0, y - (fonth / 2));
                    Pango.cairo_update_layout (cr, layout);
                    /*XXX This is one way to rotate the text*/
                    /*
                     *cr.save ();
                     *cr.rotate (-1 * GLib.Math.PI/4);
                     *cr.rel_move_to (- 15, 0);
                     */
                    Pango.cairo_show_layout (cr, layout);
                    /*cr.restore ();*/
                }
            }

            /* Draw minor ticks */
            if (this.flags.is_set (Dactl.AxisFlag.DRAW_MINOR_TICKS)) {
                x = w - minor_tick_height;
                for (var i = 0; i <= (div_major * div_minor); i++) {
                    y = i * h / (div_major * div_minor);
                    cr.move_to (x, y);
                    cr.line_to (w, y);
                    cr.set_line_width (0.5);
                    cr.stroke ();
                }
            }
        }

/*
 *
 *        for (var i = 0; i <= div_major; i++) {
 *            if (orientation == Dactl.Orientation.HORIZONTAL) {
 *                x = (w / div_major) * i + (1 * i);
 *                if (i == 0)
 *                    x += 1;
 *                else {
 *                    x -= (int)(i * 0.5);
 *                    x += 1;
 *                }
 *                cr.move_to (x, y);
 *                cr.line_to (x, major_tick_height);
 *                cr.set_line_width (1);
 *                cr.stroke ();
 *
 *                // draw label
 *                int fontw, fonth;
 *                var layout = tick_layout_list.nth_data (i);
 *                layout.get_pixel_size (out fontw, out fonth);
 *                if (i == div_major)
 *                    cr.move_to (x - fontw, y + major_tick_height + 2);
 *                else
 *                    cr.move_to (x, y + major_tick_height + 2);
 *                Pango.cairo_update_layout (cr, layout);
 *                Pango.cairo_show_layout (cr, layout);
 *
 *                // draw minor ticks
 *                for (var j = 1; j < div_minor; j++) {
 *                    x += (w / div_major) / div_minor;
 *                    cr.move_to (x, y);
 *                    cr.line_to (x, minor_tick_height);
 *                    cr.set_line_width (0.5);
 *                    cr.stroke ();
 *                }
 *            } else if (orientation == Dactl.Orientation.VERTICAL) {
 *                x = w - major_tick_height;
 *                if (i == 0)
 *                    y += 1;
 *                else
 *                    y += (h / div_major);
 *                cr.move_to (x, y);
 *                cr.line_to (w, y);
 *                cr.set_line_width (1);
 *                cr.stroke ();
 *
 *                // draw label
 *                int fontw, fonth;
 *                var layout = tick_layout_list.nth_data (i);
 *                layout.get_pixel_size (out fontw, out fonth);
 *                if (i == div_major)
 *                    cr.move_to (0, y - fonth);
 *                else if (i == 0)
 *                    cr.move_to (0, y);
 *                else
 *                    cr.move_to (0, y - (fonth / 2));
 *                Pango.cairo_update_layout (cr, layout);
 *                Pango.cairo_show_layout (cr, layout);
 *
 *                // draw minor ticks
 *                x = w - minor_tick_height;
 *                for (var j = 1; j < div_minor; j++) {
 *                    y += (h / div_major) / div_minor;
 *                    cr.move_to (x, y);
 *                    cr.line_to (w, y);
 *                    cr.set_line_width (0.5);
 *                    cr.stroke ();
 *                }
 *            }
 *        }
 *
 */
        return false;
    }

/*
 *    public override bool scroll_event (Gdk.EventScroll event) {
 *        var modifiers = Gtk.accelerator_get_default_mod_mask ();
 *
 *        var w = get_allocated_width ();
 *        var h = get_allocated_height ();
 *
 *        var pos = (orientation == Dactl.Orientation.HORIZONTAL)
 *                    ? (event.x - (w / 2)) >= 0
 *                    : (event.y - (h / 2)) >= 0;
 *
 *        if (event.direction == Gdk.ScrollDirection.UP) {
 *            // Zooming in needs to be restricted
 *            if ((event.state & modifiers) == Gdk.ModifierType.MOD1_MASK) {
 *                min = (max - min >= 2) ? min + 1 : min;
 *                max = (max - min >= 2) ? max - 1 : max;
 *            } else if ((event.state & modifiers) == Gdk.ModifierType.CONTROL_MASK) {
 *                if (pos) {
 *                    max += 5;
 *                } else {
 *                    min = (max - min >= 6) ? min + 5 : min;
 *                }
 *            } else {
 *                min = (max - min >= 6) ? min + 5 : min;
 *                max = (max - min >= 6) ? max - 5 : max;
 *            }
 *        } else if (event.direction == Gdk.ScrollDirection.DOWN) {
 *            if ((event.state & modifiers) == Gdk.ModifierType.MOD1_MASK) {
 *                min -= 1;
 *                max += 1;
 *            } else if ((event.state & modifiers) == Gdk.ModifierType.CONTROL_MASK) {
 *                if (pos) {
 *                    max = (max - min >= 6) ? max - 5 : max;
 *                } else {
 *                    min -= 5;
 *                }
 *            } else {
 *                min -= 5;
 *                max += 5;
 *            }
 *        }
 *
 *        emit_range_changed_signal ((int) event.x, (int) event.y);
 *
 *        return false;
 *    }
 */

/*
 *    public override bool button_press_event (Gdk.EventButton event) {
 *        this.dragging = true;
 *
 *        start_drag_x = event.x;
 *        start_drag_y = event.y;
 *
 *        // Show popup menu
 *        if (event.button == Gdk.BUTTON_SECONDARY) {
 *            this.dragging = false;
 *            // Popup menu
 *            var menu = new Gtk.Menu ();
 *            menu.attach_widget = this;
 *            var item_reset = new Gtk.MenuItem.with_label ("Reset");
 *            item_reset.activate.connect (() => {
 *                min = start_min;
 *                max = start_max;
 *                emit_range_changed_signal ((int) event.x, (int) event.y);
 *            });
 *            menu.append (item_reset);
 *            menu.show_all ();
 *            menu.popup (null, null, null, event.button, event.time);
 *        }
 *
 *        return false;
 *    }
 */

/*
 *    public override bool button_release_event (Gdk.EventButton event) {
 *        if (this.dragging) {
 *            this.dragging = false;
 *            emit_range_changed_signal ((int) event.x, (int) event.y);
 *        }
 *
 *        return false;
 *    }
 */

/*
 *    public override bool motion_notify_event (Gdk.EventMotion event) {
 *        //cursor_x = event.x;
 *        //cursor_y = event.y;
 *
 *        if (this.dragging) {
 *            emit_range_changed_signal ((int) event.x, (int) event.y);
 *        }
 *        return false;
 *    }
 */

/*
 *    private void emit_range_changed_signal (int x, int y) {
 *        // decode the x/y information to use as a range change
 *        var dx = 0.0;
 *        var dy = 0.0;
 *
 *        // XXX this is causing some bugs
 *
 *        if (orientation == Dactl.Orientation.HORIZONTAL) {
 *            if (x - start_drag_x >= 5.0) {
 *                dx = 5.0;
 *            } else if (x - start_drag_x <= 5.0) {
 *                dx = -5.0;
 *            }
 *            min += dx;
 *            max += dx;
 *        } else {
 *            if (y - start_drag_y >= 5.0) {
 *                dy = 5.0;
 *            } else if (y - start_drag_y <= 5.0) {
 *                dy = -5.0;
 *            }
 *            min += dy;
 *            max += dy;
 *        }
 *
 *        redraw_canvas ();
 *
 *        range_changed (min, max);
 *    }
 */

/*
 *    private void redraw_canvas () {
 *        var window = get_window ();
 *        if (window == null) {
 *            return;
 *        }
 *
 *        var region = window.get_clip_region ();
 *        // redraw the cairo canvas completely by exposing it
 *        window.invalidate_region (region, true);
 *        window.process_updates (true);
 *    }
 */

    /*
     *private bool update () {
     *    redraw_canvas ();
     *    return true;
     *}
     */
}
