/**
 * Main application class responsible for interfacing with data and different
 * interface types.
 */
public class Dactl.ApplicationModel : GLib.Object, Dactl.Container {

    /**
     * Default configuration file name.
     */
    public string config_filename { get; set; default = "dactl.xml"; }

    /**
     * Flag indicating thread activity... I think.
     * XXX pretty sure this isn't being used anymore.
     */
    public bool active { get; set; default = false; }

    /* Allow administrative functionality */
    public bool admin { get; set; default = false; }

    /* Which page to load on startup */
    public string startup_page { get; set; default = "pg0"; }

    /* Basic output verbosity, should use an integer to allow for -vvv */
    public bool verbose { get; set; default = false; }

    /* Application data */
    public Dactl.ApplicationConfig config { get; private set; }

    /* CLD data */
    public Cld.XmlConfig xml { get; private set; }
    public Cld.Context ctx { get; private set; }

    /* GSettings data */
    public Settings settings { get; private set; }

    private bool _def_enabled = false;
    /* Flag to set if user has set the calibrations to <default> */
    public bool def_enabled {
        get { return _def_enabled; }
        set { _def_enabled = value; }
    }

    private Gee.Map<string, Dactl.Object> _objects;
    /**
     * {@inheritDoc}
     */
    public Gee.Map<string, Dactl.Object> objects {
        get { return (_objects); }
        set { update_objects (value); }
    }

    //public Gee.Collection<Dactl.Plugin> plugins { get; set; }

    /**
     * Emitted whenever the data acquisition state is changed.
     */
    public signal void acquisition_state_changed (bool state);

    /**
     * Emitted whenever the state of a log has been changed.
     * XXX not sure this is used anymore
     */
    public signal void log_state_changed (string log, bool state);

    /**
     * Default construction.
     */
    public ApplicationModel (string config_filename) {
        this.config_filename = config_filename;

        if (!FileUtils.test (config_filename, FileTest.EXISTS)) {
            /* XXX might be better if somehow done after gui was launched
             *     so that a dialog could be given, or use conditional
             *     ApplicationModel construction */
            critical ("Configuration selection '%s' does not exist.", config_filename);
        }

        /* Load the entire application configuration file */
        config = new Dactl.ApplicationConfig (this.config_filename);

        var factory = Dactl.ApplicationFactory.get_default ();

        /* Get the nodeset to use from the configuration */
        try {
            Xml.Node *node = config.get_xml_node ("/dactl/objects/object");
            objects = factory.make_object_map (node);
        } catch (Dactl.ConfigError e) {
            GLib.error ("Configuration error: %s", e.message);
        }

        (this as Dactl.Container).print_objects (0);

        /* Load the CLD specific configuration and builder */
        Xml.Node *node;
        try {
            node = config.get_xml_node ("//dactl/cld:objects");
            xml = new Cld.XmlConfig.from_node (node);
            ctx = new Cld.Context.from_config (xml);

            setup_model ();
        } catch (Dactl.ConfigError e) {
            error ("Configuration error: %s", e.message);
        }
    }

    /**
     * Some generic setup for the configuration components.
     */
    private void setup_model () {
        config.property_changed.connect (config_property_changed_cb);

        /* Property loading */
        admin = config.get_boolean_property ("admin");
        startup_page = config.get_string_property ("startup-page");
    }

    /**
     * Destruction occurs when object goes out of scope.
     * XXX deprecated since CLD task addition
     */
    ~ApplicationModel () {
        /* Stop hardware threads. */
        stop_acquisition ();
        stop_device_output ();
    }

    /**
     * Callback to handle configuration changes that could be done in different
     * pieces of the application.
     */
    private void config_property_changed_cb (string property) {
        message ("Property '%s' was changed.\n", property);
    }

    /**
     * Start the log file.
     * XXX should really have id as parameter
     */
     public void start_log () {
/*
 *        if (!(log as Cld.Log).active) {
 *            //(log as Cld.CsvLog).file_open ();
 *            (log as Cld.Log).start ();
 *
 *            message ("Started log %s", log.id);
 *            log_state_changed ((log as Cld.Log).id, true);
 *        }
 */
    }

    /**
     * Stop the log file.
     * XXX should really have id as parameter
     */
    public void stop_log () {
        /*
         *if ((log as Cld.Log).active) {
         *    (log as Cld.Log).stop ();
         *    if (log is Cld.CsvLog) {
         *        (log as Cld.CsvLog).file_mv_and_date (false);
         *    }
         *    message ("Stopped log %s", log.id);
         *    log_state_changed ((log as Cld.Log).id, false);
         *}
         */
    }

    /**
     * Start the thread that handles data acquisition.
     * XXX this is possibly more aptly placed in the controller
     */
    public void start_acquisition () {

        var devices = ctx.get_object_map (typeof (Cld.Device));
        foreach (var device in devices.values) {
            message ("Starting tasks for: `%s'", device.id);
            if (!(device as Cld.ComediDevice).is_open) {
                message ("  Opening Comedi Device: %s", device.id);
                (device as Cld.ComediDevice).open ();
                if (!(device as Cld.ComediDevice).is_open)
                    error ("Failed to open Comedi device: `%s'", device.id);
            }

            var tasks = (device as Cld.Container).get_object_map (typeof (Cld.Task));
            foreach (var task in tasks.values) {
                //if ((task as Cld.ComediTask).direction == "read") {
                    message ("  Starting task: `%s` ", task.id);
                    (task as Cld.ComediTask).run ();
                //}
            }
        }

        /* XXX should check that the task started properly */
        acquisition_state_changed (true);
    }

    /**
     * Stops the thread that handles data acquisition.
     * XXX this is possibly more aptly placed in the controller
     */
    public void stop_acquisition () {
        var devices = ctx.get_object_map (typeof (Cld.Device));
        foreach (var device in devices.values) {
            message ("Stopping tasks for: `%s'", device.id);
            var tasks = (device as Cld.Container).get_object_map (typeof (Cld.Task));
            foreach (var task in tasks.values) {
                if (task is Cld.ComediTask) {
                    //if ((task as Cld.ComediTask).direction == "read") {
                        message ("  Stopping task: `%s` ", task.id);
                        (task as Cld.ComediTask).stop ();
                    //}
                }
            }

            if ((device as Cld.ComediDevice).is_open) {
                message ("Closing Comedi Device: %s", device.id);
                (device as Cld.ComediDevice).close ();
                if ((device as Cld.ComediDevice).is_open)
                    error ("Failed to close Comedi device: %s", device.id);
            }
        }

        /* XXX should check that the task stopped properly */
        acquisition_state_changed (false);
    }

    /**
     * Starts the thread that handles output channels.
     */
    public void start_device_output () {
        var devices = ctx.get_object_map (typeof (Cld.Device));
        foreach (var device in devices.values) {
            if (!(device as Cld.ComediDevice).is_open) {
                message ("Opening Comedi Device: %s", device.id);
                (device as Cld.ComediDevice).open ();
            }

            if (!(device as Cld.ComediDevice).is_open)
                error ("Failed to open Comedi device: %s", device.id);

            foreach (var task in (device as Cld.Container).objects.values) {
                if (task is Cld.ComediTask) {
                    if ((task as Cld.ComediTask).direction == "write")
                        (task as Cld.ComediTask).run ();
                }
            }
        }
    }

    /**
     * Stops the thread that handles output channels.
     */
    public void stop_device_output () {
        var devices = ctx.get_object_map (typeof (Cld.Device));
        foreach (var device in devices.values) {
            message ("Stopping tasks for: %s", device.id);
            foreach (var task in (device as Cld.Container).objects.values) {
                if (task is Cld.ComediTask) {
                    if ((task as Cld.ComediTask).direction == "write") {
                        message ("  Stopping task: %s", task.id);
                        (task as Cld.ComediTask).stop ();
                    }
                }
            }
            /*
            (device as Cld.ComediDevice).close ();

            if ((device as Cld.ComediDevice).is_open) {
                GLib.message ("Failed to close Comedi device: %s", device.id);
            }
            */
        }
    }

    /**
     * {@inheritDoc}
     */
    public void update_objects (Gee.Map<string, Dactl.Object> val) {
        _objects = val;
    }

    /**
     * ...
     */
    /*
     *public Gee.Map<string, GLib.Object> get_object_map (Type type) {
     *    if (type.is_a (typeof (Dactl.Object))) {
     *        return (this as Dactl.Container).get_object_map (type);
     *    } else if (type.is_a (typeof (Cld.Object))) {
     *        return ctx.get_object_map (type);
     *    }
     *}
     */
}
