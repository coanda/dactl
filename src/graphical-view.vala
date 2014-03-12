using Cld;
using Gee;
using Gtk;
using Callbacks;

/**
 * The Gtk.Application class expects an ApplicationWindow so a lot is being
 * moved here from outside of the actual view class.
 *
 * XXX the name GraphicalWindow is stupid, change it
 */
public class GraphicalWindow : Gtk.ApplicationWindow {

    private int _chan_scroll_min_width = 50;
    public int chan_scroll_min_width {
        get { return _chan_scroll_min_width; }
        set { _chan_scroll_min_width = value; }
    }

    /* Model used to update the view */
    private ApplicationModel model;

    /* Widgets and data needed for interface */
    private GLib.Settings settings;
    private Gtk.Builder builder;
    private Gtk.Widget frame_channels;
    private Gtk.Widget frame_charts;
    private Gtk.Widget frame_controls;
    private Gtk.Widget frame_modules;
    private Gtk.Widget btn_view_file;
    private Gtk.Widget mnu_item_view_dig;
    private Gtk.Widget mnu_item_view_data;
    private Gtk.Widget mnu_item_view_data_recent;
    private Gtk.Widget mnu_item_view_config;
    private Gtk.Widget data_recent_chooser;
    private Gtk.RecentManager recentmanager1;
    private Gtk.Widget dlg_data_file_chooser;
    private Gtk.Widget dlg_textview;
    private Gtk.Widget textview;
    private GLib.Object textbuffer;
    private ChannelTreeView channel_treeview;
    private Gee.List<ChartWidget> charts = new Gee.ArrayList<ChartWidget> ();
    private Gee.List<PIDBox> pid_box_list = new Gee.ArrayList<PIDBox> ();
    private Gee.List<PID2Box> pid2_box_list = new Gee.ArrayList<PID2Box> ();
    private Gee.List<AOBox> ao_box_list = new Gee.ArrayList<AOBox> ();
    private Gee.List<DOBox> do_box_list = new Gee.ArrayList<DOBox> ();
    //private Gee.List<ModuleBox> module_box_list = new Gee.ArrayList<ModuleBox> ();

    /**
     * Default construction.
     */
    internal GraphicalWindow (GraphicalView app, ApplicationModel model) {
        GLib.Object (application: app,
                     title: "Data Acquisition and Control",
                     window_position: WindowPosition.CENTER);

        /* XXX would be nice to leave this in the view, later... */
        this.model = model;

        string path = GLib.Path.build_filename (Config.UI_DIR,
                                                "main_window.ui");
        GLib.message ("Loading interface file: %s", path);

        var grid = new Gtk.Grid ();
        this.add (grid);
        grid.show ();

        /* Add the main content from a Glade interface file */
        builder = new Gtk.Builder ();
        try {
            builder.add_from_file (path);
        } catch (GLib.Error e) {
            GLib.error ("Unable to load file: %s", e.message);
        }

        load_widgets ();

        /* Using grid to make more complicated UI construction possible later */
        grid.attach (builder.get_object ("main_box") as Gtk.Box, 0, 0, 1, 1);

        /* Apply stylings from CSS */
        string css_path = GLib.Path.build_filename (Config.UI_DIR,
                                                    "style.css");

        GLib.message ("Loading style from file: %s", css_path);
        var provider = new CssProvider ();
        try {
            provider.load_from_path (css_path);
        } catch (GLib.Error e) {
            GLib.message ("Error: %s", e.message);
        }

        var display = Gdk.Display.get_default ();
        var screen = display.get_default_screen ();
        Gtk.StyleContext.add_provider_for_screen (screen,
            provider as Gtk.StyleProvider,
            Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);

        /* Get content box and fill */
        add_channel_treeview_content ();
        add_chart_content ();
        add_control_content ();
        add_module_content ();

        /* Initialize the display from settings */
        initialize_display ();

        /* Connect interface callbacks */
        connect_signals ();
    }

    private void load_widgets () {
        frame_channels = builder.get_object ("frame_channels") as Widget;
        frame_charts = builder.get_object ("frame_charts") as Widget;
        frame_controls = builder.get_object ("frame_controls") as Widget;
        frame_modules = builder.get_object ("frame_modules") as Widget;

        /* View menu */
        data_recent_chooser = builder.get_object ("data_recent_chooser") as Widget;
        recentmanager1 = builder.get_object ("recentmanager1") as RecentManager;
        //(data_recent_chooser as Gtk.RecentChooser).recent_manager = recentmanager1;
        mnu_item_view_data = builder.get_object ("mnu_item_view_data") as Widget;
        mnu_item_view_data_recent = builder.get_object ("mnu_item_view_data_recent") as Widget;
        mnu_item_view_config = builder.get_object ("mnu_item_view_config") as Widget;
        mnu_item_view_dig = builder.get_object ("mnu_item_view_dig") as Widget;
        dlg_data_file_chooser = builder.get_object ("dlg_data_file_chooser") as Widget;
        dlg_textview = builder.get_object ("dlg_textview") as Widget;
        textview = builder.get_object ("textview") as Widget;
        textbuffer = builder.get_object ("textbuffer");
        btn_view_file = builder.get_object ("btn_view_file") as Widget;
    }

    private void initialize_display () {
        /* Setup the interface based on GSettings */
        settings = new GLib.Settings ("org.coanda.dactl");
        frame_channels.visible = settings.get_boolean ("display-channel-frame");
        frame_channels.width_request = 50;
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
    }

    private void connect_signals () {
        /* One-time connect for all signals defined in Glade */
        builder.connect_signals (model);

        /* Signals from the application data model */
        model.acquisition_state_changed.connect ((state) => {
            var btn_acq = builder.get_object ("btn_acq");
            if (state)
                (btn_acq as Gtk.ToolButton).set_icon_name ("media-playback-stop");
            else
                (btn_acq as Gtk.ToolButton).set_icon_name ("media-playback-start");
        });

        model.log_state_changed.connect ((id, state) => {
            var btn_log = builder.get_object ("btn_log");
            if (state) {
                (btn_log as Gtk.ToolButton).set_icon_name ("media-playback-stop");
            } else {
                (btn_log as Gtk.ToolButton).set_icon_name ("media-record");
            }
        });

        /* Signals from changes made to settings in dconf */
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

        /* View */
        (mnu_item_view_data as Gtk.MenuItem).activate.connect (mnu_item_view_data_activate_cb);
        (dlg_data_file_chooser as Gtk.FileChooserDialog).file_activated.connect (dlg_data_file_chooser_file_activated_cb);
        (data_recent_chooser as Gtk.RecentChooser).item_activated.connect (data_recent_chooser_item_activated_cb);
        (mnu_item_view_config as Gtk.MenuItem).activate.connect (mnu_item_view_config_activate_cb);
        (mnu_item_view_dig as Gtk.MenuItem).activate.connect (mnu_item_view_dig_cb);
    }

    /* XXX These would probably be just as suitable placed in objects
     *     that did the layout so they could be packed as eg.
     *     widget.pack_start (new ChannelTreeView ...) */

    private void add_channel_treeview_content () {
        var channel_scroll = builder.get_object ("scrolledwindow_channels");
        Gee.Map<string, Cld.Object> channels = new Gee.TreeMap<string, Cld.Object> ();
        channels = model.ctx.get_object_map (typeof (Cld.Channel));
        channel_treeview = new ChannelTreeView (channels);
        (channel_scroll as Gtk.ScrolledWindow).set_min_content_width (_chan_scroll_min_width);

        /* XXX row_activated/cursor_changed(?) goes here */
        (channel_scroll as Gtk.Container).add (channel_treeview);
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
                data.add (model.ctx.get_object (series));
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

            charts.add (chart);
        }

        alignment.add (chart_box);
        (chart_scroll as Gtk.Container).add (alignment);
    }

    private void add_control_content () {
        var control_scroll = builder.get_object ("scrolledwindow_controls");

        var alignment = new Alignment (0.50f, 0.50f, 1.0f, 1.0f);
        alignment.top_padding = 5;
        alignment.right_padding = 5;
        alignment.bottom_padding = 5;
        alignment.left_padding = 5;

        var control_box = new Box (Orientation.VERTICAL, 10);
        foreach (var pid in model.control_loops.values) {
            //var pid_box = new PIDBox (pid as Cld.Pid);
            if (pid is Cld.Pid) {
                var pid_box = new PIDBox (pid.id, model);
                pid_box.settings_dialog = new PIDSettingsDialog (pid as Cld.Pid, model.channels);
                pid_box_list.add (pid_box);
            } else if (pid is Cld.Pid2) {
                var pid2_box = new PID2Box (pid.id, model);
                pid2_box.settings_dialog = new PID2SettingsDialog (pid as Cld.Pid2, model.dataseries);
                pid2_box_list.add (pid2_box);
            }
        }

        foreach (var box in pid_box_list) {
            (control_box as Box).pack_start (box, false, false, 0);
            control_box.pack_start (new Gtk.Separator (Orientation.HORIZONTAL), false, false, 0);
        }

        foreach (var box in pid2_box_list) {
            (control_box as Box).pack_start (box, false, false, 0);
            control_box.pack_start (new Gtk.Separator (Orientation.HORIZONTAL), false, false, 0);
        }

        foreach (var ao_channel in model.ao_channels.values) {
            if (ao_channel is Cld.AOChannel) {
                var ao_box = new AOBox (ao_channel.id, model);
                ao_box_list.add (ao_box);
            }
        }

        foreach (var box in ao_box_list) {
            (control_box as Box).pack_start (box, false, false, 0);
            control_box.pack_start (new Gtk.Separator (Orientation.HORIZONTAL), false, false, 0);
        }

        foreach (var do_channel in model.do_channels.values) {
            if (do_channel is Cld.DOChannel) {
                var do_box = new DOBox (do_channel.id, model);
                do_box_list.add (do_box);
            }
        }

        foreach (var box in do_box_list) {
            (control_box as Box).pack_start (box, false, false, 0);
            control_box.pack_start (new Gtk.Separator (Orientation.HORIZONTAL), false, false, 0);
        }

        alignment.add (control_box);
        (control_scroll as Gtk.Container).add (alignment);
    }

    private void add_module_content () {
        var module_scroll = builder.get_object ("scrolledwindow_modules");

        var alignment = new Alignment (0.50f, 0.50f, 1.0f, 1.0f);
        alignment.top_padding = 5;
        alignment.right_padding = 5;
        alignment.bottom_padding = 5;
        alignment.left_padding = 5;

        var module_box = new Box (Orientation.VERTICAL, 10);
        foreach (var module in model.modules.values) {
            if (module is LicorModule) {
                var licor_box = new LicorModuleBox ((module as Module), model.vchannels);
                module_box.pack_start (licor_box, false, false, 0);
                module_box.pack_start (new Gtk.Separator (Orientation.HORIZONTAL), false, false, 0);
            } else if (module is VelmexModule) {
                var velmex_box = new VelmexModuleBox ((module as Module));
                module_box.pack_start (velmex_box, false, false, 0);
            } else if (module is BrabenderModule) {
                var brabender_box = new BrabenderModuleBox ((module as Module));
                module_box.pack_start (brabender_box, false, false, 0);
            } else if (module is ParkerModule) {
                var parker_box = new ParkerModuleBox ((module as Module));
                module_box.pack_start (parker_box, false, false, 0);
            } else if (module is HeidolphModule) {
                var heidolph_box = new HeidolphModuleBox (module as Module);
                module_box.pack_start (heidolph_box, false, false, 0);
            }
        }

        /* pack module content */
        //licor_box = new LicorModuleBox (model.licor, model.vchannels);
        //module_box.pack_start (licor_box, false, false, 0);
        //module_box.pack_start (new Gtk.Separator (Orientation.HORIZONTAL), false, false, 0);

        //velmex_box = new VelmexModuleBox (model.velmex);
        //module_box.pack_start (velmex_box, false, false, 0);

        alignment.add (module_box);
        (module_scroll as Gtk.ScrolledWindow).add_with_viewport (alignment);
    }

    private void channel_cursor_changed_cb () {
        string id;
        TreeModel model;
        TreeIter iter;
        TreeSelection selection;
        Cld.Object channel;

        selection = (channel_treeview as Gtk.TreeView).get_selection ();
        selection.get_selected (out model, out iter);
        model.get (iter, ChannelTreeView.Columns.HIDDEN_ID, out id);

        GLib.debug ("Selected: %s", id);
        channel = this.model.ctx.get_object (id);

        /* This is an ugly way of doing this but it shouldn't matter */
        foreach (var chart in charts) {
            chart.select_series (id);
        }
    }

    /**
     * Run the data file chooser dialog.
     */
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
     */
    private void mnu_item_view_config_activate_cb () {
        Cld.debug ("Configuration file is: %s.\n", model.xml_file);
        show_file (model.xml_file);

    }

    /**
     * Launch the digital I/O viewer.
     */
    private void mnu_item_view_dig_cb () {
        Cld.debug ("Starting digital I/O viewer.\n");
        var viewer = new DIOViewer (model);
    }


    /**
     * Get the filename of the double clicked selection in the file chooser.
     */
    private void  dlg_data_file_chooser_file_activated_cb () {
        string  filename = (dlg_data_file_chooser as Gtk.FileChooserDialog).get_filename ();
        Cld.debug ("FileChooser :: filename is: %s\n", filename);
        recentmanager1.add_item ("file://" + filename);
        show_file (filename);
    }

    /**
     * Get the filename of the selection from the recent file chooser.
     */
    private void data_recent_chooser_item_activated_cb () {
        string uri = (data_recent_chooser as Gtk.RecentChooser).get_current_uri ();
        string filename = uri.substring (7, -1);
        //Cld.debug ("RecentChooser :: uri is: %s\n\tfilename is: %s\n", uri, filename);

        show_file (filename);
    }

    /**
     * Display the contents of the selected text file.
     */
    private void show_file (string filename) {

        try {
            string text;
            FileUtils.get_contents (filename, out text);
            ((this.textbuffer) as TextBuffer).text = text;
        } catch (GLib.Error e) {
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
}

/**
 * The view class in an MVC design is responsible for updating the display based
 * on the changes made to the model.
 *
 * XXX should consider adding signals where necessary in the model and only
 *     update the view when it fires a signal to improve performance.
 */
public class GraphicalView : Gtk.Application {

    /* Allow administrative functionality */
    public bool _admin = false;
    public bool admin {
        get { return _admin; }
        set {
            _admin = value;
        }
    }

    /* Model used to update the view */
    private ApplicationModel model;

    /* The main application window */
    private GraphicalWindow window;

    /**
     * Signals used to inform the controller that a request was made of
     * the model.
     */

    /**
     * Used when the user requests to quit.
     */
    public signal void closed ();
    public signal void save_requested ();


    /**
     * Default construction.
     */
    public GraphicalView (ApplicationModel model) {
        GLib.Object (application_id: "org.coanda.dactl", flags: ApplicationFlags.FLAGS_NONE);
        this.model = model;
    }

    /**
     * Load and launch the application window.
     */
    protected override void activate () {
        window = new GraphicalWindow (this, model);
        window.maximize ();
        window.show_all ();
    }

    /**
     * Perform the application setup including connecting interface callbacks
     * to the various actions.
     */
    protected override void startup () {
        base.startup ();

        /* XXX could probably do a lot of this in Glade */

        var pref_action = new SimpleAction ("pref", null);
        pref_action.activate.connect (preferences_activated_cb);
        this.add_action (pref_action);

        var settings_action = new SimpleAction ("settings", null);
        settings_action.activate.connect (settings_activated_cb);
        this.add_action (settings_action);

        var help_action = new SimpleAction ("help", null);
        help_action.activate.connect (help_activated_cb);
        this.add_action (help_action);

        var about_action = new SimpleAction ("about", null);
        about_action.activate.connect (about_activated_cb);
        this.add_action (about_action);

        var save_action = new SimpleAction ("save", null);
        save_action.activate.connect (save_activated_cb);
        this.add_action (save_action);

        var log_action = new SimpleAction.stateful ("log", null, new Variant.boolean (false));
        log_action.activate.connect (log_activated_cb);
        this.add_action (log_action);

        var acquire_action = new SimpleAction.stateful ("acquire", null, new Variant.boolean (false));
        acquire_action.activate.connect (acquire_activated_cb);
        this.add_action (acquire_action);

        var defaults_action = new SimpleAction.stateful ("defaults", null, new Variant.boolean (false));
        defaults_action.activate.connect (defaults_activated_cb);
        this.add_action (defaults_action);

        var quit_action = new SimpleAction ("quit", null);
        quit_action.activate.connect (quit_activated_cb);
        this.add_action (quit_action);

        var export_action = new SimpleAction ("export", null);
        export_action.activate.connect (export_activated_cb);
        this.add_action (export_action);

        /* Add some actions to the app menu */
        var help_menu = new GLib.Menu ();
        help_menu.append ("Help", "app.help");
        help_menu.append ("About Dactl", "app.about");
        var menu = new GLib.Menu ();
        menu.append_section (null, help_menu);
        menu.append ("Quit", "app.quit");
        this.app_menu = menu;
    }

    /**
     * Action callback for quit.
     */
    private void quit_activated_cb (SimpleAction action, Variant? parameter) {
        var dialog = new Gtk.MessageDialog (null,
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
                    this.quit ();
                    break;
            }
        });

        (dialog as Gtk.Dialog).run ();
    }

    /**
     * Action callback for export to CSV file.
     */
    private void export_activated_cb (SimpleAction action, Variant? parameter) {
        Cld.debug ("Export CSV dialog run started.\n");

        var dialog = new ExportCsvDialog (model);
        (dialog as Dialog).response.connect (dialog.response_cb);
        (dialog as Gtk.Dialog).run ();
        Cld.debug ("Export CSV dialog run complete. \n");
    }

    /**
     * Action callback for settings.
     */
    private void settings_activated_cb (SimpleAction action, Variant? parameter) {
        var dialog = new ApplicationSettingsDialog.with_startup_tab_id (model, 2);
        (dialog as Dialog).response.connect (dialog.response_cb);

        Cld.debug ("Preferences dialog run started.\n");
        (dialog as Gtk.Dialog).run ();
        Cld.debug ("Preferences dialog run complete.\n");
    }

    /**
     * Action callback for settings.
     */
    private void preferences_activated_cb (SimpleAction action, Variant? parameter) {
        var dialog = new ApplicationSettingsDialog.with_startup_tab_id (model, 0);
        (dialog as Dialog).response.connect (dialog.response_cb);

        Cld.debug ("Preferences dialog run started.\n");
        (dialog as Gtk.Dialog).run ();
        Cld.debug ("Preferences dialog run complete.\n");
    }

    /**
     * Action callback for saving the configuration file.
     */
    private void save_activated_cb (SimpleAction action, Variant? parameter) {
        /* Warn the user if <defaults> are currently enabled */
        if (model.def_enabled) {
            var dialog = new Gtk.MessageDialog (null,
                                                Gtk.DialogFlags.MODAL,
                                                Gtk.MessageType.QUESTION,
                                                Gtk.ButtonsType.YES_NO,
                                                "Calibrations are set to defaults.\nDo you still want to save?");

            (dialog as Gtk.Dialog).response.connect ((response_id) => {
                switch (response_id) {
                    case ResponseType.YES:
                        (dialog as Gtk.Dialog).destroy ();
                        break;
                    case ResponseType.NO:
                        (dialog as Gtk.Dialog).destroy ();
                        return;
                    default:
                        break;
                }
            });

            (dialog as Gtk.Dialog).run ();
        }

        /* Second check to confirm overwrite this time */
        var dialog = new Gtk.MessageDialog (null,
                                            Gtk.DialogFlags.MODAL,
                                            Gtk.MessageType.QUESTION,
                                            Gtk.ButtonsType.YES_NO,
                                            "Overwrite %s with application preferences?",
                                            model.config.file_name);

        (dialog as Gtk.Dialog).response.connect ((response_id) => {
            switch (response_id) {
                case ResponseType.YES:
                    /* Signal the controller if the user selected yes */
                    (dialog as Gtk.Dialog).destroy ();
                    save_requested ();
                    break;
                case ResponseType.NO:
                    (dialog as Gtk.Dialog).destroy ();
                    return;
                default:
                    break;
            }
        });

        (dialog as Gtk.Dialog).run ();
    }

    /**
     * Action callback for logging.
     */
    private void log_activated_cb (SimpleAction action, Variant? parameter) {
        /* XXX for multiple log files to work this needs to change */
        var log = model.ctx.get_object ("log0");
        int mode = Posix.R_OK | Posix.W_OK;
        int response = ResponseType.OK;
        bool go = false;                    /* XXX bad variable naming */

        /* XXX this could be done in a loop */
        Cld.debug ("Testing path: %s\n", (log as Cld.Log).path);
        if (Posix.access ((log as Cld.Log).path, mode) == 0) {
            Cld.debug ("Path is valid.\n");
            go = true;
        } else {
            /* Alert the user if path is not valid */
            var dialog = new Gtk.MessageDialog (null,
                                                DialogFlags.MODAL,
                                                MessageType.ERROR,
                                                ButtonsType.CANCEL,
                                                "File access permission denied: %s\n",
                                                (log as Cld.Log).path);

            dialog.secondary_text = "Use the Chooser to select a new directory.";
            dialog.response.connect ((response_id) => {
                switch (response_id) {
                    case Gtk.ResponseType.CANCEL:
                        break;
                }
                dialog.destroy();
            });

            dialog.run ();

            /* Allow user to select a different directory */
            var log_dialog = new LogSettingsDialog (log as Cld.Log);

            while (!((log_dialog as LogSettingsDialog).done)) {
                (log_dialog as Dialog).run ();
                Cld.debug ("running ...\n");
                if ((dialog as LogSettingsDialog).done) {
                    Cld.debug ("done = true\n");
                } else {
                    Cld.debug ("done = false\n");
                }
            }
            Cld.debug ("Finished.\n");
        }

        /* Test the path again */
        Cld.debug ("Path is %s\n", (log as Cld.Log).path);
        if (Posix.access ((log as Cld.Log).path, mode) == 0) {
            Cld.debug ("Path is valid.\n");
            go = true;
        } else {
            /* Alert the user that no log file will be generated. */
            var dialog = new Gtk.MessageDialog (null,
                                                DialogFlags.MODAL,
                                                MessageType.ERROR,
                                                ButtonsType.CANCEL,
                                                "File access permission denied: %s\n",
                                                (log as Cld.Log).path);

            dialog.secondary_text = "No log file will be generated.";
            dialog.response.connect ((response_id) => {
                switch (response_id) {
                    /* XXX what is this supposed to do?!?!? */
                    case Gtk.ResponseType.CANCEL:
                        break;
                }
                dialog.destroy();
            });

            dialog.run ();
        }

        /* XXX not sure this is necessary anymore, might be dealt with in CLD */
        if (!((log as Cld.Log).path.has_suffix ("/")))
            (log as Cld.Log).path = "%s%s".printf ((log as Cld.Log).path, "/");

        this.hold ();
        Variant state = action.get_state ();
        bool active = state.get_boolean ();
        action.set_state (new Variant.boolean (!active));
        /* XXX locking the model may not be necessary, from older version */
        if (!active && go) {
            lock (model) {
                model.start_log ();
            }
        } else {
            lock (model) {
                model.stop_log ();
            }
        }
        this.release ();
    }

    /**
     * Action callback for acquire.
     */
    private void acquire_activated_cb (SimpleAction action, Variant? parameter) {
        this.hold ();
        Variant state = action.get_state ();
        bool active = state.get_boolean ();
        action.set_state (new Variant.boolean (!active));
        /* XXX locking the model may not be necessary, from older version */
        if (!active) {
            lock (model) {
                model.start_acquisition ();
            }
        } else {
            lock (model) {
                model.stop_acquisition ();
            }
        }
        this.release ();
    }

    /**
     * Action callback for defaults.
     */
    private void defaults_activated_cb (SimpleAction action, Variant? parameter) {
        this.hold ();
        Variant state = action.get_state ();
        bool active = state.get_boolean ();
        action.set_state (new Variant.boolean (!active));
        if (!active) {
            model.def_enabled = true;
            foreach (var channel in model.channels.values) {
                /* Don't scale output channels */
                if (!(channel is Cld.AOChannel)) {
                    stdout.printf ("Found channel: %s reading %f\n",
                        channel.id, (channel as Cld.ScalableChannel).scaled_value);
                    var cal = (channel as Cld.ScalableChannel).calibration;
                    stdout.printf ("Found calibration: %s units %s\n",
                        cal.id, cal.units);
                    cal.units = "Volts";
                    foreach (var coefficient in cal.coefficients.values) {
                        stdout.printf ("Found coefficient: %s\n", coefficient.id);
                        if ((coefficient as Cld.Coefficient).n == 1)
                            (coefficient as Cld.Coefficient).value = 1.0;
                        else
                            (coefficient as Cld.Coefficient).value = 0.0;
                    }
                }
            }
        } else {
            model.def_enabled = false;
            foreach (var channel in model.channels.values) {
                /* Don't scale output channels */
                if (!(channel is Cld.AOChannel)) {
                    stdout.printf ("Found channel: %s reading %f\n",
                        channel.id, (channel as Cld.ScalableChannel).scaled_value);
                    var cal = (channel as Cld.ScalableChannel).calibration;
                    stdout.printf ("Found calibration: %s units %s\n",
                        cal.id, cal.units);

                    var xpath = "//cld/cld:objects/cld:object[@id=\"%s\"]/cld:property[@name=\"units\"]".printf (cal.id);
                    var value = model.xml.value_at_xpath (xpath);
                    cal.units = value;

                    foreach (var coefficient in cal.coefficients.values) {
                        stdout.printf ("Found coefficient: %s\n", coefficient.id);
                        xpath = "//cld/cld:objects/cld:object[@id=\"%s\"]/cld:object[@id=\"%s\"]/cld:property[@name=\"value\"]".printf (cal.id, coefficient.id);
                        value = model.xml.value_at_xpath (xpath);
                        stdout.printf ("Printing @ %s: value: %s\n", xpath, value);
                        (coefficient as Cld.Coefficient).value = double.parse (value);
                    }
                }
            }
        }
        this.release ();
    }

    /**
     * Action callback for about.
     */
    private void about_activated_cb (SimpleAction action, Variant? parameter) {
        string path = GLib.Path.build_filename (Config.UI_DIR,
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

    /**
     * Action callback for help.
     */
    private void help_activated_cb (SimpleAction action, Variant? parameter) {
        GLib.message ("Help requested.");
    }
}
