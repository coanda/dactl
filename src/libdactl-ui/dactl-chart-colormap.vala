protected class Dactl.ColorMap : Dactl.Canvas, Dactl.Buildable, Dactl.Object {

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

    /* The color that min is mapped to */
    protected string min_color_spec { get; set; default = "black"; }

    protected Gdk.RGBA _min_color;

    public Gdk.RGBA min_color  {
        get { return _min_color; }
        set {
            _min_color = value;
            min_color_spec = min_color.to_string ();
        }
    }

    /* The color that max is mapped to */
    protected string max_color_spec { get; set; default = "white"; }

    protected Gdk.RGBA _max_color;

    public Gdk.RGBA max_color  {
        get { return _max_color; }
        set {
            _max_color = value;
            max_color_spec = max_color.to_string ();
        }
    }

    /**
     * The interpolation method used for color gradient
     */
    private Dactl.ColorGradientType _gradient;
    public Dactl.ColorGradientType gradient {
        get { return _gradient; }
        set {
            _gradient = value;
        }
    }

    public int div_major { get; set; default = 10; }

    public int div_minor { get; set; default = 2; }

    private bool dragging = false;

    public signal void range_changed (double min, double max);

    public signal void label_changed (string label);

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

        flags = Dactl.AxisFlag.DRAW_LABEL |
                Dactl.AxisFlag.DRAW_MINOR_TICKS |
                Dactl.AxisFlag.DRAW_MAJOR_TICKS |
                Dactl.AxisFlag.DRAW_MINOR_LABELS |
                Dactl.AxisFlag.DRAW_MAJOR_LABELS |
                Dactl.AxisFlag.DRAW_START_LABEL |
                Dactl.AxisFlag.DRAW_END_LABEL;

       width_request = 25;
    }

    /**
     * Default construction.
     */
    public ColorMap () {
        //update ();
    }

    /**
     * Construction using an XML node.
     */
    public ColorMap.from_xml_node (Xml.Node *node) {
        build_from_xml_node (node);
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
                        case "min-color":
                            min_color_spec = iter->get_content ();
                            _min_color.parse (min_color_spec);
                            break;
                        case "max-color":
                            max_color_spec = iter->get_content ();
                            _max_color.parse (max_color_spec);
                            break;
                        case "gradient":
                            var g = iter->get_content ();
                            gradient = Dactl.ColorGradientType.parse (g);
                            break;
                        default:
                            break;
                    }
                }
            }
        }
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
                        case "min-color":
                            iter->set_content (min_color_spec);
                            break;
                        case "max-color":
                            iter->set_content (max_color_spec);
                            break;
                        case "gradient":
                            iter->set_content (gradient.to_string ());
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

        Cairo.Pattern pat1 = new Cairo.Pattern.linear (0.0, 0.0,  0.0, h);
        for (int i = 0; i < h; i++) {
            double value = (double)i / (double)h;
            Gdk.RGBA color = Gdk.RGBA ();
            switch (gradient) {
                case Dactl.ColorGradientType.RGB:
                    color = Dactl.UI.rgb_lerp (value, min_color, 0, max_color, 1);
                    break;
                case Dactl.ColorGradientType.HSV:
                    color = Dactl.UI.hsv_lerp (value, min_color, 0, max_color, 1);
                    break;
                default:
                    break;
            }

            cr.set_source_rgba (color.red, color.green, color.blue, color.alpha);
            cr.rectangle (20, h - i, w - 20, 1);
            cr.fill ();
        }

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

            tick_layout_list.append (layout);
        }

        cr.set_source_rgba (1.0, 1.0, 1.0, 1.0);

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
        return false;
    }
}

