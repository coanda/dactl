using Cld;
using Gee;

/**
 * Main application class responsible for interfacing with data and different
 * interface types.
 */
public class ApplicationModel : GLib.Object {

    public string xml_file { get; set; default = "dactl.xml"; }
    public bool active { get; set; default = false; }

    /* Allow administrative functionality */
    public bool admin { get; set; default = false; }

    /* Basic output verbosity, should use an integer to allow for -vvv */
    public bool verbose { get; set; default = false; }

    /* Configuration data */
    public ApplicationConfig config { get; private set; }

    /* CLD data */
    public Cld.XmlConfig xml { get; private set; }
    public Cld.Context ctx { get; private set; }
    public Cld.Task task { get; private set; }

    /* GSettings data */
    public Settings settings { get; private set; }

    /* Flag to set if user has set the calibrations to <default> */
    private bool _def_enabled = false;
    public bool def_enabled {
        get { return _def_enabled; }
        set { _def_enabled = value; }
    }

    /* Application specific classes. */
    private Gee.Map<string, Cld.Object> _channels;
    public Gee.Map<string, Cld.Object> channels {
        get {
            if (_channels == null) {
                _channels = new Gee.TreeMap<string, Cld.Object> ();
                _channels = ctx.get_object_map (typeof (Cld.Channel));
            }

            return _channels;
        }
        set { _channels = value; }
    }

    private Gee.Map<string, Cld.Object> _logs;
    public Gee.Map<string, Cld.Object> logs {

        get {
            if (_logs == null) {
                _logs = new Gee.TreeMap<string, Cld.Object> ();
                _logs = ctx.get_object_map (typeof (Cld.Log));
            }

            return _channels;
        }
        set { _logs = value; }
    }

    private Gee.Map<string, Cld.Object> _devices;
    public Gee.Map<string, Cld.Object> devices {
        get {
            if (_devices == null) {
                lock (ctx) {
                    _devices = new Gee.TreeMap<string, Cld.Object> ();
                    _devices = ctx.get_object_map (typeof (Cld.Device)); }
            }
            return _devices;
        }
        set { _devices = value; }
    }

    /* Analog input channel data
     * XXX this is only needed because it hasn't been implemented in CLD yet.
     */
    private Gee.Map<string, Cld.Object>? _ai_channels = null;
    public Gee.Map<string, Cld.Object>? ai_channels {
        get {
            if (_ai_channels == null) {
                lock (ctx) {
                    _ai_channels = new Gee.TreeMap<string, Cld.Object> ();
                    _ai_channels = ctx.get_object_map (typeof (Cld.AIChannel));
                }
            }
            return _ai_channels;
        }
        set { _ai_channels = value; }
    }

    /* Analog output channel data
     * XXX also only needed because it hasn't been implemented in CLD yet.
     */
    private Gee.Map<string, Cld.Object>? _ao_channels = null;
    public Gee.Map<string, Cld.Object>? ao_channels {
        get {
            if (_ao_channels == null) {
                lock (ctx) {
                    _ao_channels = new Gee.TreeMap<string, Cld.Object> ();
                    _ao_channels = ctx.get_object_map (typeof (Cld.AOChannel));
                }
            }
            return _ao_channels;
        }
        set { _ao_channels = value; }
    }

    /* Digital Input channel data
     * XXX also only needed because it hasn't been implemented in CLD yet.
     */
    private Gee.Map<string, Cld.Object>? _di_channels = null;
    public Gee.Map<string, Cld.Object>? di_channels {
        get {
            if (_di_channels == null) {
                lock (ctx) {
                    _di_channels = new Gee.TreeMap<string, Cld.Object> ();
                    _di_channels = ctx.get_object_map (typeof (Cld.DIChannel));
                }
            }
            return _di_channels;
        }
        set { _di_channels = value; }
    }

    /* Digital Output channel data
     * XXX also only needed because it hasn't been implemented in CLD yet.
     */
    private Gee.Map<string, Cld.Object>? _do_channels = null;
    public Gee.Map<string, Cld.Object>? do_channels {
        get {
            if (_do_channels == null) {
                lock (ctx) {
                    _do_channels = new Gee.TreeMap<string, Cld.Object> ();
                    _do_channels = ctx.get_object_map (typeof (Cld.DOChannel));
                }
            }
            return _do_channels;
        }
        set { _do_channels = value; }
    }

    /* Virtual channel data
     * XXX also only needed because it hasn't been implemented in CLD yet.
     */
    private Gee.Map<string, Cld.Object>? _vchannels = null;
    public Gee.Map<string, Cld.Object>? vchannels {
        get {
            if (_vchannels == null) {
                lock (ctx) {
                    _vchannels = new Gee.TreeMap<string, Cld.Object> ();
                    _vchannels = ctx.get_object_map (typeof (Cld.VChannel));
                }
            }
            return _vchannels;
        }
        set { _vchannels = value; }
    }

    /* Control loop data
     * XXX also only needed because it hasn't been implemented in CLD yet.
     */
    private Gee.Map<string, Cld.Object>? _control_loops = null;
    public Gee.Map<string, Cld.Object>? control_loops {
        get {
            if (_control_loops == null) {
                lock (ctx) {
                    _control_loops = new Gee.TreeMap<string, Cld.Object> ();
                    _control_loops = ctx.get_object_map (typeof (Cld.Pid));
                    _control_loops.set_all (ctx.get_object_map (typeof (Cld.Pid2)));
                }
            }
            return _control_loops;
        }
        set { _control_loops = value; }
    }

    /* Calibration data
     * XXX this one is actually in CLD, re-added by accident - could move later
     */
    private Gee.Map<string, Cld.Object>? _calibrations = null;
    public Gee.Map<string, Cld.Object>? calibrations {
        get {
            if (_calibrations == null) {
                lock (ctx) {
                    _calibrations = new Gee.TreeMap<string, Cld.Object> ();
                    _calibrations = ctx.get_object_map (typeof (Cld.Calibration));
                }
            }
            return _calibrations;
        }
        set { _calibrations = value; }
    }

    /* Module data
     * XXX should be in CLD.
     */
    private Gee.Map<string, Cld.Object>? _modules = null;
    public Gee.Map<string, Cld.Object> modules {
        get {
            if (_modules == null) {
                lock (ctx) {
                    _modules = new Gee.TreeMap<string, Cld.Object> ();
                    _modules = ctx.get_object_map (typeof (Cld.Module));
                }
            }
            return _modules;
        }
        set { _modules = value; }
    }

    /* DataSeries data
     * XXX also only needed because it hasn't been implemented in CLD yet.
     */
    private Gee.Map<string, Cld.Object>? _dataseries = null;
    public Gee.Map<string, Cld.Object>? dataseries {
        get {
            if (_dataseries == null) {
                lock (ctx) {
                    _dataseries = new Gee.TreeMap<string, Cld.Object> ();
                    _dataseries = ctx.get_object_map (typeof (Cld.DataSeries));
                }
            }
            return _dataseries;
        }
        set { _dataseries = value; }
    }



//    public Gee.Map<string, Cld.Log.Thread> log_threads = new Gee.TreeMap<string, Cld.Log.Thread> ();
//    public Cld.Log.Thread log_thread;
    public Cld.Log log;

    /**
     * Signals used primarily to inform the view that something in the
     * model was changed.
     */

    public signal void acquisition_state_changed (bool state);
    public signal void log_state_changed (string log, bool state);

    /**
     * Default construction.
     */
    public ApplicationModel () {
        config = new ApplicationConfig (xml_file);
        xml = new Cld.XmlConfig.from_node (config.get_xml_node ("//dactl/cld:objects"));
        ctx = new Cld.Context.from_config (xml);

        config.property_changed.connect (config_property_changed_cb);

        /* Read configuration settings to control application execution. */
        if (config.get_boolean_property ("launch-input-on-startup"))
            start_acquisition ();

        if (config.get_boolean_property ("launch-output-on-startup"))
            run_device_output ();

        /* XXX change for multiple log files */
        log = ctx.get_object ("log0") as Cld.Log;
        //Gee.Map<string, Cld.Object> logs = new Gee.TreeMap<string, Cld.Object> ();
        //logs = ctx.get_object_map (typeof (Cld.Log));
    }

    /**
     * Construction that loads configuration using the file name provided.
     */
    public ApplicationModel.with_xml_file (string xml_file) {
        this.xml_file = xml_file;

        if (!FileUtils.test (xml_file, FileTest.EXISTS)) {
            /* XXX might be better if somehow done after gui was launched
             *     so that a dialog could be given, or use conditional
             *     ApplicationModel construction */
            critical ("Configuration selection '%s' does not exist.", xml_file);
        }

        config = new ApplicationConfig (this.xml_file);
        xml = new Cld.XmlConfig.from_node (config.get_xml_node ("//dactl/cld/cld:objects"));
        ctx = new Cld.Context.from_config (xml);

        config.property_changed.connect (config_property_changed_cb);

        /* Read configuration settings to control application execution. */
        if (config.get_boolean_property ("launch-input-on-startup"))
            start_acquisition ();

        if (config.get_boolean_property ("launch-output-on-startup"))
            run_device_output ();
        /**
         * The velmex property needs to be set as it is referenced by the VelmexSettingsBox.
         * XXX It would be better if this was done automatically and only as required.
         */

        /** The licor property simailarily needs to be set and the channels assigned.
         * XXX This also should be done automatically as required by the particular configuration.
         **/

        /* XXX change for multiple log files */
        log = ctx.get_object ("log0") as Cld.Log;

        if (verbose)
            Cld.debug ("Context to string:\n%s\n", ctx.to_string_recursive ());
    }

    /**
     * Destruction occurs when object goes out of scope.
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
        Cld.debug ("Property '%s' was changed.\n", property);
    }

    /**
     * Start the log file.
     * XXX should really have id as parameter
     */
     public void start_log () {
        if (!(log as Cld.Log).active) {
//            (log as Cld.CsvLog).file_open ();
            (log as Cld.Log).start ();

            Cld.debug ("Started log %s", log.id);
            log_state_changed ((log as Cld.Log).id, true);
        }
    }

    /**
     * Stop the log file.
     * XXX should really have id as parameter
     */
    public void stop_log () {
        if ((log as Cld.Log).active) {
            (log as Cld.Log).stop ();
            if (log is Cld.CsvLog) {
                (log as Cld.CsvLog).file_mv_and_date (false);
            }
            Cld.debug ("Stopped log %s", log.id);
            log_state_changed ((log as Cld.Log).id, false);
        }
    }

    /**
     * Start the thread that handles data acquisition.
     * XXX this is possibly more aptly placed in the controller
     */
    public void start_acquisition () {
        foreach (var device in devices.values) {
            if (!(device as ComediDevice).is_open) {
                Cld.debug ("Opening Comedi Device: %s\n", device.id);
                (device as ComediDevice).open ();
            }

            if (!(device as ComediDevice).is_open)
                GLib.error ("Failed to open Comedi device: %s\n", device.id);

            foreach (var task in (device as Container).objects.values) {
                if (task is ComediTask) {
                    if ((task as ComediTask).direction == "read")
                        (task as ComediTask).run ();
                }
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

        foreach (var device in devices.values) {
            Cld.debug ("Stopping tasks for: %s\n", device.id);
            foreach (var task in (device as Container).objects.values) {
                if (task is ComediTask) {
                    if ((task as ComediTask).direction == "read") {
                        Cld.debug ("    Stopping task: %s\n ", task.id);
                        (task as ComediTask).stop ();
                    }
                }
            }
            /*
            if ((device as ComediDevice).is_open) {
                Cld.debug ("Closing Comedi Device: %s\n", device.id);
                (device as ComediDevice).close ();
            }

            if ((device as ComediDevice).is_open)
                GLib.error ("Failed to close Comedi device: %s\n", device.id);
            */
        }

        /* XXX should check that the task stopped properly */
        acquisition_state_changed (false);
    }

    /**
     * Starts the thread that handles output channels.
     */
    public void run_device_output () {
        foreach (var device in devices.values) {
            if (!(device as ComediDevice).is_open) {
                Cld.debug ("Opening Comedi Device: %s\n", device.id);
                (device as ComediDevice).open ();
            }

            if (!(device as ComediDevice).is_open)
                GLib.error ("Failed to open Comedi device: %s\n", device.id);

            foreach (var task in (device as Container).objects.values) {
                if (task is ComediTask) {
                    if ((task as ComediTask).direction == "write")
                        (task as ComediTask).run ();
                }
            }
        }
    }

    /**
     * Stops the thread that handles output channels.
     */
    public void stop_device_output () {
        foreach (var device in devices.values) {
            Cld.debug ("Stopping tasks for: %s\n", device.id);
            foreach (var task in (device as Container).objects.values) {
                if (task is ComediTask) {
                    if ((task as ComediTask).direction == "write") {
                        Cld.debug ("    Stopping task: %s\n", task.id);
                        (task as ComediTask).stop ();
                    }
                }
            }
            /*
            (device as ComediDevice).close ();

            if ((device as ComediDevice).is_open) {
                GLib.message ("Failed to close Comedi device: %s\n", device.id);
            }
            */
        }
    }

    /**
     * CommandLineInterface callbacks.
     */

    public void cli_cld_request_cb (string request) {
    }

    public void cli_config_event_cb (string event) {
    }

    public void cli_control_event_cb (string event, string id) {
    }

    public void cli_log_event_cb (string event, string id) {
        var log = builder.get_object (id);
        if (event == "start") {
            if (!(log as Cld.Log).active) {
                (log as Cld.Log).file_open ();
                (log as Cld.Log).run ();
            }
        } else if (event == "stop") {
            if ((log as Cld.Log).active) {
                (log as Cld.Log).stop ();
                (log as Cld.Log).file_close ();
            }
        }
    }

    public void cli_read_channel_cb (string id) {
        var channel = builder.get_object (id);
        cli.queue_result ("%s: %f".printf (id, (channel as Cld.AIChannel).scaled_value));
    }

    public void cli_read_channels_cb (string[] ids) {
        var channels = new Gee.TreeMap<string, Cld.Object> ();

        foreach (var id in ids) {
            var channel = builder.get_object (id);
            channels.set (channel.id, channel);
        }

        foreach (var channel in channels.values) {
            cli.queue_result ("%s: %f".printf (channel.id, (channel as Cld.AIChannel).scaled_value));
        }
    }

    public void cli_write_channel_cb (string id, double value) {
    }

    public void cli_write_channels_cb (string[] ids, double[] values) {
    }

    /**
     * Internal thread classes for hardware access.
     */
    public class AcquisitionThread {
        unowned ApplicationData data;
        //private ApplicationData data;

        /**
         * Construction
         */
        public AcquisitionThread (ApplicationData data) {
            this.data = data;
        }

        /**
         * Hands over control to the function that does the actual work.
         */
        public void * run () {
            acq_func (data);
            return null;
        }
    }

    /**
     * Simple thread class that contains data to use with the output device.
     */
    public class DeviceOutputThread {
        unowned ApplicationData data;

        /**
         * Construction
         */
        public DeviceOutputThread (ApplicationData data) {
            this.data = data;
        }

        /**
         * Hands over control to the function that does the actual work.
         */
        public void * run () {
            //write_func (data);
            return null;
        }
    }
}
