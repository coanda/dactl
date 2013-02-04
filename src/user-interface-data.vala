using Cld;
using Gee;
using Gtk;
using Callbacks;

public class Utility {

    public static Gee.List<double?> hex_to_rgb (string hex) {
        Gee.ArrayList<double?> rgb = new Gee.ArrayList<double?> ();

        Gdk.Color color = Gdk.Color ();
        Gdk.Color.parse (hex, out color);
        rgb.add (color.red / 65535.0);
        rgb.add (color.green / 65535.0);
        rgb.add (color.blue / 65535.0);

        return rgb;
    }
}

/**
 * This is all very plain for now just to get things going.
 */
public class UserInterfaceData : GLib.Object {

    public Gtk.Builder builder;         /* change to private ??? */

    /* XXX really wish I could come up with a better way to deal with moving
     *     application data around. */
    private ApplicationData _cb_data;
    public ApplicationData cb_data {
        get { return _cb_data; }
        set { _cb_data = value; }
    }

    private Gtk.Widget _main_window;
    public Gtk.Widget main_window {
        get { return _main_window; }
        set { _main_window = value; }
    }

    private Gtk.Widget _about_dialog;
    public Gtk.Widget about_dialog {
        get {
            string path = GLib.Path.build_filename (Config.DATADIR,
                                                    "about_dialog.ui");
            Gtk.Builder dlg_builder = new Gtk.Builder ();
            GLib.debug ("Loaded interface file: %s", path);

            try {
                dlg_builder.add_from_file (path);
            } catch (Error e) {
                var msg = new MessageDialog (null, DialogFlags.MODAL,
                                             MessageType.ERROR,
                                             ButtonsType.CANCEL,
                                             "Failed to load UI\n%s",
                                             e.message);
                msg.run ();
            }

            _about_dialog = dlg_builder.get_object ("about_dialog") as Gtk.Widget;
            return _about_dialog;
        }
        set { _about_dialog = value; }
    }

    private Gtk.Widget frame_channels;
    private Gtk.Widget frame_charts;
    private Gtk.Widget frame_controls;
    private ChannelTreeView channel_treeview;
    private Gee.List<PIDBox> pid_box_list = new Gee.ArrayList<PIDBox> ();
    private Gee.List<ChartWidget> charts = new Gee.ArrayList<ChartWidget> ();

    /* Thread for control loop execution */
    private unowned GLib.Thread<void *> log_thread;

    construct {
        string path = GLib.Path.build_filename (Config.DATADIR, "main_window.ui");

        builder = new Gtk.Builder ();
        GLib.debug ("Loaded interface file: %s", path);

        try {
            builder.add_from_file (path);
            frame_channels = builder.get_object ("frame_channels") as Widget;
            frame_charts = builder.get_object ("frame_charts") as Widget;
            frame_controls = builder.get_object ("frame_controls") as Widget;
        } catch (Error e) {
            var msg = new MessageDialog (null, DialogFlags.MODAL,
                                         MessageType.ERROR,
                                         ButtonsType.CANCEL,
                                         "Failed to load UI\n%s",
                                         e.message);
            msg.run ();
        }
    }

    public UserInterfaceData (ApplicationData cb_data) {
        this.cb_data = cb_data;

        main_window = builder.get_object ("main_window") as Gtk.Widget;

        /* Add some window setup defaults */
        (main_window as Gtk.Window).title = "Data Acquisition and Control";
        (main_window as Gtk.Window).window_position = WindowPosition.CENTER;
        main_window.destroy.connect (Gtk.main_quit);

        /* Give toolbar nice styling using system theme */
        var toolbar = builder.get_object ("toolbar");
        var context = (toolbar as Gtk.Widget).get_style_context ();
        context.add_class ("primary-toolbar");

        /* Get content box and fill */
        add_channel_treeview_content ();
        add_chart_content ();
        add_control_content ();

        /* Setup the interface based on GSettings */
        var settings = new GLib.Settings ("org.coanda.dactl");
        frame_channels.visible = settings.get_boolean ("display-channel-frame");
        frame_charts.visible = settings.get_boolean ("display-chart-frame");
        frame_controls.visible = settings.get_boolean ("display-control-frame");

        settings.changed["display-channel-frame"].connect (() => {
            frame_channels.visible = settings.get_boolean ("display-channel-frame");
        });

        settings.changed["display-chart-frame"].connect (() => {
            frame_charts.visible = settings.get_boolean ("display-chart-frame");
        });

        settings.changed["display-control-frame"].connect (() => {
            frame_controls.visible = settings.get_boolean ("display-control-frame");
        });

        /* Connect interface callbacks */
        connect_signals ();

        main_window.show_all ();
    }

    private void connect_signals () {
        /* One-time connect for all signals defined in Glade */
        builder.connect_signals (cb_data);

        /* XXX for multiple log files to work this needs to change */
        var btn_log = builder.get_object ("btn_log");
        (btn_log as Gtk.ToggleToolButton).toggled.connect (() => {
            if ((btn_log as Gtk.ToggleToolButton).active) {
                if (!cb_data.log.active) {
                    cb_data.log_thread = new Cld.Log.Thread (cb_data.log);

                    try {
                        cb_data.log.active = true;
                        cb_data.log.file_open ();
                        cb_data.log.write_header ();
                        /* TODO create is deprecated, check compiler warnings */
                        log_thread = GLib.Thread.create<void *> (cb_data.log_thread.run, true);
                    } catch (ThreadError e) {
                        cb_data.log.active = false;
                        error ("%s\n", e.message);
                    }
                }
            } else {
                if (cb_data.log.active) {
                    cb_data.log.active = false;
                    cb_data.log.file_mv_and_date (false);
                    log_thread.join ();
                }
            }
        });

        /* Callbacks with functions */
        channel_treeview.cursor_changed.connect (channel_cursor_changed_cb);
    }

    /* XXX These would probably be just as suitable placed in objects
     *     that did the layout so the could be packed as eg.
     *     widget.pack_start (new ChannelTreeView ...) */

    private void add_channel_treeview_content () {
        var channel_scroll = builder.get_object ("scrolledwindow_channels");
        channel_treeview = new ChannelTreeView (cb_data.ai_channels);

        /* XXX row_activated/cursor_changed(?) goes here */
        (channel_scroll as Gtk.ScrolledWindow).add (channel_treeview);
    }

    private void add_chart_content () {
        var chart_scroll = builder.get_object ("scrolledwindow_charts");
        (chart_scroll as Gtk.ScrolledWindow).min_content_width = 600;
        (chart_scroll as Gtk.ScrolledWindow).min_content_height = 600;

        var alignment = new Alignment (0.50f, 0.50f, 1.0f, 1.0f);
        alignment.top_padding = 5;
        alignment.right_padding = 10;
        alignment.bottom_padding = 5;
        alignment.left_padding = 5;

        var chart_box = new Box (Orientation.VERTICAL, 0);

        /* Use GSettings schema to populate the charts */
        var schema = "org.coanda.dactl.charts";
        var settings = new GLib.Settings (schema);
        foreach (var child in settings.list_children ()) {
            debug ("Found chart schema: %s", child);
            var chart_settings = new GLib.Settings (schema + "." + child);
            var chart = new StripChartWidget ();
            chart.title = chart_settings.get_string ("title");
            chart.x_axis_label = chart_settings.get_string ("x-axis-label");
            chart.y_axis_label = chart_settings.get_string ("y-axis-label");
            chart.x_axis_min = chart_settings.get_double ("x-axis-min");
            chart.x_axis_max = chart_settings.get_double ("x-axis-max");
            chart.y_axis_min = chart_settings.get_double ("y-axis-min");
            chart.y_axis_max = chart_settings.get_double ("y-axis-max");

            /* Add data */
            Gee.List<Cld.Object> data = new Gee.ArrayList<Cld.Object> ();
            foreach (var series in chart_settings.get_strv ("series-list")) {
                Cld.Builder cld_builder = cb_data.builder;
                data.add (cld_builder.get_object (series));
                debug ("Adding data series %s to chart %s", series, child);
                chart.add_series (series);
                /* Add two points at least */
                chart.add_point_to_series (series, chart.x_axis_min, 0.0);
                chart.add_point_to_series (series, chart.x_axis_max, 0.0);
            }
            chart.series_data = data;

            /* Add colors */
            foreach (var color in chart_settings.get_strv ("series-colors")) {
                chart.add_series_color (Utility.hex_to_rgb (color));
            }

            /* meh... fix? */
            (chart_box as Box).pack_start (chart, true, true, 0);
            (chart_box as Box).pack_start (new Gtk.Separator (Orientation.HORIZONTAL), false, false, 0);

            /* just to test */
            chart_settings.changed.connect ((key) => {
                if (key == "title")
                    chart.title = chart_settings.get_string ("title");
                else if (key == "x-axis-label")
                    chart.x_axis_label = chart_settings.get_string ("x-axis-label");
                else if (key == "y-axis-label")
                    chart.y_axis_label = chart_settings.get_string ("y-axis-label");
                else if (key == "x-axis-min")
                    chart.x_axis_min = chart_settings.get_double ("x-axis-min");
                else if (key == "x-axis-max")
                    chart.x_axis_max = chart_settings.get_double ("x-axis-max");
                else if (key == "y-axis-min")
                    chart.y_axis_min = chart_settings.get_double ("y-axis-min");
                else if (key == "y-axis-max")
                    chart.y_axis_max = chart_settings.get_double ("y-axis-max");
            });

            charts.add (chart);
        }

        alignment.add (chart_box);
        (chart_scroll as Gtk.ScrolledWindow).add_with_viewport (alignment);
    }

    private void add_control_content () {
        var control_scroll = builder.get_object ("scrolledwindow_controls");

        var alignment = new Alignment (0.50f, 0.50f, 1.0f, 1.0f);
        alignment.top_padding = 5;
        alignment.right_padding = 5;
        alignment.bottom_padding = 5;
        alignment.left_padding = 5;

        var control_box = new Box (Orientation.VERTICAL, 10);
        foreach (var pid in cb_data.control_loops.values) {
            //var pid_box = new PIDBox (pid as Cld.Pid);
            var pid_box = new PIDBox (pid.id, cb_data);
            pid_box.settings_dialog = new PIDSettingsDialog (pid as Cld.Pid, cb_data.channels);
            pid_box_list.add (pid_box);
        }

        foreach (var box in pid_box_list) {
            (control_box as Box).pack_start (box, false, false, 0);
            control_box.pack_start (new Gtk.Separator (Orientation.HORIZONTAL), false, false, 0);
        }

        alignment.add (control_box);
        (control_scroll as Gtk.ScrolledWindow).add_with_viewport (alignment);
    }

    private void channel_cursor_changed_cb () {
        string id;
        TreeModel model;
        TreeIter iter;
        TreeSelection selection;
        Cld.Builder cld_builder = cb_data.builder;
        Cld.Object channel;

        selection = (channel_treeview as Gtk.TreeView).get_selection ();
        selection.get_selected (out model, out iter);
        model.get (iter, ChannelTreeView.Columns.HIDDEN_ID, out id);

        debug ("Selected: %s", id);
        channel = cld_builder.get_object (id);

        /* This is an ugly way of doing this but it shouldn't matter */
        foreach (var chart in charts) {
            chart.select_series (id);
        }
    }
}
