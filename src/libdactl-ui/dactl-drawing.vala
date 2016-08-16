/**
 * An object that can be drawn in a Cairo context
 */
public interface Dactl.Drawable : GLib.Object {

    /**
     * A surface to draw into
     */
    public abstract Cairo.ImageSurface image_surface { get; set; }

    /**
     * Generate the pixelated data by interpolating the raw data and scaling it
     * to the chart dimensions and axis limits.
     *
     * @param w Width of the drawing area
     * @param h Height of the drawing area
     * @param x_min Minimum value of the X axis
     * @param x_max Maximum value of the X axis
     * @param y_min Minimum value of the Y axis
     * @param y_max Maximum value of the Y axis
     */
    public abstract void generate (int w, int h,
                                   double x_min, double x_max,
                                   double y_min, double y_max);

    /**
     * Update the data
     */
    public abstract void update ();

    /**
     * Draw into the given context
     *
     * @param cr The context to be altered
     */
    public abstract void draw (Cairo.Context cr);
}

/**
 * FIXME Strip chart should use a generic ChartGrid instead of StripChartGrid. This is here to allow for
 * code refactoring without breaking StripChart.
 */
[Compact]
private class Dactl.StripChartGrid : Cairo.Context {

    public StripChartGrid (Cairo.Surface target) {
        base (target);
    }

    public void draw (Dactl.Axis x_axis, Dactl.Axis y_axis, Gdk.RGBA color, int w, int h) {
        double w_major = (double)w / x_axis.div_major;
        double w_minor = w_major / x_axis.div_minor;
        double h_major = (double)h / y_axis.div_major;
        double h_minor = h_major / y_axis.div_minor;

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
                set_line_width (1.0);
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
                set_line_width (1.0);
                stroke ();
                y_major += h_major;
            }
        }
    }
}

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
                set_line_width (1.0);
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
                set_line_width (1.0);
                stroke ();
                y_major += h_major;
            }
        }
    }
}

[Compact]
public class Dactl.PolarChartGrid : Cairo.Context {

    const double PI = GLib.Math.PI;

    public PolarChartGrid (Cairo.Surface target) {
        base (target);
    }

    public void limits (Dactl.PolarAxis mag_axis,
                                     Dactl.PolarAxis angle_axis, int w, int h,
                                     out double x_max, out double x_min,
                                     out double y_max, out double y_min) {

        Gsl.Vector x = new Gsl.Vector (4);
        Gsl.Vector y = new Gsl.Vector (4);
        /* Find the graphical boundaries that will contain the axis limits */
        var t1 = Dactl.UI.degrees_to_radians (angle_axis.min);
        var t2 = Dactl.UI.degrees_to_radians (angle_axis.max);

        x.set (0, mag_axis.min * GLib.Math.cos (t1));
        x.set (1, mag_axis.min * GLib.Math.cos (t2));
        x.set (2, mag_axis.max * GLib.Math.cos (t1));
        x.set (3, mag_axis.max * GLib.Math.cos (t2));

        y.set (0, mag_axis.min * GLib.Math.sin (t1));
        y.set (1, mag_axis.min * GLib.Math.sin (t2));
        y.set (2, mag_axis.max * GLib.Math.sin (t1));
        y.set (3, mag_axis.max * GLib.Math.sin (t2));

        x_max = x.max ();
        x_min = x.min ();
        y_max = y.max ();
        y_min = y.min ();

        /* Grid spans 1st and 2nd quadrants */
        if (t1 < t2) {
            if ((t1 < PI / 2) && (t2 > PI / 2)) {
                y_max = mag_axis.max;
            }
        } else {
            if ((t1 < PI / 2) || (t2 > PI / 2)) {
                y_max = mag_axis.max;
            }
        }

        /* Grid spans 2nd and 3rd quadrants */
        if (t1 < t2) {
            if ((t1 < PI) && (t2 > PI)) {
                x_min = -1 * mag_axis.max;
            }
        } else {
            if ((t1 < PI) || (t2 > PI)) {
                x_min = -1 * mag_axis.max;
            }
        }

        /* Grid spans 3rd and 4th quadrants */
        if (t1 < t2) {
            if ((t1 < 3 * PI / 2) && (t2 > 3 * PI / 2)) {
                y_min = -1 * mag_axis.max;
            }
        } else {
            if ((t1 < 3 * PI / 2) || (t2 > 3 * PI / 2)) {
                y_min = -1 * mag_axis.max;
            }
        }

        /* Grid spans 4th and 1st quadrants */
        if (t1 < t2) {
            if ((t1 < 0) && (t2 > 0)) {
                x_max = mag_axis.max;
            }
        } else {
            x_max = mag_axis.max;
        }

        /*
         *message ("x_max, x_min, y_max, y_min %.3f %.3f %.3f %.3f",
         *                                            x_max, x_min, y_max, y_min);
         */
    }

    public void draw (Dactl.PolarAxis mag_axis, Dactl.PolarAxis angle_axis,
                                                 int w, int h, double zoom) {
        double x_max, x_min, y_max, y_min;
        double scale; // the number of pixels per unit magnitude

        limits (mag_axis, angle_axis, w, h,
                                    out x_max, out x_min, out y_max, out y_min);

        var t1 = Dactl.UI.degrees_to_radians (angle_axis.min);
        var t2 = Dactl.UI.degrees_to_radians (angle_axis.max);

        /* scale the reference plane from magnitude units to pixels */
        var scale_x = (double)w / (x_max - x_min);
        var scale_y = (double)h / (y_max - y_min);
        scale = scale_x < scale_y ? scale_x : scale_y;
        scale = scale * zoom;
        var d = w < h ? w : h;
        /* reposition it in the center of the window */
        var dx = (w - scale * (x_max - x_min)) / 2;
        var dy = (h - scale * (y_max - y_min)) / 2;

        this.translate (dx, dy);
        /*
         *message ("scaled: x_max, x_min, y_max, y_min %.3f %.3f %.3f %.3f",
         *                    x_max/scale, x_min/scale, y_max/scale, y_min/scale);
         */

        var xc = -1 * scale * x_min;
        var yc = scale * y_max;
        /*message ("w h xc yc %.3f %.3f %.3f %.3f", w, h, xc, yc);*/
        var rmin = scale * mag_axis.min;
        var rmax = scale * mag_axis.max;
        /*var rstep_major = (rmax - rmin) / (mag_axis.div_major - 1);*/
        var rstep_major = (rmax - rmin) / (mag_axis.div_major);
        var rstep_minor = rstep_major / mag_axis.div_minor;
        var t1a = 2 * PI - t1;
        var t2a = 2 * PI - t2;

        /* draw circles */
        /*for (int i = 0; i < mag_axis.div_major; i++) {*/
        for (int i = 0; i <= mag_axis.div_major; i++) {
            set_dash ({3, 5}, 0);
            set_source_rgba (
                            mag_axis.color.red,
                            mag_axis.color.green,
                            mag_axis.color.blue,
                            mag_axis.color.alpha * 0.75
                            );

            var r1 = rmin + i * rstep_major;


            for (var j = 1; j < mag_axis.div_minor; j++) {
                if (i < mag_axis.div_major) {
                    var r2 = r1 + j * rstep_minor;
                    /*message ("r2 = %.3f", r2 / scale);*/
                    arc (xc, yc, r2, t2a, t1a);
                    set_line_width (0.5);
                    stroke ();
                }
            }

            set_dash (null, 0);
            set_source_rgba (
                            mag_axis.color.red,
                            mag_axis.color.green,
                            mag_axis.color.blue,
                            mag_axis.color.alpha
                            );

            /*message ("r1 = %.3f", r1 / scale);*/
            set_line_width (1.0);
            arc (xc, yc, r1, t2a, t1a);
            stroke ();
        }

        /* draw radial lines */
        double tj, p1x, p1y, p2x, p2y;
        if (t1 > t2) {
            t1 = t1 - 2 * PI;
        }
        var tstep_major = (t2 - t1) / (angle_axis.div_major);
        var tstep_minor = tstep_major / angle_axis.div_minor;

        for (int i = 0; i < angle_axis.div_major + 1; i++) {
            /*set_dash ({3, 5}, 0);*/
            set_dash (null, 0);
            set_source_rgba (
                            angle_axis.color.red,
                            angle_axis.color.green,
                            angle_axis.color.blue,
                            angle_axis.color.alpha * 0.75
                            );
            var ti = t1 + i * tstep_major;
            for (int j = 0; j < angle_axis.div_minor; j++) {
                if (i < angle_axis.div_major) {
                    tj = ti + j * tstep_minor;
                    p1x = xc + rmin * GLib.Math.cos (tj);
                    p1y = yc - rmin * GLib.Math.sin (tj);
                    p2x = xc + rmax * GLib.Math.cos (tj);
                    p2y = yc - rmax * GLib.Math.sin (tj);
                    move_to (p1x, p1y);
                    line_to (p2x, p2y);
                    set_line_width (0.5);
                    stroke ();
                    /*message ("tj p1x p1y p2x p2y %.3f %.3f %.3f %.3f %.3f", tj * 180 / PI, p1x,p1y,p2x,p2y);*/
                }
            }
            set_dash (null, 0);
            set_source_rgba (
                            angle_axis.color.red,
                            angle_axis.color.green,
                            angle_axis.color.blue,
                            angle_axis.color.alpha
                            );

            p1x = xc + rmin * GLib.Math.cos (ti);
            p1y = yc - rmin * GLib.Math.sin (ti);
            p2x = xc + rmax * GLib.Math.cos (ti);
            p2y = yc - rmax * GLib.Math.sin (ti);
            /*message ("ti p1x p1y p2x p2y %.3f %.3f %.3f %.3f %.3f >>>", ti * 180 / PI, p1x,p1y,p2x,p2y);*/
            set_line_width (1.0);
            move_to (p1x, p1y);
            line_to (p2x, p2y);
            stroke ();
        }


        /* XXX TBD axial ticks */
        /* XXX TBD radial labels */
        for (int i = 0; i <= angle_axis.div_major; i++) {
            set_dash (null, 0);
            set_source_rgba (
                            angle_axis.color.red,
                            angle_axis.color.green,
                            angle_axis.color.blue,
                            angle_axis.color.alpha
                            );
            var ti = 2 * PI - (t1 + i * tstep_major);
            set_dash (null, 0);
            set_source_rgba (
                            angle_axis.color.red,
                            angle_axis.color.green,
                            angle_axis.color.blue,
                            angle_axis.color.alpha
                            );

            /* Labels are on an offset elipse */
            var px = xc +  1.1 * rmax * GLib.Math.cos (ti) - 15;
            var py = yc - (rmax + 10) * GLib.Math.sin (ti) + 4;

            select_font_face ("Normal 100", Cairo.FontSlant.NORMAL, Cairo.FontWeight.BOLD);
            set_font_size (8);
            save ();
            move_to (px, py);
            if (ti != 2 * PI)
                show_text ("%.1f".printf (ti * 180 / PI));
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

            if (!((p1 == null) || (p2 == null))) {
                /*stdout.printf ("%d of %d - %.3f : %.3f - %.3f : %.3f\n", i + 1, data.length, p1.x, p1.y, p2.x, p2.y);*/

                /* Draw the line segment */
                move_to (p1.x, p1.y);
                line_to (p2.x, p2.y);
            }
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
            debug ("x: %.3f y: %.3f", x, y);

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
private class Dactl.HeatMapView : Cairo.Context {

    public HeatMapView (Cairo.Surface target) {
        base (target);
    }

    public void draw (Gdk.RGBA[,] colors, Cairo.Rectangle[,] rectangles) {
        for (int i = 0; i < colors.length[0]; i++) {
            for (int j = 0; j < colors.length[1]; j++) {
                var r = colors[i,j].red;
                var g = colors[i,j].green;
                var b = colors[i,j].blue;
                var a = colors[i,j].alpha;
                var x = rectangles[i,j].x;
                var y = rectangles[i,j].y;
                var width = rectangles[i,j].width;
                var height = rectangles[i,j].height;
                /*
                 *message ("r g b a x y w h: %-8.3f %-8.3f %-8.3f %-8.3f %-8.3f %-8.3f %-8.3f %-8.3f ",
                 *                                r,g,b,a,x,y,width,height);
                 */
                set_source_rgba (r, g, b, a);
                rectangle (x, y, width, height);
                fill ();
            }
        }
    }
}

[Compact]
private class Dactl.PolarHeatMapView : Cairo.Context {

    public PolarHeatMapView (Cairo.Surface target) {
        base (target);
    }

    public void draw (Gdk.RGBA[,] colors,
                                  Dactl.PolarHeatMap.AnnulusSector[,] sectors) {
        /*set_operator (Cairo.Operator.DEST_OVER);*/
        for (int i = 0; i < colors.length[0]; i++) {
            for (int j = 0; j < colors.length[1]; j++) {
                var r = colors[i,j].red;
                var g = colors[i,j].green;
                var b = colors[i,j].blue;
                var a = colors[i,j].alpha;
                var xc = sectors[i,j].xc;
                var yc = sectors[i,j].yc;
                var x = sectors[i,j].x;
                var y = sectors[i,j].y;
                var radius = GLib.Math.sqrt (
                         GLib.Math.pow (x - xc,  2) + GLib.Math.pow (y - yc, 2));
                var theta = sectors[i,j].theta;
                var width = sectors[i,j].width;
                var sweep = sectors[i,j].sweep;
                /*message ("%d %d RGB: %.2f %.2f %.2f",i, j, r, g, b);*/
                /*message ("%d %d arc (%.3f, %.3f, %.3f, %.3f, %.3f)",i, j, xc, yc, radius, theta, theta + sweep);*/

                /* draw annulus sector */
                /*
                 *move_to (x, y);
                 *line_to (x + width * GLib.Math.cos (theta),
                 *         y + width * GLib.Math.sin (theta));
                 *arc (xc, yc, radius + width, theta, theta + sweep);
                 *line_to (xc + radius * GLib.Math.cos (theta + sweep),
                 *                yc + radius * GLib.Math.sin (theta + sweep));
                 *arc_negative (xc, yc, radius, theta + sweep, theta);
                 *close_path ();
                 *set_source_rgba (r, g, b, a);
                 *fill ();
                 */

                /* draw annulus sector */
                move_to (xc, yc);
                save ();
                translate (xc,yc);
                rotate (-1 * (theta +  sweep / 2));
                move_to (radius, 0);
                line_to (radius + width, 0);
                arc (0, 0, radius + width, 0, sweep);
                line_to (radius * GLib.Math.cos (sweep),
                                radius * GLib.Math.sin (sweep));
                arc_negative (0, 0, radius, sweep, 0);
                close_path ();
                set_source_rgba (r, g, b, a);
                fill ();
                restore ();
            }
        }
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

                if (axis.flags.is_set (Dactl.AxisFlag.DRAW_MAJOR_TICKS)) {
                    this.move_to (x, y);
                    this.line_to (x, major_tick_height);
                    this.set_line_width (1);
                    this.stroke ();
                }

                /* Draw label */
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

            /* Draw minor ticks */
            if (axis.flags.is_set (Dactl.AxisFlag.DRAW_MINOR_TICKS)) {
                for (var i = 0; i <= (div_major * div_minor); i++) {
                    x = i * w / (div_major * div_minor);
                    this.move_to (x, y);
                    this.line_to (x, minor_tick_height);
                    this.set_line_width (0.5);
                    this.stroke ();
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

                if (axis.flags.is_set (Dactl.AxisFlag.DRAW_MAJOR_TICKS)) {
                    this.move_to (x, y);
                    this.line_to (w, y);
                    this.set_line_width (1);
                    this.stroke ();
                }

                /* Draw label */
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

            /* Draw minor ticks */
            if (axis.flags.is_set (Dactl.AxisFlag.DRAW_MINOR_TICKS)) {
                x = w - minor_tick_height;
                for (var i = 0; i <= (div_major * div_minor); i++) {
                    y = i * h / (div_major * div_minor);
                    this.move_to (x, y);
                    this.line_to (w, y);
                    this.set_line_width (0.5);
                    this.stroke ();
                }
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
