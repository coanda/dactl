/**
 * The view class in an MVC design is responsible for updating the display based
 * on the changes made to the model.
 *
 * XXX should consider adding signals where necessary in the model and only
 *     update the view when it fires a signal to improve performance.
 */
public class Dactl.UI.Application : Gtk.Application, Dactl.Application {

    /* Application singleton */
    private static Dactl.UI.Application app;

    public bool _admin = false;
    /**
     * Allow administrative functionality
     */
    public bool admin {
        get { return _admin; }
        set {
            _admin = value;
        }
    }

    /**
     * {@inheritDoc}
     */
    public virtual Dactl.ApplicationModel model { get; set; }

    /**
     * {@inheritDoc}
     */
    public virtual Dactl.ApplicationView view { get; set; }

    /**
     * {@inheritDoc}
     */
    public virtual Dactl.ApplicationController controller { get; set; }

    /**
     * Signals used to inform the controller that a request was made of
     * the model.
     */

    /**
     * Used when the user requests to quit.
     */
    public signal void save_requested ();

    /**
     * Returns the singleton for this class creating it first if it hasn't
     * been yet.
     */
    public static new Dactl.UI.Application get_default () {
        if (app == null) {
            app = new Dactl.UI.Application ();
        }
        return app;
    }

    /**
     * Default construction.
     */
    internal Application () {
        string[] args1 = {};
        unowned string[] args2 = args1;
        Gtk.init (ref args2);

        GLib.message ("Application construction");

        GLib.Object (application_id: "org.coanda.dactl",
                     flags: ApplicationFlags.HANDLES_COMMAND_LINE);
    }

    /**
     * XXX All of these actions could probably be bound using [GtkCallback] by
     *     creating the ApplicationView as a GtkTemplate of
     *     Gtk.ApplicationWindow.
     */
    private void add_actions () {
        /* file menu actions */
        var save_action = new SimpleAction ("save", null);
        save_action.activate.connect (save_activated_cb);
        this.add_action (save_action);

        /* view menu actions */
        var view_data_action = new SimpleAction ("data", null);
        view_data_action.activate.connect (view_data_action_activated_cb);
        this.add_action (view_data_action);

        /*
         *var view_recent_action = new SimpleAction ("recent", null);
         *view_recent_action.activate.connect (view_recent_action_activated_cb);
         *this.add_action (view_recent_action);
         */

        /*
         *var view_digio_action = new SimpleAction ("digio", null);
         *view_digio_action.activate.connect (view_digio_action_activated_cb);
         *this.add_action (view_digio_action);
         */

        var configuration_action = new SimpleAction ("configuration", null);
        configuration_action.activate.connect (configuration_action_activated_cb);
        this.add_action (configuration_action);

        var configuration_back_action = new SimpleAction ("configuration-back", null);
        configuration_back_action.activate.connect (configuration_back_activated_cb);
        this.add_action (configuration_back_action);

        /* admin menu actions */
        var defaults_action = new SimpleAction.stateful ("defaults", null, new Variant.boolean (false));
        defaults_action.activate.connect (defaults_activated_cb);
        this.add_action (defaults_action);

        /* top-level menu actions */
        var help_action = new SimpleAction ("help", null);
        help_action.activate.connect (help_activated_cb);
        this.add_action (help_action);

        var about_action = new SimpleAction ("about", null);
        about_action.activate.connect (about_activated_cb);
        this.add_action (about_action);

        var quit_action = new SimpleAction ("quit", null);
        quit_action.activate.connect (quit_activated_cb);
        this.add_action (quit_action);

        /* toolbar actions */
        var log_action = new SimpleAction.stateful ("log", null, new Variant.boolean (false));
        log_action.activate.connect (log_activated_cb);
        this.add_action (log_action);

        var previous_page_action = new SimpleAction ("previous-page", null);
        previous_page_action.activate.connect (previous_page_activated_cb);
        this.add_action (previous_page_action);

        var next_page_action = new SimpleAction ("next-page", null);
        next_page_action.activate.connect (next_page_activated_cb);
        this.add_action (next_page_action);

        var settings_action = new SimpleAction ("settings", null);
        settings_action.activate.connect (settings_activated_cb);
        this.add_action (settings_action);

        var settings_back_action = new SimpleAction ("settings-back", null);
        settings_back_action.activate.connect (settings_back_activated_cb);
        this.add_action (settings_back_action);

        /* Handling some of the actions at the view level to reduce the need to
         * make public a lot of widget content. */
        (view as Dactl.UI.ApplicationView).add_actions ();
    }

    /**
     * Load and launch the application window.
     */
    protected override void activate () {
        base.activate ();

        Gtk.Window.set_default_icon_name ("dactl");
        Gtk.Settings.get_default ().gtk_application_prefer_dark_theme = true;

        GLib.message ("Creating application model using file %s", opt_cfgfile);
        model = new Dactl.ApplicationModel (opt_cfgfile);
        assert (model != null);
        //model.verbose = opt_verbose;

        view = new Dactl.UI.ApplicationView (model);
        assert (view != null);
        (view as Gtk.Window).application = this;

        /**
         * FIXME: This hides the window and then shows the message box
         *
         *(view as Gtk.Window).destroy.connect (() => {
         *    activate_action ("quit", null);
         *});
         */

        controller = new Dactl.ApplicationController.with_data (model, view);
        assert (controller != null);

        model.notify["admin"].connect (() => {
            admin = model.admin;
            controller.admin = model.admin;
        });

        add_app_menu ();

        /* XXX would like to move this inside of the view but doesn't work until
         *     the application activate is performed */
        (view as Dactl.UI.ApplicationView).maximize ();
        (view as Dactl.UI.ApplicationView).show_all ();

        (view as Gtk.ApplicationWindow).present ();

        /* Load the layout from either the configuration or use the default */
        (view as Dactl.UI.ApplicationView).construct_layout ();
        (view as Dactl.UI.ApplicationView).layout_change_page (model.startup_page);
        (view as Dactl.UI.ApplicationView).connect_signals ();

        add_actions ();

        lock (model) {
            message ("Start device acquisition and output tasks");
            model.start_acquisition ();
            //model.start_device_output ();
        }
    }

    /**
     * Perform the application setup including connecting interface callbacks
     * to the various actions.
     */
    protected override void startup () {
        base.startup ();
    }

    private void add_app_menu () {
        /* Add some actions to the app menu */
        var file_menu = new GLib.Menu ();
        file_menu.append ("Save", "app.save");
        file_menu.append ("Export", "app.export");

        var view_menu = new GLib.Menu ();
        view_menu.append ("Data", "app.data");
        view_menu.append ("Configuration", "app.configuration");
        //view_menu.append ("Recent", "app.recent");
        //view_menu.append ("Digital I/O", "app.digio");

        /*
         *var settings_menu = new GLib.Menu ();
         *settings_menu.append ("Settings", "app.settings");
         */

        var menu = new GLib.Menu ();
        menu.append_submenu ("File", file_menu);
        menu.append_submenu ("View", view_menu);

        if (model.admin) {
            message ("Adding a menu for admin functionality");
            var admin_menu = new GLib.Menu ();
            admin_menu.append ("Defaults", "app.defaults");
            menu.append_submenu ("Admin", admin_menu);
        }

        //menu.append_section (null, settings_menu);
        menu.append ("Help", "app.help");
        menu.append ("About Dactl", "app.about");
        menu.append ("Quit", "app.quit");
        app_menu = menu;
    }

    public override void shutdown () {
        base.shutdown ();

        lock (model) {
            message ("Stopping device acquisition and output tasks");
            model.stop_acquisition ();
            //model.stop_device_output ();
        }

        /* Let someone else deal with shutting down. */
        closed ();
    }

    public virtual int launch (string[] args) {
        return (this as Gtk.Application).run (args);
    }

    /**
     * XXX should test moving this into the Utility file so that it doesn't
     *     need to be created in every application class
     */
    static bool opt_admin;
    static bool opt_help;
    static string opt_cfgfile;
    static const OptionEntry[] options = {{
        "admin", 'a', 0, OptionArg.NONE, ref opt_admin,
        "Allow administrative functionality.", null
    },{
        "cli", 'c', 0, OptionArg.NONE, null,
        "Start the application with a command line interface", null
    },{
        "config", 'f', 0, OptionArg.STRING, ref opt_cfgfile,
        "Use the given configuration file.", null
    },{
        "help", 'h', 0, OptionArg.NONE, ref opt_help,
        null, null
    },{
        "verbose", 'v', 0, OptionArg.NONE, null,
        "Provide verbose debugging output.", null
    },{
        "version", 'V', 0, OptionArg.NONE, null,
        "Display version number.", null
    },{
        null
    }};

    public override int command_line (GLib.ApplicationCommandLine cmdline) {
        opt_admin = false;
        opt_help = false;
        opt_cfgfile = null;

        var opt_context = new OptionContext (Config.PACKAGE_NAME);
        opt_context.add_main_entries (options, null);
        opt_context.set_help_enabled (false);

        try {
            string[] args1 = cmdline.get_arguments ();
            unowned string[] args2 = args1;
            opt_context.parse (ref args2);
        } catch (OptionError e) {
           cmdline.printerr ("error: %s\n", e.message);
           cmdline.printerr (opt_context.get_help (true, null));
           return 1;
        }

        if (opt_help) {
            cmdline.printerr (opt_context.get_help (true, null));
            return 1;
        }

        if (opt_cfgfile == null) {

            opt_cfgfile = Path.build_filename (Config.DATADIR, "dactl.xml");
            GLib.message ("Configuration file not provided, using %s", opt_cfgfile);
        }

        admin = opt_admin;

        /* XXX not sure if this is the correct way to use this yet */
        activate ();

        return 0;
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
                case Gtk.ResponseType.NO:
                    (dialog as Gtk.Dialog).destroy ();
                    break;
                case Gtk.ResponseType.YES:
                    (dialog as Gtk.Dialog).destroy ();
                    this.quit ();
                    break;
            }
        });

        (dialog as Gtk.Dialog).run ();
    }

    /**
     * Action callback for settings.
     */
    private void settings_activated_cb (SimpleAction action, Variant? parameter) {
        (view as Dactl.UI.ApplicationView).layout_change_page ("settings");
    }

    /**
     * Action callback for going back to previous page from settings.
     */
    private void settings_back_activated_cb (SimpleAction action, Variant? parameter) {
        (view as Dactl.UI.ApplicationView).layout_back_page ();
    }

    /**
     * Action callback for configuration.
     */
    private void configuration_action_activated_cb (SimpleAction action, Variant? parameter) {
        (view as Dactl.UI.ApplicationView).layout_change_page ("configuration");
    }

    /**
     * Action callback for going back to previous page from configuration.
     */
    private void configuration_back_activated_cb (SimpleAction action, Variant? parameter) {
        (view as Dactl.UI.ApplicationView).layout_back_page ();
    }

    /**
     * Action callback for going to the previous available non-settings page.
     */
    private void previous_page_activated_cb (SimpleAction action, Variant? parameter) {
        (view as Dactl.UI.ApplicationView).layout_previous_page ();
    }

    /**
     * Action callback for going to the next available non-settings page.
     */
    private void next_page_activated_cb (SimpleAction action, Variant? parameter) {
        (view as Dactl.UI.ApplicationView).layout_next_page ();
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
                    case Gtk.ResponseType.YES:
                        (dialog as Gtk.Dialog).destroy ();
                        break;
                    case Gtk.ResponseType.NO:
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
                case Gtk.ResponseType.YES:
                    /* Signal the controller if the user selected yes */
                    (dialog as Gtk.Dialog).destroy ();
                    save_requested ();
                    break;
                case Gtk.ResponseType.NO:
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
/*
 *        [> FIXME: this should be better <]
 *
 *        [> XXX for multiple log files to work this needs to change <]
 *        var log = model.ctx.get_object_from_uri ("/ctr0/logctl0/log0");
 *        message (log.to_string ());
 *        int mode = Posix.R_OK | Posix.W_OK;
 *        int response = Gtk.ResponseType.OK;
 *        bool go = false;                    [> XXX bad variable naming <]
 *
 *        [> XXX this could be done in a loop <]
 *        message ("Testing path: %s", (log as Cld.Log).path);
 *        if (Posix.access ((log as Cld.Log).path, mode) == 0) {
 *            warning ("Path is valid.");
 *            go = true;
 *        } else {
 *            [> Alert the user if path is not valid <]
 *            var dialog = new Gtk.MessageDialog (null,
 *                                                Gtk.DialogFlags.MODAL,
 *                                                Gtk.MessageType.ERROR,
 *                                                Gtk.ButtonsType.CANCEL,
 *                                                "File access permission denied: %s\n",
 *                                                (log as Cld.Log).path);
 *
 *            dialog.secondary_text = "Use the Chooser to select a new directory.";
 *            dialog.response.connect ((response_id) => {
 *                switch (response_id) {
 *                    case Gtk.ResponseType.CANCEL:
 *                        break;
 *                }
 *                dialog.destroy();
 *            });
 *
 *            dialog.run ();
 *
 *            [> Allow user to select a different directory <]
 *            var log_dialog = new Dactl.LogSettingsDialog (log as Cld.Log);
 *
 *            while (!((log_dialog as Dactl.LogSettingsDialog).done)) {
 *                (log_dialog as Gtk.Dialog).run ();
 *                debug ("running ...");
 *                if ((dialog as Dactl.LogSettingsDialog).done) {
 *                    debug ("done = true");
 *                } else {
 *                    debug ("done = false");
 *                }
 *            }
 *            debug ("Finished.");
 *        }
 *
 *        [> Test the path again <]
 *        message ("Path is %s", (log as Cld.Log).path);
 *        if (Posix.access ((log as Cld.Log).path, mode) == 0) {
 *            debug ("Path is valid.");
 *            go = true;
 *        } else {
 *            [> Alert the user that no log file will be generated. <]
 *            var dialog = new Gtk.MessageDialog (null,
 *                                                Gtk.DialogFlags.MODAL,
 *                                                Gtk.MessageType.ERROR,
 *                                                Gtk.ButtonsType.CANCEL,
 *                                                "File access permission denied: %s\n",
 *                                                (log as Cld.Log).path);
 *
 *            dialog.secondary_text = "No log file will be generated.";
 *            dialog.response.connect ((response_id) => {
 *                switch (response_id) {
 *                    [> XXX what is this supposed to do?!?!? <]
 *                    case Gtk.ResponseType.CANCEL:
 *                        break;
 *                }
 *                dialog.destroy();
 *            });
 *
 *            dialog.run ();
 *        }
 *
 *        [> XXX not sure this is necessary anymore, might be dealt with in CLD <]
 *        if (!((log as Cld.Log).path.has_suffix ("/")))
 *            (log as Cld.Log).path = "%s%s".printf ((log as Cld.Log).path, "/");
 *
 *        this.hold ();
 *        Variant state = action.get_state ();
 *        bool active = state.get_boolean ();
 *        action.set_state (new Variant.boolean (!active));
 *        [> XXX locking the model may not be necessary, from older version <]
 *        if (!active && go) {
 *            lock (model) {
 *                model.start_log ();
 *            }
 *        } else {
 *            lock (model) {
 *                model.stop_log ();
 *            }
 *        }
 *        this.release ();
 */
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

        var channels = model.ctx.get_object_map (typeof (Cld.Channel));

        if (!active) {
            model.def_enabled = true;
            foreach (var channel in channels.values) {
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
            /* FIXME: the application shouldn't have to use XPath for edits */
            model.def_enabled = false;
            foreach (var channel in channels.values) {
                /* Don't scale output channels */
                if (!(channel is Cld.AOChannel)) {
                    stdout.printf ("Found channel: %s reading %f\n",
                        channel.id, (channel as Cld.ScalableChannel).scaled_value);
                    var cal = (channel as Cld.ScalableChannel).calibration;
                    stdout.printf ("Found calibration: %s units %s\n",
                        cal.id, cal.units);

                    var xpath = "//cld/cld:objects/cld:object[@id=\"%s\"]/cld:property[@name=\"units\"]".printf (cal.id);
                    string value;

                    try {
                        value = model.xml.value_at_xpath (xpath);
                        cal.units = value;
                    } catch (Cld.XmlError error) {
                        warning (error.message);
                    }

                    foreach (var coefficient in cal.coefficients.values) {
                        stdout.printf ("Found coefficient: %s\n", coefficient.id);
                        xpath = "//cld/cld:objects/cld:object[@id=\"%s\"]/cld:object[@id=\"%s\"]/cld:property[@name=\"value\"]".printf (cal.id, coefficient.id);
                        try {
                            value = model.xml.value_at_xpath (xpath);
                            stdout.printf ("Printing @ %s: value: %s\n", xpath, value);
                            (coefficient as Cld.Coefficient).value = double.parse (value);
                        } catch (Cld.XmlError error) {
                            warning (error.message);
                        }
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
        var window = get_active_window ();

        string[] authors = {
            "Geoff Johnson <geoff.johnson@coanda.ca>",
            "Stephen Roy <stephen.roy@coanda.ca>"
        };

        string[] documenters = {
            "Geoff Johnson <geoff.johnson@coanda.ca>",
            "Stephen Roy <stephen.roy@coanda.ca>"
        };

        string comments = N_("dactl is an application for data acquisition and control for the GNOME Desktop");

        Gdk.Pixbuf? logo = null;
        try {
            logo = Dactl.load_asset ("scalable/dactl.svg");
        } catch (GLib.Error error) {
            warning (error.message);
        }

        Gtk.show_about_dialog (window,
                               "program-name", ("Dactl"),
                               "authors", authors,
                               "comments", _(comments),
                               "copyright", ("Copyright © 2012-2014 Coanda"),
                               "license", Gtk.License.UNKNOWN,
                               "documenters", documenters,
                               "logo", logo,
                               "version", Config.PACKAGE_VERSION,
                               "website", "http://www.coanda.ca",
                               "website-label", ("Coanda Research and Development"));
    }

    /**
     * Action callback for help.
     */
    private void help_activated_cb (SimpleAction action, Variant? parameter) {
        GLib.message ("Help: Documentation viewer activated.");
    }

    /**
     * View menu actions.
     */
    private void view_data_action_activated_cb (SimpleAction action, Variant? parameter) {
        GLib.message ("View: Data viewer action activated");
    }

    /*
     *private void view_digio_action_activated_cb (SimpleAction action, Variant? parameter) {
     *    GLib.message ("View: Digital I/O viewer action activated");
     *    var dialog = new Dactl.DioViewerDialog (model);
     *}
     */

    /*
     *private void view_recent_action_activated_cb (SimpleAction action, Variant? parameter) {
     *    GLib.message ("View: Recent files action activated");
     *    var dialog = new Dactl.RecentFilesDialog ();
     *}
     */
}
