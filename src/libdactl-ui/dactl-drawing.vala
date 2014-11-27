[Compact]
private class Dactl.ChartGrid : Cairo.Context {

    public ChartGrid (Cairo.Surface target) {
        base (target);
    }

    public void draw (Dactl.Axis x_axis, Dactl.Axis y_axis, Gdk.RGBA color, int w, int h) {
        double w_major = (double)w / x_axis.div_major;
        double w_minor = w_major / x_axis.div_minor;
        double h_major = (double)h / y_axis.div_major;
        double h_minor = h_major / y_axis.div_minor;

        /* Draw border - possibly wrong place for this? */
        set_source_rgba (color.red, color.green, color.blue, color.alpha);
        rectangle (1, 1, w, h);
        set_line_width (1);
        stroke ();

        /* X axis */
        double x_major = w_major;
        double x_minor = w_minor;
        for (var i = 0; i < x_axis.div_major; i++) {

            set_dash ({3, 5}, 0);
            set_source_rgba (color.red, color.green, color.blue, 3 * color.alpha / 4);
            for (var j = 1; j < x_axis.div_minor; j++) {
                move_to (x_minor, 0);
                line_to (x_minor, h);
                set_line_width (0.5);
                stroke ();
                x_minor += w_minor;
            }
            set_dash (null, 0);

            x_minor = (w_major * (i + 1)) + w_minor;

            if (i > 0) {
                set_source_rgba (color.red, color.green, color.blue, color.alpha);
                move_to (x_major, 0);
                line_to (x_major, h);
                set_line_width (1);
                stroke ();
                x_major += w_major;
            }
        }

        /* Y axis */
        double y_major = h_major;
        double y_minor = h_minor;
        for (var i = 0; i < y_axis.div_major; i++) {

            set_dash ({3, 5}, 0);
            set_source_rgba (color.red, color.green, color.blue, 3 * color.alpha / 4);
            for (var j = 1; j < y_axis.div_minor; j++) {
                move_to (0, y_minor);
                line_to (w, y_minor);
                set_line_width (0.5);
                stroke ();
                y_minor += h_minor;
            }
            set_dash (null, 0);

            y_minor = (h_major * (i + 1)) + h_minor;

            if (i > 0) {
                set_source_rgba (color.red, color.green, color.blue, color.alpha);
                move_to (0, y_major);
                line_to (w, y_major);
                set_line_width (1);
                stroke ();
                y_major += h_major;
            }
        }
    }
}

[Compact]
private class Dactl.Line : Cairo.Context {

    public Line (Cairo.Surface target) {
        base (target);
    }

    public void draw (Dactl.Point[] data) {

        for (var i = 0; i < data.length - 1; i++) {
            var p1 = data[i];
            var p2 = data[i + 1];

            //stdout.printf ("%d of %d - %.3f : %.3f - %.3f : %.3f\n", i + 1, data.length, p1.x, p1.y, p2.x, p2.y);

            /* Draw the line segment */
            move_to (p1.x, p1.y);
            line_to (p2.x, p2.y);
        }

        stroke ();
    }
}

[Compact]
private class Dactl.Polyline : Cairo.Context {

    public Polyline (Cairo.Surface target) {
        base (target);
    }

    public void draw (Dactl.Point[] data) {

        int i;
        double x, y, x2, y2, xl, yl, xr, yr, xls, xrs;
        double pdx, pdy, cx1, cy1, cx2, cy2, pdx1, pdy1, pdx2, pdy2, ph;
        double[,] poly_data = new double[data.length, 6];

        for (i = 0; i < data.length; i++) {
            var point = data[i];
            x = point.x;
            y = point.y;

            if ((i != 0) && (i != data.length - 1)) {
                // calculate left hand point data
                var prev_point = data[i - 1];
                xl = prev_point.x;
                yl = prev_point.y;

                // calculate right hand point data
                var next_point = data[i + 1];
                xr = next_point.x;
                yr = next_point.y;

                // calculate left/right step width and some other polyline drawing data
                xls = (x - xl) / 2;
                xrs = (xr - x) / 2;
                pdx = xr - xl;
                pdy = yr - yl;
                ph = Math.sqrt (pdx*pdx + pdy*pdy);

                // calculate control point data
                if (ph == 0.0) {
                    cx1 = x;
                    cy1 = y;
                    cx2 = x;
                    cy2 = y;
                } else {
                    pdx1 = (pdx * xls) / ph;
                    pdy1 = (pdy * xls) / ph;
                    pdx2 = (pdx * xrs) / ph;
                    pdy2 = (pdy * xrs) / ph;
                    cx1 = x - pdx1;
                    cx2 = x + pdx2;
                    cy1 = y - pdy1;
                    cy2 = y + pdy2;
                }
            } else {
                cx1 = x;
                cy1 = y;
                cx2 = x;
                cy2 = y;
            }

            poly_data[i, 0] = x;
            poly_data[i, 1] = y;
            poly_data[i, 2] = cx1;
            poly_data[i, 3] = cy1;
            poly_data[i, 4] = cx2;
            poly_data[i, 5] = cy2;
        }

        for (i = 0; i < poly_data.length[0] - 1; i++) {
            x   = poly_data[i, 0];
            y   = poly_data[i, 1];
            cx1 = poly_data[i, 4];
            cy1 = poly_data[i, 5];
            cx2 = poly_data[i+1, 2];
            cy2 = poly_data[i+1, 3];
            x2  = poly_data[i+1, 0];
            y2  = poly_data[i+1, 1];
            move_to (x, y);
            curve_to (cx1, cy1, cx2, cy2, x2, y2);
        }

        stroke ();
    }
}

[Compact]
private class Dactl.Scatter : Cairo.Context {

    public Scatter (Cairo.Surface target) {
        base (target);
    }

    public void draw (Dactl.Point[] data) {
        for (var i = 0; i < data.length; i++) {
            var point = data[i];
            arc (point.x, point.y, 2.0, 0, 2 * Math.PI);
            stroke ();
        }
    }
}

[Compact]
private class Dactl.Bar : Cairo.Context {

    public Bar (Cairo.Surface target) {
        base (target);
    }

    public void draw (Dactl.Point[] data, Dactl.Point origin, bool outline = false) {
        var x = origin.x + 1.0;
        for (var i = 0; i < data.length - 1; i++) {
            rectangle (x, data[i].y, data[1].x, origin.y - data[i].y);
            fill ();

            if (outline) {
                save ();
                set_source_rgb (0.0, 0.0, 0.0);
                rectangle (x, data[i].y, data[1].x, origin.y - data[i].y);
                stroke ();
                restore ();
            }

            x += data[1].x;
        }
    }
}

[Compact]
private class Dactl.Ring : Cairo.Context {

    public Ring (Cairo.Surface target) {
        base (target);
    }

    public void draw (double x, double y, double radius, double percent,
                      double start_angle, double end_angle, double width) {
        var theta_0 = start_angle * (2 * Math.PI / 360) - Math.PI_2;
        var theta_f = end_angle * (2 * Math.PI / 360) - Math.PI_2;
        var t_arc = percent * (theta_f - theta_0);

        // Draw background ring
        arc (x, y, radius, theta_0, theta_f);
        set_line_width (width);
        stroke ();

        // Draw indicator ring
        arc (x, y, radius, theta_0, theta_f + t_arc);
        stroke ();
    }
}

[Compact]
private class Dactl.Vector : Cairo.Context {

    public Vector (Cairo.Surface target) {
        base (target);
    }

    public void draw () {
    }
}

[Compact]
private class Dactl.VectorField : Cairo.Context {

    public VectorField (Cairo.Surface target) {
        base (target);
    }

    public void draw () {
    }
}

[Compact]
private class Dactl.AxisView : Cairo.Context {

    public AxisView (Cairo.Surface target) {
        base (target);
    }

    public void draw (int w, int h, Dactl.Axis axis) {
        int major_tick_height = 8;
        int minor_tick_height = 5;
        int div_major = axis.div_major;
        int div_minor = axis.div_minor;
        double min = axis.min;
        double max = axis.max;
        int orientation = axis.orientation;

        /* ticks */
        var x = 0;
        var y = 0;

        GLib.List<Pango.Layout> tick_layout_list = new GLib.List<Pango.Layout> ();

        for (var i = 0; i <= div_major; i++) {
            string tick_label = "%.1f".printf (min);
            if (i > 0)
                tick_label = "%.1f".printf (min + (((max - min) / div_major) * i));
            var layout = axis.create_pango_layout (tick_label);
            var desc = Pango.FontDescription.from_string ("Normal 100");
            layout.set_font_description (desc);
            string markup = "<span font='8'>%s</span>".printf (tick_label);
            layout.set_markup (markup, -1);
            tick_layout_list.append (layout);
        }

        if (orientation == Dactl.Orientation.HORIZONTAL) {
            for (var i = 0; i <= div_major; i++) {
                x = i * w / div_major;
                /* Shift the first one over a bit */
                if (i == 0) {
                    x += 1;
                }
                this.move_to (x, y);
                this.line_to (x, major_tick_height);
                this.set_line_width (1);
                this.stroke ();

                /* draw label */
                int fontw, fonth;
                var layout = tick_layout_list.nth_data (div_major - i);
                layout.get_pixel_size (out fontw, out fonth);
                if (i == div_major)
                    this.move_to (x - fontw, y + major_tick_height + 2);
                else
                    this.move_to (x, y + major_tick_height + 2);
                Pango.cairo_update_layout (this, layout);
                Pango.cairo_show_layout (this, layout);
            }

            /* draw minor ticks */
            for (var i = 0; i <= (div_major * div_minor); i++) {
                x = i * w / (div_major * div_minor);
                this.move_to (x, y);
                this.line_to (x, minor_tick_height);
                this.set_line_width (0.5);
                this.stroke ();
            }

        } else if (orientation == Dactl.Orientation.VERTICAL) {
            x = w - major_tick_height;
            for (var i = 0; i <= div_major; i++) {
                y = i * h / div_major;
                /* Shift the first one over a bit */
                if (i == 0) {
                    y += 1;
                }
                this.move_to (x, y);
                this.line_to (w, y);
                this.set_line_width (1);
                this.stroke ();

                /* draw label */
                int fontw, fonth;
                var layout = tick_layout_list.nth_data (div_major - i);
                layout.get_pixel_size (out fontw, out fonth);
                if (i == div_major)
                    this.move_to (0, y - fonth);
                else if (i == 0)
                    this.move_to (0, y);
                else
                    this.move_to (0, y - (fonth / 2));
                Pango.cairo_update_layout (this, layout);
                Pango.cairo_show_layout (this, layout);
            }

            /* draw minor ticks */
            x = w - minor_tick_height;
            for (var i = 0; i <= (div_major * div_minor); i++) {
                y = i * h / (div_major * div_minor);
                this.move_to (x, y);
                this.line_to (w, y);
                this.set_line_width (0.5);
                this.stroke ();
            }
        }

 /*
  *        this.set_source_rgba (0.5, 0.5, 0.5, 0.75);
  *
  *        if (orientation == Dactl.Orientation.HORIZONTAL) {
  *            this.move_to (cursor_x, 0);
  *            this.line_to (cursor_x, h);
  *            this.set_line_width (1);
  *            this.stroke ();
  *        } else if (orientation == Dactl.Orientation.VERTICAL) {
  *            this.move_to (0, cursor_y);
  *            this.line_to (w, cursor_y);
  *            this.set_line_width (1);
  *            this.stroke ();
  *        }
  */

     }
}
