using Cld;
using Gee;
using Gtk;
using Callbacks;

/**
 * This is all very plain for now just to get things going.
 */
public class UserInterfaceData : GLib.Object {

    public Gtk.Builder builder;         /* change to private ??? */

    private int _chan_scroll_min_width = 800;
    public int chan_scroll_min_width {
        get { return _chan_scroll_min_width; }
        set { _chan_scroll_min_width = value; }
    }

    public bool _admin = false;
    public bool admin {
        get { return _admin; }
        set {
            _admin = value;
            btn_def.visible = value;
        }
    }

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

    private GLib.Settings settings;
    private Gtk.Widget frame_channels;
    private Gtk.Widget frame_charts;
    private Gtk.Widget frame_controls;
    private Gtk.Widget frame_modules;
    private Gtk.Widget btn_def;
    private Gtk.Widget mnu_item_edit_chan;
    private Gtk.Widget mnu_item_edit_pref;
    private Gtk.Widget mnu_item_file_quit;
    private Gtk.Widget mnu_item_view_data;
    private Gtk.Widget data_recent_chooser;
    private Gtk.RecentManager recentmanager1;
    private Gtk.Widget dlg_data_file_chooser;
    private Gtk.Widget btn_view_file;
    private Gtk.Widget mnu_item_view_config;
    private Gtk.Widget mnu_item_view_dig;
    private Gtk.Widget dlg_textview;
    private Gtk.Widget textview;
    private GLib.Object textbuffer;
    private Gtk.Widget mnu_item_help_about;
    private ChannelTreeView channel_treeview;
    private Gee.List<ChartWidget> charts = new Gee.ArrayList<ChartWidget> ();
    private Gee.List<PIDBox> pid_box_list = new Gee.ArrayList<PIDBox> ();
    //private Gee.List<ModuleBox> module_box_list = new Gee.ArrayList<ModuleBox> ();
    private Gee.List<ChartWidget> charts = new Gee.ArrayList<ChartWidget> ();
    private Gee.List<PIDBox> pid_box_list = new Gee.ArrayList<PIDBox> ();
    private Gee.List<ModuleBox> module_box_list = new Gee.ArrayList<ModuleBox> ();

    /* XXX these need to be hardcoded to speed up delivery, change later */
    //private Gtk.Widget licor_box;
    //private Gtk.Widget velmex_box;

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
            frame_modules = builder.get_object ("frame_modules") as Widget;
            btn_def = builder.get_object ("btn_def") as Widget;
            /* Edit menu ------------------------------------------------------- */
            mnu_item_edit_chan = builder.get_object ("mnu_item_edit_chan") as Widget;
            mnu_item_edit_pref = builder.get_object ("mnu_item_edit_pref") as Widget;
            /* File menu ------------------------------------------------------- */
            mnu_item_file_quit = builder.get_object ("mnu_item_file_quit") as Widget;
            /* View menu ------------------------------------------------------- */
            mnu_item_view_data = builder.get_object ("mnu_item_view_data") as Widget;

            data_recent_chooser = builder.get_object ("data_recent_chooser") as Widget;
            recentmanager1 = builder.get_object ("recentmanager1") as RecentManager;
            //(data_recent_chooser as Gtk.RecentChooser).recent_manager = recentmanager1;

            mnu_item_view_config = builder.get_object ("mnu_item_view_config") as Widget;
            dlg_data_file_chooser = builder.get_object ("dlg_data_file_chooser") as Widget;
            mnu_item_view_config = builder.get_object ("mnu_item_view_config") as Widget;
            dlg_textview = builder.get_object ("dlg_textview") as Widget;
            textview = builder.get_object ("textview") as Widget;
            textbuffer = builder.get_object ("textbuffer");
            btn_view_file = builder.get_object ("btn_view_file") as Widget;
            mnu_item_view_dig = builder.get_object ("mnu_item_view_dig") as Widget;
            /* Help menu ------------------------------------------------------- */
            mnu_item_help_about = builder.get_object ("mnu_item_help_about") as Widget;
        } catch (GLib.Error e) {
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

        main_window.show_all ();

        /* Get content box and fill */
        add_channel_treeview_content ();
        add_chart_content ();
        add_control_content ();
        add_module_content ();

        /* Setup the interface based on GSettings */
        settings = new GLib.Settings ("org.coanda.dactl");
        frame_channels.visible = settings.get_boolean ("display-channel-frame");
        frame_channels.width_request = 300;
        frame_charts.visible = settings.get_boolean ("display-chart-frame");
        frame_controls.visible = settings.get_boolean ("display-control-frame");
        frame_modules.visible = settings.get_boolean ("display-module-frame");

        if (frame_channels.visible)
            frame_channels.show_all ();

        if (frame_charts.visible)
            frame_charts.show_all ();

        if (frame_controls.visible)
            frame_controls.show_all ();

        if (frame_modules.visible)
            frame_modules.show_all ();

        settings.changed["display-module-frame"].connect (() => {
            frame_modules.visible = settings.get_boolean ("display-module-frame");
        });

        settings.changed["display-module-frame"].connect (() => {
            frame_modules.visible = settings.get_boolean ("display-module-frame");
        });

        /* Connect interface callbacks */
        connect_signals ();
    }

    private void connect_signals () {
        /* One-time connect for all signals defined in Glade */
        builder.connect_signals (cb_data);

        /* XXX for multiple log files to work this needs to change */
        var btn_log = builder.get_object ("btn_log");
        (btn_log as Gtk.ToggleToolButton).toggled.connect (() => {
            var log = cb_data.builder.get_object ("log0");
            if ((btn_log as Gtk.ToggleToolButton).active) {
                (btn_log as Gtk.ToolButton).set_icon_name ("media-playback-stop");
                (log as Cld.Log).file_open ();
                (log as Cld.Log).run ();
                if ((log as Cld.Log).active)
                    message ("Started log %s", log.id);
            } else {
                (btn_log as Gtk.ToolButton).set_icon_name ("media-record");
                if ((log as Cld.Log).active) {
                    (log as Cld.Log).stop ();
                    (log as Cld.Log).file_mv_and_date (false);
                }
            }
        });

        var btn_acq = builder.get_object ("btn_acq");
        (btn_acq as Gtk.ToggleToolButton).toggled.connect (() => {
            if ((btn_acq as Gtk.ToggleToolButton).active) {
                (btn_acq as Gtk.ToolButton).set_icon_name ("media-playback-stop");
                lock (cb_data) {
                    cb_data.run_acquisition ();
                }
            }
            else {
                (btn_acq as Gtk.ToolButton).set_icon_name ("media-playback-start");
                lock (cb_data) {
                    cb_data.stop_acquisition ();
                }
            }
        });

        settings.changed["display-channel-frame"].connect (() => {
            frame_channels.visible = settings.get_boolean ("display-channel-frame");
        });

        settings.changed["display-chart-frame"].connect (() => {
            frame_charts.visible = settings.get_boolean ("display-chart-frame");
        });

        settings.changed["display-control-frame"].connect (() => {
            frame_controls.visible = settings.get_boolean ("display-control-frame");
        });

        settings.changed["display-module-frame"].connect (() => {
            frame_modules.visible = settings.get_boolean ("display-module-frame");
        });

        /* Callbacks with functions */
        channel_treeview.cursor_changed.connect (channel_cursor_changed_cb);
        /* Edit */
        (mnu_item_edit_chan as Gtk.MenuItem).activate.connect (mnu_item_edit_chan_activate_cb);
        (mnu_item_edit_pref as Gtk.MenuItem).activate.connect (mnu_item_edit_pref_activate_cb);
        /* File */
        (mnu_item_file_quit as Gtk.MenuItem).activate.connect (mnu_item_file_quit_activate_cb);
        /* View */
        (mnu_item_view_data as Gtk.MenuItem).activate.connect (mnu_item_view_data_activate_cb);
        (dlg_data_file_chooser as Gtk.FileChooserDialog).file_activated.connect (dlg_data_file_chooser_file_activated_cb);
        (data_recent_chooser as Gtk.RecentChooser).item_activated.connect (data_recent_chooser_item_activated_cb);
        (mnu_item_view_config as Gtk.MenuItem).activate.connect (mnu_item_view_config_activate_cb);
        (mnu_item_view_dig as Gtk.MenuItem).activate.connect (mnu_item_view_dig_cb);
        /* Help */
        (mnu_item_help_about as Gtk.MenuItem).activate.connect (mnu_item_help_about_activate_cb);
    }

    /* XXX These would probably be just as suitable placed in objects
     *     that did the layout so the could be packed as eg.
     *     widget.pack_start (new ChannelTreeView ...) */

    private void add_channel_treeview_content () {
        var channel_scroll = builder.get_object ("scrolledwindow_channels");
        Gee.Map<string, Cld.Object> channels = new Gee.TreeMap<string, Cld.Object> ();
        channels.set_all (cb_data.ai_channels);
        channels.set_all (cb_data.vchannels);
        channels.set_all (cb_data.ao_channels);

        channel_treeview = new ChannelTreeView (channels);
        (channel_scroll as Gtk.ScrolledWindow).set_min_content_width (_chan_scroll_min_width);

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
           GLib.debug ("Found chart schema: %s", child);
            var chart_settings = new GLib.Settings (schema + "." + child);
            var chart = new StripChartWidget ();
            chart.schema = schema + "." + child;
            chart.title = chart_settings.get_string ("title");
            chart.x_axis_label = chart_settings.get_string ("x-axis-label");
            chart.y_axis_label = chart_settings.get_string ("y-axis-label");
            chart.x_axis_min = chart_settings.get_double ("x-axis-min");
            chart.x_axis_max = chart_settings.get_double ("x-axis-max");
            chart.y_axis_min = chart_settings.get_double ("y-axis-min");
            chart.y_axis_max = chart_settings.get_double ("y-axis-max");
            chart.height_min = chart_settings.get_int ("height-min");
            /* Attach the setting dialog */
            chart.settings_dialog  = new ChartSettingsDialog (chart as ChartWidget);
            /* Set the height and width */
            (chart as Widget).height_request = chart.height_min;
            (chart as Widget).width_request = chart.width_min;
            /* Add data */
            Gee.List<Cld.Object> data = new Gee.ArrayList<Cld.Object> ();
            foreach (var series in chart_settings.get_strv ("series-list")) {
                Cld.Builder cld_builder = cb_data.builder;
                data.add (cld_builder.get_object (series));
               GLib.debug ("Adding data series %s to chart %s", series, child);
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
                else if (key == "height-min")
                    chart.height_min = chart_settings.get_int ("height-min");
            });

            (chart as Widget).height_request = chart.height_min;
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

    private void add_module_content () {
        var module_scroll = builder.get_object ("scrolledwindow_modules");

        var alignment = new Alignment (0.50f, 0.50f, 1.0f, 1.0f);
        alignment.top_padding = 5;
        alignment.right_padding = 5;
        alignment.bottom_padding = 5;
        alignment.left_padding = 5;

        var module_box = new Box (Orientation.VERTICAL, 10);
        foreach (var module in cb_data.modules.values) {
            if (module is LicorModule) {
                var licor_box = new LicorModuleBox ((module as Module), cb_data.vchannels);
                module_box.pack_start (licor_box, false, false, 0);
                module_box.pack_start (new Gtk.Separator (Orientation.HORIZONTAL), false, false, 0);
            } else if (module is VelmexModule) {
                var velmex_box = new VelmexModuleBox ((module as Module));
                module_box.pack_start (velmex_box, false, false, 0);
            } else if (module is BrabenderModule) {
                var brabender_box = new BrabenderModuleBox ((module as Module));
                module_box.pack_start (brabender_box, false, false, 0);
            }
        }

        /* pack module content */
        //licor_box = new LicorModuleBox (cb_data.licor, cb_data.vchannels);
        //module_box.pack_start (licor_box, false, false, 0);
        //module_box.pack_start (new Gtk.Separator (Orientation.HORIZONTAL), false, false, 0);

        //velmex_box = new VelmexModuleBox (cb_data.velmex);
        //module_box.pack_start (velmex_box, false, false, 0);

        alignment.add (module_box);
        (module_scroll as Gtk.ScrolledWindow).add_with_viewport (alignment);
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

       GLib.debug ("Selected: %s", id);
        channel = cld_builder.get_object (id);

        /* This is an ugly way of doing this but it shouldn't matter */
        foreach (var chart in charts) {
            chart.select_series (id);
        }
    }

    private void mnu_item_edit_chan_activate_cb () {
        var dialog = new ApplicationSettingsDialog.with_startup_tab_id (cb_data, 2);

        (dialog as Gtk.Dialog).run ();
        (dialog as Gtk.Dialog).destroy ();
    }

    private void mnu_item_edit_pref_activate_cb () {
        var dialog = new ApplicationSettingsDialog.with_startup_tab_id (cb_data, 0);

        (dialog as Gtk.Dialog).run ();
        (dialog as Gtk.Dialog).destroy ();
    }

    private void mnu_item_file_quit_activate_cb () {
        var dialog = new Gtk.MessageDialog ((main_window as Gtk.Window),
                                            Gtk.DialogFlags.MODAL,
                                            Gtk.MessageType.QUESTION,
                                            Gtk.ButtonsType.YES_NO,
                                            "Are you sure you want to quit?");

        (dialog as Gtk.Dialog).response.connect ((response_id) => {
            switch (response_id) {
                case ResponseType.NO:
                    (dialog as Gtk.Dialog).destroy ();
                    break;
                case ResponseType.YES:
                    (dialog as Gtk.Dialog).destroy ();
                    Gtk.main_quit ();
                    break;
            }
        });

        (dialog as Gtk.Dialog).run ();
    }

    /**
     * RUn the data file chooser dialog.
     **/
    private void mnu_item_view_data_activate_cb () {
        Cld.debug ("Menu item view data activate callback.\n");
        (dlg_data_file_chooser as Gtk.Dialog).response.connect ((response_id) => {
            switch (response_id) {
                case ResponseType.CANCEL:
                    break;
                case ResponseType.ACCEPT:
                    string filename = (dlg_data_file_chooser as Gtk.FileChooserDialog).get_filename ();
                    Cld.debug ("FileChooser :: filename is: %s\n", filename);
                    show_file (filename);
                    break;
            }
        });

        int result = (dlg_data_file_chooser as Gtk.Dialog).run ();
        (dlg_data_file_chooser as Gtk.Dialog).hide ();
    }
    /**
     * Get the filename string of the xml configuration file.
     **/
    private void mnu_item_view_config_activate_cb () {
        Cld.debug ("Configuration file is: %s.\n", cb_data.xml_file);
        show_file (cb_data.xml_file);

    }

    /**
     * Launch the digital I/O viewer.
     **/
    private void mnu_item_view_dig_cb () {
        Cld.debug ("Starting digital I/O viewer.\n");
        var viewer = new DIOViewer (cb_data);
    }


    /**
     * Get the filename of the double clicked selection in the file chooser.
     **/
    private void  dlg_data_file_chooser_file_activated_cb () {
        string  filename = (dlg_data_file_chooser as Gtk.FileChooserDialog).get_filename ();
        Cld.debug ("FileChooser :: filename is: %s\n", filename);
        recentmanager1.add_item ("file://" + filename);
        show_file (filename);
    }

    /**
     * Get the filename of the selection from the recent file chooser.
     **/
    private void data_recent_chooser_item_activated_cb () {
        string uri = (data_recent_chooser as Gtk.RecentChooser).get_current_uri ();
        string filename = uri.substring (7, -1);
        //Cld.debug ("RecentChooser :: uri is: %s\n\tfilename is: %s\n", uri, filename);

        show_file (filename);
    }

    /**
     * Display the contents of the selected text file.
     **/
    private void show_file (string filename) {

        try {
            string text;
            FileUtils.get_contents (filename, out text);
            ((this.textbuffer) as TextBuffer).text = text;
        } catch (Error e) {
            stderr.printf ("Error: %s\n", e.message);
        }

        (dlg_textview as Gtk.Dialog).response.connect ((response_id) => {
            switch (response_id) {
                case ResponseType.ACCEPT:
                break;
            }
        });
        (dlg_textview as Gtk.Window).set_decorated (true);
        (dlg_textview as Gtk.Dialog).run ();
        (dlg_textview as Gtk.Dialog).hide ();
    }

    private void mnu_item_help_about_activate_cb () {
        string path = GLib.Path.build_filename (Config.DATADIR,
                                                "about_dialog.ui");
        Gtk.Builder dlg_builder = new Gtk.Builder ();

        try {
            dlg_builder.add_from_file (path);
        } catch (GLib.Error e) {
            var msg = new MessageDialog (null, DialogFlags.MODAL,
                                            MessageType.ERROR,
                                            ButtonsType.CANCEL,
                                            "Failed to load UI\n%s",
                                            e.message);
            msg.run ();
        }

        var about_dialog = dlg_builder.get_object ("about_dialog");
        (about_dialog as Gtk.Dialog).response.connect ((response_id) => {
            switch (response_id) {
                case ResponseType.CANCEL:
                case ResponseType.DELETE_EVENT:
                    (about_dialog as Gtk.Dialog).destroy ();
                    break;
            }
        });

        (about_dialog as Gtk.Dialog).run ();
    }
}
