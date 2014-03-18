using Cld;
using Gee;
using Gtk;
using Dactl;

/**
 * The Gtk.Application class expects an ApplicationWindow so a lot is being
 * moved here from outside of the actual view class.
 */
public class Dactl.UI.ApplicationView : Gtk.ApplicationWindow, Dactl.ApplicationView {

    /* Property backing fields */
    private int _chan_scroll_min_width = 50;

    /**
     * From previous versions, limits the width of an interface element.
     */
    public int chan_scroll_min_width {
        get { return _chan_scroll_min_width; }
        set { _chan_scroll_min_width = value; }
    }

    /**
     * The value is controlled by the existence of certain configuration
     * elements. If it's true a default interface layout will be constructed
     * otherwise a valid layout is expected to be provided.
     */
    public bool using_default { get; private set; default = true; }

    /* Model used to update the view */
    private Dactl.ApplicationModel model;

    /* Widgets and data needed for interface */
    private GLib.Settings settings;
    private Gtk.Widget notebook;
    private Gtk.Widget frame_channels;
    private Gtk.Widget frame_charts;
    private Gtk.Widget frame_controls;
    private Gtk.Widget frame_modules;
    private Gtk.Widget btn_acq;
    private Gtk.Widget btn_log;
    private Gtk.Widget mnu_item_view_dig;

    /* This is all stuff that will need to be upgraded to new layout method */
    private Dactl.ChannelTreeView channel_treeview;
    private Gee.List<ChartWidget> charts = new Gee.ArrayList<ChartWidget> ();
    private Gee.List<PIDBox> pid_box_list = new Gee.ArrayList<PIDBox> ();
    //private Gee.List<ModuleBox> module_box_list = new Gee.ArrayList<ModuleBox> ();

    /**
     * Default construction.
     *
     * @param model Data model class that the interface uses to update itself
     * @return A new instance of an ApplicationView object
     */
    internal ApplicationView (Dactl.ApplicationModel model) {
        GLib.Object (title: "Data Acquisition and Control",
                     window_position: WindowPosition.CENTER);

        this.model = model;
        assert (this.model != null);

        (this as Gtk.ApplicationWindow).set_default_size (1280, 720);

        load_widgets ();
        load_style ();
    }

    /**
     * Load all Gtk widgets that will be used internally with the
     * application window.
     */
    private void load_widgets () {
        /* Load anything that's needed from the toolbar */
        var tb_builder = load_ui ("toolbar.ui");
        btn_acq = tb_builder.get_object ("btn_acq") as Widget;
        btn_log = tb_builder.get_object ("btn_log") as Widget;

        /* Load what's needed into the top-level grid */
        var grid = new Gtk.Grid ();
        (grid as Gtk.Widget).expand = true;
        this.add (grid);
        grid.show ();

        /* All layout panels will be placed inside of a notebook to allow for
         * multiple buildable pages */
        notebook = new Gtk.Notebook ();
        notebook.expand = true;

        //grid.attach (mb_builder.get_object ("menubar") as Gtk.Widget, 0, 0, 1, 1);
        grid.attach (tb_builder.get_object ("toolbar") as Gtk.Widget, 0, 0, 1, 1);
        grid.attach (notebook, 0, 1, 1, 1);
    }

    /**
     * Load the application styling from CSS.
     */
    private void load_style () {

        /* XXX use resource instead - see gtk3-demo for example */

        /* Apply stylings from CSS resource */
        var provider = Dactl.load_css ("gtk-style.css");
        Gtk.StyleContext.add_provider_for_screen (Gdk.Screen.get_default (),
                                                  provider,
                                                  600);
    }

    /**
     * Construct the layout using the contents of the configuration file.
     *
     * Lists of objects included:
     * - pages
     * - boxes
     * - trees
     * - charts
     * - control views
     * - module/plugin views
     */
    public void construct_layout () {

        using_default = (model.page_map.size == 0) ? true : false;

        /* If no pages were defined load the default layout */
        if (using_default) {
            load_default_layout ();
        } else {
            /* Currently only pages can be added to the notebook */
            foreach (var page in model.page_map.values) {
                GLib.message ("Constructing layout for page `%s'", page.id);
                layout_add_page (page as Dactl.Page);
            }

            notebook.show_all ();
        }

        /* No point taking up space unnecessarily */
        if ((notebook as Gtk.Notebook).get_n_pages () == 1) {
            (notebook as Gtk.Notebook).show_tabs = false;
        }
    }

    /**
     * This should load a default layout for the interface if one was defined
     * in the application configuration.
     *
     * XXX in its current state this doesn't work, this is all from the old
     *     Gtk and Glade based design, a new design should extend the Page class
     *     and add the elements by packing them into a GtkClutter.Embed widget
     */
    private void load_default_layout () {

        /* FIXME: this should go away in the future and the default layout is
         *        just an empty one with possibly a channel tree */
        var builder = load_ui ("default_layout.ui");

        /* These are all of the widgets that are needed without using builder */
        frame_channels = builder.get_object ("frame_channels") as Widget;
        frame_charts = builder.get_object ("frame_charts") as Widget;
        frame_controls = builder.get_object ("frame_controls") as Widget;
        frame_modules = builder.get_object ("frame_modules") as Widget;

        Gtk.Label title = new Gtk.Label ("Default Layout");
        Gtk.Box content = builder.get_object ("default_layout") as Gtk.Box;
        (notebook as Gtk.Notebook).append_page (content, title);

        /* Get content box and fill */
        /*
         *var channel_scroll = builder.get_object ("scrolledwindow_channels");
         *add_channel_treeview_content (channel_scroll as Gtk.Widget);
         */

        var chart_scroll = builder.get_object ("scrolledwindow_charts");
        add_chart_content (chart_scroll as Gtk.Widget);

        var control_scroll = builder.get_object ("scrolledwindow_controls");
        add_control_content (control_scroll as Gtk.Widget);

        var module_scroll = builder.get_object ("scrolledwindow_modules");
        add_module_content (module_scroll as Gtk.Widget);

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

    private void layout_add_page (Dactl.Page page) {
        var title = new Gtk.Label (page.model.title);
        var content = page.view;
        GLib.message ("Adding page `%s' with title `%s'",
                      page.id, page.model.title);
        (notebook as Gtk.Notebook).append_page (content, title);
        page.add_children ();
    }

    public void connect_signals () {
        /* Signals from the application data model */
        model.acquisition_state_changed.connect ((state) => {
            if (state)
                (btn_acq as Gtk.ToolButton).set_icon_name ("media-playback-stop");
            else
                (btn_acq as Gtk.ToolButton).set_icon_name ("media-playback-start");
        });

        model.log_state_changed.connect ((id, state) => {
            if (state) {
                (btn_log as Gtk.ToolButton).set_icon_name ("media-playback-stop");
            } else {
                GLib.message ("stopping logging");
                (btn_log as Gtk.ToolButton).set_icon_name ("media-record");
            }
        });

        if (using_default) {
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
        }

        /* Callbacks with functions */
        //channel_treeview.cursor_changed.connect (channel_cursor_changed_cb);

        /*
         *(mnu_item_view_data as Gtk.MenuItem).activate.connect (mnu_item_view_data_activate_cb);
         *(mnu_item_view_config as Gtk.MenuItem).activate.connect (mnu_item_view_config_activate_cb);
         *(mnu_item_view_dig as Gtk.MenuItem).activate.connect (mnu_item_view_dig_cb);
         */
        //(dlg_data_file_chooser as Gtk.FileChooserDialog).file_activated.connect (dlg_data_file_chooser_file_activated_cb);
        //(data_recent_chooser as Gtk.RecentChooser).item_activated.connect (data_recent_chooser_item_activated_cb);
    }

    /* XXX These would probably be just as suitable placed in objects
     *     that did the layout so they could be packed as eg.
     *     widget.pack_start (new Dactl.ChannelTreeView ...) */

    private void add_chart_content (Gtk.Widget scrolled_window) {
        (scrolled_window as Gtk.ScrolledWindow).min_content_width = 600;
        (scrolled_window as Gtk.ScrolledWindow).min_content_height = 600;

        var alignment = new Alignment (0.50f, 0.50f, 1.0f, 1.0f);
        alignment.top_padding = 5;
        alignment.right_padding = 10;
        alignment.bottom_padding = 5;
        alignment.left_padding = 5;

        var chart_box = new Gtk.Box (Orientation.VERTICAL, 0);

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
            chart.settings_dialog = new Dactl.ChartSettingsDialog (chart as ChartWidget);

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
                chart.add_series_color (hex_to_rgb (color));
            }

            /* meh... fix? */
            (chart_box as Gtk.Box).pack_start (chart, true, true, 0);
            (chart_box as Gtk.Box).pack_start (new Gtk.Separator (Orientation.HORIZONTAL), false, false, 0);

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
        (scrolled_window as Gtk.Container).add (alignment);
    }

    private void add_control_content (Gtk.Widget scrolled_window) {
        var alignment = new Alignment (0.50f, 0.50f, 1.0f, 1.0f);
        alignment.top_padding = 5;
        alignment.right_padding = 5;
        alignment.bottom_padding = 5;
        alignment.left_padding = 5;

        var control_box = new Gtk.Box (Orientation.VERTICAL, 10);
        foreach (var pid in model.control_loops.values) {
            //var pid_box = new PIDBox (pid as Cld.Pid);
            var pid_box = new PIDBox (pid.id, model);
            pid_box.settings_dialog = new PIDSettingsDialog (pid as Cld.Pid, model.channels);
            pid_box_list.add (pid_box);
        }

        foreach (var box in pid_box_list) {
            (control_box as Gtk.Box).pack_start (box, false, false, 0);
            control_box.pack_start (new Gtk.Separator (Orientation.HORIZONTAL), false, false, 0);
        }

        alignment.add (control_box);
        (scrolled_window as Gtk.Container).add (alignment);
    }

    private void add_module_content (Gtk.Widget scrolled_window) {
        var alignment = new Alignment (0.50f, 0.50f, 1.0f, 1.0f);
        alignment.top_padding = 5;
        alignment.right_padding = 5;
        alignment.bottom_padding = 5;
        alignment.left_padding = 5;

        /* Pack module content */
        var module_box = new Gtk.Box (Orientation.VERTICAL, 10);
        /*
         *foreach (var module in model.modules.values) {
         *    if (module is LicorModule) {
         *        var licor_box = new LicorModuleBox ((module as Cld.Module), model.vchannels);
         *        module_box.pack_start (licor_box, false, false, 0);
         *        module_box.pack_start (new Gtk.Separator (Orientation.HORIZONTAL), false, false, 0);
         *    } else if (module is VelmexModule) {
         *        var velmex_box = new VelmexModuleBox ((module as Cld.Module));
         *        module_box.pack_start (velmex_box, false, false, 0);
         *    } else if (module is BrabenderModule) {
         *        var brabender_box = new BrabenderModuleBox ((module as Cld.Module));
         *        module_box.pack_start (brabender_box, false, false, 0);
         *    } else if (module is ParkerModule) {
         *        var parker_box = new ParkerModuleBox ((module as Cld.Module));
         *        module_box.pack_start (parker_box, false, false, 0);
         *    } else if (module is HeidolphModule) {
         *        var heidolph_box = new HeidolphModuleBox (module as Cld.Module);
         *        module_box.pack_start (heidolph_box, false, false, 0);
         *    }
         *}
         */

        alignment.add (module_box);
        (scrolled_window as Gtk.Container).add (alignment);
    }

    private void channel_cursor_changed_cb () {
        string id;
        TreeModel model;
        TreeIter iter;
        TreeSelection selection;
        Cld.Object channel;

        selection = (channel_treeview as Gtk.TreeView).get_selection ();
        selection.get_selected (out model, out iter);
        model.get (iter, Dactl.ChannelTreeView.Columns.HIDDEN_ID, out id);

        GLib.debug ("Selected: %s", id);
        channel = this.model.ctx.get_object (id);

        /* This is an ugly way of doing this but it shouldn't matter */
        foreach (var chart in charts) {
            chart.select_series (id);
        }
    }
}
