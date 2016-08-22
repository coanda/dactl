[GtkTemplate (ui = "/org/coanda/libdactl/ui/chart-widget.ui")]
public class Dactl.ChartWidget : Gtk.Box {

    [GtkChild]
    private Gtk.Label lbl_title;

    [GtkChild]
    private Gtk.Label lbl_x_axis;

    [GtkChild]
    private Gtk.Label lbl_y_axis;

    [GtkChild]
    private Gtk.Button btn_settings;

    [GtkChild]
    private Gtk.Alignment alignment_x_axis;

    [GtkChild]
    private Gtk.Alignment alignment_y_axis;

    [GtkChild]
    private Gtk.Alignment alignment_chart;

    private Gtk.Dialog _settings_dialog;
    public Gtk.Dialog settings_dialog {
        get { return _settings_dialog; }
        set { _settings_dialog = value; }
    }

    public string schema;

    /* XXX could consider using an adjustment in each to sync */
    protected Gtk.Widget chart_area;
    protected Gtk.Widget x_axis_area;
    protected Gtk.Widget y_axis_area;

    public string title {
        get { return (lbl_title as Gtk.Label).label; }
        set { (lbl_title as Gtk.Label).label = value; }
    }

    public string x_axis_label {
        get { return (lbl_x_axis as Gtk.Label).label; }
        set { (lbl_x_axis as Gtk.Label).label = value; }
    }

    public string y_axis_label {
        get { return (lbl_y_axis as Gtk.Label).label; }
        set { (lbl_y_axis as Gtk.Label).label = value; }
    }

    public int n_x_divisions_major {
        get { return (x_axis_area as XAxisArea).n_divisions_major; }
        set {
            (x_axis_area as XAxisArea).n_divisions_major = value;
            x_axis_area.queue_draw ();
            (chart_area as ChartArea).n_x_divisions_major = value;
            chart_area.queue_draw ();
        }
    }

    public int n_x_divisions_minor {
        get { return (x_axis_area as XAxisArea).n_divisions_minor; }
        set {
            (x_axis_area as XAxisArea).n_divisions_minor = value;
            x_axis_area.queue_draw ();
            (chart_area as ChartArea).n_x_divisions_minor = value;
            chart_area.queue_draw ();
        }
    }

    public int n_y_divisions_major {
        get { return (y_axis_area as YAxisArea).n_divisions_major; }
        set {
            (y_axis_area as YAxisArea).n_divisions_major = value;
            y_axis_area.queue_draw ();
            (chart_area as ChartArea).n_y_divisions_major = value;
            chart_area.queue_draw ();
        }
    }

    public int n_y_divisions_minor {
        get { return (y_axis_area as YAxisArea).n_divisions_minor; }
        set {
            (y_axis_area as YAxisArea).n_divisions_minor = value;
            y_axis_area.queue_draw ();
            (chart_area as ChartArea).n_y_divisions_minor = value;
            chart_area.queue_draw ();
        }
    }

    public int height_min {get; set; default = 100;}

    public int width_min {get; set; default = 100;}

    public double x_axis_max {
        get { return (x_axis_area as XAxisArea).axis_max; }
        set {
            (x_axis_area as XAxisArea).axis_max = value;
            x_axis_area.queue_draw ();
            (chart_area as ChartArea).x_axis_max = value;
            chart_area.queue_draw ();
        }
    }

    public double x_axis_min {
        get { return (x_axis_area as XAxisArea).axis_min; }
        set {
            (x_axis_area as XAxisArea).axis_min = value;
            x_axis_area.queue_draw ();
            (chart_area as ChartArea).x_axis_min = value;
            chart_area.queue_draw ();
        }
    }

    public double y_axis_max {
        get { return (y_axis_area as YAxisArea).axis_max; }
        set {
            (y_axis_area as YAxisArea).axis_max = value;
            y_axis_area.queue_draw ();
            (chart_area as ChartArea).y_axis_max = value;
            chart_area.queue_draw ();
        }
    }

    public double y_axis_min {
        get { return (y_axis_area as YAxisArea).axis_min; }
        set {
            (y_axis_area as YAxisArea).axis_min = value;
            y_axis_area.queue_draw ();
            (chart_area as ChartArea).y_axis_min = value;
            chart_area.queue_draw ();
        }
    }

    public ChartWidget () {

        chart_area = new Dactl.ChartArea ();
        x_axis_area = new Dactl.XAxisArea ();
        y_axis_area = new Dactl.YAxisArea ();

        /* Set names for styling */
        chart_area.set_name ("chart-area");
        x_axis_area.set_name ("x-axis-area");
        y_axis_area.set_name ("y-axis-area");

        alignment_chart.add (chart_area);
        alignment_x_axis.add (x_axis_area);
        alignment_y_axis.add (y_axis_area);

        connect_signals ();
    }

    private void connect_signals () {
        (btn_settings as Gtk.Button).clicked.connect (() => {
            settings_dialog.run ();
        });
    }

    public void update_settings () {
        var settings = new GLib.Settings (schema);
        settings.set_string ("title", title);
        settings.set_string ("x-axis-label", x_axis_label);
        settings.set_string ("y-axis-label", y_axis_label);
        settings.set_int ("height-min", height_min);
        settings.set_double ("x-axis-min", x_axis_min);
        settings.set_double ("x-axis-max", x_axis_max);
        settings.set_double ("y-axis-min", y_axis_min);
        settings.set_double ("y-axis-max", y_axis_max);
    }

    public virtual void add_series (string id) {
        (chart_area as Dactl.ChartArea).data_series.set (id, new Gee.ArrayList<Dactl.Point> ());
    }

    public virtual void add_series_with_data (string id, Gee.List<Dactl.Point> data) {
        (chart_area as Dactl.ChartArea).data_series.set (id, data);
    }

    public virtual void add_point_to_series (string id, double x, double y) {
        var list = (chart_area as Dactl.ChartArea).data_series.get (id);
        list.add (new Dactl.Point (x, y));
    }

    public virtual void add_series_color (Gee.List<double?> color) {
        (chart_area as Dactl.ChartArea).series_colors.add (color);
    }

    public virtual void select_series (string series_id) {
        (chart_area as Dactl.ChartArea).selected_series = series_id;
    }
}

public class Dactl.StripChartWidget : Dactl.ChartWidget {

    public double time_step { get; set; default = 0.1; }
    public Gee.List<Cld.Object> series_data { private get; set; }

    public StripChartWidget () {
        base ();
        series_data = new Gee.ArrayList<Cld.Object> ();
        update ();
        Timeout.add ((uint)(1000 * time_step), update);
    }

    private bool update () {
        foreach (var data in series_data) {
            if (data is Cld.ScalableChannel)
                add_point_to_series (data.id, x_axis_max, (data as Cld.ScalableChannel).scaled_value);
        }
        //redraw_canvas ();
        chart_area.queue_draw ();
        return true;
    }

    private void redraw_canvas () {
        var window = chart_area.get_window ();
        if (null == window) {
            return;
        }

        var region = window.get_clip_region ();
        /* redraw the cairo canvas completely by exposing it */
        window.invalidate_region (region, true);
        window.process_updates (true);
    }

    public override void add_point_to_series (string id, double x, double y) {
        bool has_next;

        if (!(chart_area as Dactl.ChartArea).data_series.has_key (id))
            return;

        var list = (chart_area as Dactl.ChartArea).data_series.get (id);

        //string r = "Size: %d -> ".printf (list.size);

        if (list.size >= (x_axis_max / time_step) + 1) {
            for (var iter = list.iterator (); iter.has_next (); iter.next ()) {
                var point = iter.get ();
                point.x -= time_step;
            }
        } else {
            for (var iter = list.iterator (); iter.has_next (); iter.next ()) {
                var point = iter.get ();
                if ((point.x - time_step) >= 0.0)
                    point.x -= time_step;
                else
                    point.x = 0.0;
            }
        }

        list.add (new Dactl.Point (x, y));

        //r += "%d -> ".printf (list.size);

        if (list.size > (x_axis_max / time_step) + 1)
            list.remove_at (0);

        //r += "%d".printf (list.size);
        //message (r);
    }
}

/* X Axis drawing area class */
public class Dactl.XAxisArea : Gtk.DrawingArea {

    public int n_divisions_major { get; set; default = 10; }
    public int n_divisions_minor { get; set; default = 5; }
    public double axis_max { get; set; default = 100.0; }
    public double axis_min { get; set; default = 0.0; }

    private int major_tick_height = 8;
    private int minor_tick_height = 5;

    public override bool draw (Cairo.Context cr) {
        var w = get_allocated_width ();
        var h = get_allocated_height ();

        /* ticks */
        var x = 0;
        var y = 0;

        GLib.List<Pango.Layout> tick_layout_list = new GLib.List<Pango.Layout> ();
        for (var i = 0; i <= n_divisions_major; i++) {
            string tick_label = "%.1f".printf (axis_min);
            if (i > 0)
                tick_label = "%.1f".printf (axis_min + (((axis_max - axis_min) / n_divisions_major) * i));
            var layout = create_pango_layout (tick_label);
            var desc = Pango.FontDescription.from_string ("Normal 100");
            layout.set_font_description (desc);
            string markup = "<span font='8'>%s</span>".printf (tick_label);
            layout.set_markup (markup, -1);
            tick_layout_list.append (layout);
        }

        for (var i = 0; i <= n_divisions_major; i++) {
            x = (w / n_divisions_major) * i + (1 * i);
            if (i == 0)
                x += 1;
            else {
                x -= (int)(i * 0.5);
                x += 1;
            }
            cr.move_to (x, y);
            cr.line_to (x, major_tick_height);
            cr.set_line_width (1);
            cr.stroke ();

            /* draw label */
            int fontw, fonth;
            var layout = tick_layout_list.nth_data (i);
            layout.get_pixel_size (out fontw, out fonth);
            if (i == n_divisions_major)
                cr.move_to (x - fontw, y + major_tick_height + 2);
            else
                cr.move_to (x, y + major_tick_height + 2);
            Pango.cairo_update_layout (cr, layout);
            Pango.cairo_show_layout (cr, layout);

            /* draw minor ticks */
            for (var j = 1; j < n_divisions_minor; j++) {
                x += (w / n_divisions_major) / n_divisions_minor;
                cr.move_to (x, y);
                cr.line_to (x, minor_tick_height);
                cr.set_line_width (0.5);
                cr.stroke ();
            }
        }

        return false;
    }
}

/* Y Axis drawing area class */
public class Dactl.YAxisArea : Gtk.DrawingArea {

    public int n_divisions_major { get; set; default = 8; }
    public int n_divisions_minor { get; set; default = 1; }
    public double axis_max { get; set; default = 100.0; }
    public double axis_min { get; set; default = -100.0; }

    private int major_tick_height = 8;
    private int minor_tick_height = 5;

    public override bool draw (Cairo.Context cr) {
        var w = get_allocated_width ();
        var h = get_allocated_height ();

        /* ticks */
        var x = 0;
        var y = 0;

        GLib.List<Pango.Layout> tick_layout_list = new GLib.List<Pango.Layout> ();

        for (var i = 0; i <= n_divisions_major; i++) {
            string tick_label = "%.1f".printf (axis_max);
            if (i > 0)
                tick_label = "%.1f".printf (axis_max - (((axis_max - axis_min) / n_divisions_major) * i));
            var layout = create_pango_layout (tick_label);
            var desc = Pango.FontDescription.from_string ("Normal 100");
            layout.set_font_description (desc);
            string markup = "<span font='8'>%s</span>".printf (tick_label);
            layout.set_markup (markup, -1);
            tick_layout_list.append (layout);
        }

        for (var i = 0; i <= n_divisions_major; i++) {
            x = w - major_tick_height;
            if (i == 0)
                y += 1;
            else
                y += (h / n_divisions_major);
            cr.move_to (x, y);
            cr.line_to (w, y);
            cr.set_line_width (1);
            cr.stroke ();

            /* draw label */
            int fontw, fonth;
            var layout = tick_layout_list.nth_data (i);
            layout.get_pixel_size (out fontw, out fonth);
            if (i == n_divisions_major)
                cr.move_to (0, y - fonth);
            else if (i == 0)
                cr.move_to (0, y);
            else
                cr.move_to (0, y - (fonth / 2));
            Pango.cairo_update_layout (cr, layout);
            Pango.cairo_show_layout (cr, layout);

            /* draw minor ticks */
            x = w - minor_tick_height;
            for (var j = 1; j < n_divisions_minor; j++) {
                y += (h / n_divisions_major) / n_divisions_minor;
                cr.move_to (x, y);
                cr.line_to (w, y);
                cr.set_line_width (0.5);
                cr.stroke ();
            }
        }

        return false;
    }
}

/* Chart drawing area class */
public class Dactl.ChartArea : Gtk.DrawingArea {

    public int n_x_divisions_major { private get; set; default = 10; }
    public int n_x_divisions_minor { private get; set; default = 5; }
    public int n_y_divisions_major { private get; set; default = 8; }
    public int n_y_divisions_minor { private get; set; default = 1; }
    public double x_axis_min { private get; set; default = 0.0; }
    public double x_axis_max { private get; set; default = 100.0; }
    public double y_axis_min { private get; set; default = -100.0; }
    public double y_axis_max { private get; set; default = 100.0; }

    public Gee.Map<string, Gee.List<Dactl.Point>> data_series;
    public Gee.List<Gee.List<double?>> series_colors;
    public string selected_series;

    private int pps = 10;
    private Gee.List<double?> default_color = new Gee.ArrayList<double?> ();

    construct {
        data_series = new Gee.TreeMap<string, Gee.List<Dactl.Point>> ();
        series_colors = new Gee.ArrayList<Gee.List<double?>> ();

        default_color.add (0);
        default_color.add (0);
        default_color.add (0);
    }

    public override bool draw (Cairo.Context cr) {
        var w = get_allocated_width ();
        var h = get_allocated_height ();
        Gee.List<double?> color = new Gee.ArrayList<double?> ();

        /* Chart back */
        //cr.rectangle (0, 0, w, h);
        //cr.set_source_rgb (1, 1, 1);
        //cr.fill_preserve ();

        cr.set_antialias (Cairo.Antialias.SUBPIXEL);
        draw_grid (cr);

        var i = 0;
        foreach (var key in data_series.keys) {
            var data = data_series.get (key);

            if (key == selected_series)
                cr.set_line_width (2.0);
            else
                cr.set_line_width (1.0);

            if (series_colors.size > 0)
                color = series_colors.get (i++);
            else
                color = default_color;

            Gee.List<Point> subset = new Gee.ArrayList<Dactl.Point> ();

            /* XXX !!! fix this !!! */
            if (data.size > (x_axis_max * pps + 1))
                subset = data.slice (data.size - (int)(x_axis_max * pps) - 1,
                                     data.size - 1);
            else
                subset = data;

            //debug ("Plot series %s, %d points", key, subset.size);

            cr.set_source_rgb (color.get (0), color.get (1), color.get (2));
            draw_line (cr, subset);
        }

        return false;
    }

    private void draw_grid (Cairo.Context cr) {
        var x = 0;
        var y = 0;
        var w = get_allocated_width ();
        var h = get_allocated_height ();

        /* X axis */
        for (var i = 0; i <= n_x_divisions_major; i++) {
            cr.set_source_rgb (0.5, 0.5, 0.5);
            x = ((int)w / n_x_divisions_major) * i + (1 * i);
            y = 0;
            if (i == 0)
                x += 1;
            else {
                x -= (int)(i * 0.5);
                x += 1;
            }
            cr.move_to (x, y);
            cr.line_to (x, h);
            cr.set_line_width (1);
            cr.stroke ();

            /* draw minor ticks */
            cr.set_source_rgb (0.75, 0.75, 0.75);
            for (var j = 1; j < n_x_divisions_minor; j++) {
                x += ((int)w / n_x_divisions_major) / n_x_divisions_minor;
                cr.move_to (x, y);
                cr.line_to (x, h);
                cr.set_line_width (0.5);
                cr.stroke ();
            }
        }

        /* Y axis */
        y = 0;
        for (var i = 0; i <= n_y_divisions_major; i++) {
            cr.set_source_rgb (0.5, 0.5, 0.5);
            x = 0;
            if (i == 0)
                y += 1;
            else
                y += ((int)h / n_y_divisions_major);
            cr.move_to (x, y);
            cr.line_to (w, y);
            cr.set_line_width (1);
            cr.stroke ();

            /* draw minor ticks */
            cr.set_source_rgb (0.75, 0.75, 0.75);
            for (var j = 1; j < n_y_divisions_minor; j++) {
                y += ((int)h / n_y_divisions_major) / n_y_divisions_minor;
                cr.move_to (x, y);
                cr.line_to (w, y);
                cr.set_line_width (0.5);
                cr.stroke ();
            }
        }

        /* Border */
        cr.set_source_rgb (0, 0, 0);
        cr.stroke ();
    }

    private void draw_line (Cairo.Context cr, Gee.List<Dactl.Point> data) {
        var w = get_allocated_width ();
        var h = get_allocated_height ();
        var x_min = x_axis_min;
        var x_max = x_axis_max;
        var y_min = y_axis_min;
        var y_max = y_axis_max;
        var x_offset = x_min * -1.0;
        var y_offset = y_min * -1.0;

        /* Normalize */
        if (x_min < 0) {
            x_max = Math.fabs (x_max + Math.fabs (x_min));
            x_min = x_min + Math.fabs (x_min);
        } else {
            x_max = x_max - x_min;
            x_min = x_min - x_min;
        }

        if (y_min < 0) {
            y_max = Math.fabs (y_max + Math.fabs (y_min));
            y_min = y_min + Math.fabs (y_min);
        } else {
            y_max = y_max - y_min;
            y_min = y_min - y_min;
        }

        var x_range = x_max - x_min;
        var y_range = y_max - y_min;

        for (var i = 0; i < data.size - 1; i++) {
            var p1 = data.get (i);
            var p2 = data.get (i + 1);
            var x1 = p1.x + x_offset;
            var y1 = p1.y + y_offset;
            var x2 = p2.x + x_offset;
            var y2 = p2.y + y_offset;

            /* Convert x values to plotting range */
            x1 = (x1 > x_max) ? x_max : x1;
            x1 = (x1 < x_min) ? x_min : x1;
            x2 = (x2 > x_max) ? x_max : x2;
            x2 = (x2 < x_min) ? x_min : x2;

            x1 = (x1 / x_range) * w;
            x2 = (x2 / x_range) * w;

            /* Convert y values to plotting range */
            y1 = (y1 > y_max) ? y_max : y1;
            y1 = (y1 < y_min) ? y_min : y1;
            y2 = (y2 > y_max) ? y_max : y2;
            y2 = (y2 < y_min) ? y_min : y2;

            y1 = h - ((y1 / y_range) * h);
            y2 = h - ((y2 / y_range) * h);

            /* Draw the line segment */
            cr.move_to (x1, y1);
            cr.line_to (x2, y2);
        }

        cr.stroke ();
    }

    private void draw_polyline (Cairo.Context cr, Gee.List<Dactl.Point> data) {
        var w = get_allocated_width ();
        var h = get_allocated_height ();
        int i;
        double x, y, x2, y2, xl, yl, xr, yr, xls, xrs, pdx, pdy, cx1, cy1, cx2, cy2, pdx1, pdy1, pdx2, pdy2, ph;
        double[,] poly_data = new double[data.size, 6];

        for (i = 0; i < data.size; i++) {
            var point = data.get (i);
            x = ((Math.fabs (point.x) - Math.fabs (x_axis_min)) /
                    Math.fabs (Math.fabs (x_axis_max) -
                                Math.fabs (x_axis_min))) * w;
            y = ((Math.fabs (y_axis_max) - Math.fabs (point.y)) /
                    (y_axis_max - y_axis_min)) * h;

            if ((i != 0) && (i != data.size - 1)) {
                // calculate left hand point data
                var prev_point = data.get (i - 1);
                xl = ((Math.fabs (prev_point.x) - Math.fabs (x_axis_min)) /
                        Math.fabs (Math.fabs (x_axis_max) -
                                    Math.fabs (x_axis_min))) * w;
                yl = ((Math.fabs (y_axis_max) - Math.fabs (prev_point.y)) /
                        (y_axis_max - y_axis_min)) * h;

                // calculate right hand point data
                var next_point = data.get (i + 1);
                xr = ((Math.fabs (next_point.x) - Math.fabs (x_axis_min)) /
                        Math.fabs (Math.fabs (x_axis_max) -
                                    Math.fabs (x_axis_min))) * w;
                yr = ((Math.fabs (y_axis_max) - Math.fabs (next_point.y)) /
                        (y_axis_max - y_axis_min)) * h;

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
            cr.move_to (x, y);
            cr.curve_to (cx1, cy1, cx2, cy2, x2, y2);
        }

        cr.stroke ();
    }
}
