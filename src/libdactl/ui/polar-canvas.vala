protected class Dactl.PolarChartCanvas : Dactl.Canvas {

    public weak Dactl.PolarAxis mag_axis { get; set; }

    public weak Dactl.PolarAxis angle_axis { get; set; }

    public weak Gtk.DrawingArea dwg_color_map { get; set; }

    public weak double zoom { get; set; default = 0.8; }
    /* To draw or not draw the grid */
    public bool draw_grid { get; set; }

    /* To draw or not draw the grid border */
    public bool draw_grid_border { get; set; }

    public Dactl.PolarChartGrid grid { get; private set; }

    public PolarChartCanvas () {
        add_events (Gdk.EventMask.BUTTON_PRESS_MASK |
                    Gdk.EventMask.BUTTON_RELEASE_MASK |
                    Gdk.EventMask.POINTER_MOTION_MASK |
                    Gdk.EventMask.KEY_PRESS_MASK |
                    Gdk.EventMask.KEY_RELEASE_MASK |
                    Gdk.EventMask.SCROLL_MASK);

        update ();

        set_size_request (320, 240);
    }

    /**
     * Draw callback.
     */
    public override bool draw (Cairo.Context cr) {
        cr.set_source_rgb (1, 1, 1);
        /*cr.set_source_rgba (1, 1, 1, 0.5);*/
        cr.paint ();

        var w = get_allocated_width ();
        var h = get_allocated_height ();
        var parent = get_parent ();
        var grid_surface = new Cairo.ImageSurface (Cairo.Format.ARGB32, w, h);
        grid = new Dactl.PolarChartGrid (grid_surface);

        cr.set_antialias (Cairo.Antialias.SUBPIXEL);

        /* Grid */
        if (draw_grid) {
            var grid_color = Gdk.RGBA () {
                red = 0.5,
                green = 0.5,
                blue = 0.5,
                alpha = 1.0
            };

            if (draw_grid_border) {
                grid.set_source_rgba (grid_color.red, grid_color.green, grid_color.blue, grid_color.alpha);
                grid.rectangle (0.5, 0.5, w, h);
                grid.set_line_width (1.0);
                grid.stroke ();
            }

            grid.draw (mag_axis, angle_axis, w, h, zoom);
            cr.set_operator (Cairo.Operator.OVER);
            cr.set_source_surface (grid.get_target (), 0, 0);
            cr.paint ();
        }

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
        queue_draw ();
    }
}


