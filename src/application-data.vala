using Cld;
using Gee;
using Threads;

/**
 * Main application class responsible for interfacing with data and different
 * interface types.
 */
public class ApplicationData : GLib.Object {

    public string xml_file { get; set; default = "dactl.xml"; }
    public bool active { get; set; default = false; }

    /* Control administrative functionality */
    public bool _admin = false;
    public bool admin {
        get { return _admin; }
        set{
            _admin = value;
            if (ui_enabled)
                ui.admin = value;
        }
    }

    /* Configuration data */
    public ApplicationConfig config { get; private set; }

    /* CLD data */
    public Cld.Builder builder { get; private set; }
    public Cld.XmlConfig xml { get; private set; }
    public Cld.Module licor { get; private set; }
    public Cld.Module velmex { get; private set; }

    /* GSettings data */
    public Settings settings { get; private set; }

    /* Flag to set if user requested a graphical interface. */
    private bool _ui_enabled = false;
    public bool ui_enabled {
        get { return _ui_enabled; }
        set {
            _ui_enabled = value;
            if (_ui_enabled) {
                _ui = new UserInterfaceData (this);
                _ui.admin = admin;
                //_ui.closed.connect ();
            } else {
                /* XXX should perform a clean shutdown of the interface - fix */
                _ui = null;
            }
        }
    }

    /* Flag to set if user requested a command line interface. */
    private bool _cli_enabled = false;
    public bool cli_enabled {
        get { return _cli_enabled; }
        set {
            _cli_enabled = value;
            if (_cli_enabled) {
                _cli = new CommandLineInterface ();
                _cli.admin = admin;
                _cli.cld_request.connect (cli_cld_request_cb);
                _cli.config_event.connect (cli_config_event_cb);
                _cli.control_event.connect (cli_control_event_cb);
                _cli.log_event.connect (cli_log_event_cb);
                _cli.read_channel.connect (cli_read_channel_cb);
                _cli.read_channels.connect (cli_read_channels_cb);
                _cli.write_channel.connect (cli_write_channel_cb);
                _cli.write_channels.connect (cli_write_channels_cb);
            } else {
                _cli = null;
            }
        }
    }

    /* Application specific classes. */

    private UserInterfaceData _ui;
    public UserInterfaceData ui {
        get { return _ui; }
        private set { _ui = value; }
    }

    private CommandLineInterface _cli;
    public CommandLineInterface cli {
        get { return _cli; }
        private set { _cli = value; }
    }

    private Gee.Map<string, Cld.Object> _channels;
    public Gee.Map<string, Cld.Object> channels {
        get { return builder.channels; }
        set { _channels = value; }
    }

    private Gee.Map<string, Cld.Object> _devices;
    public Gee.Map<string, Cld.Object> devices {
        get {
            lock (builder) {
                if (_devices == null) {
                    var daq = builder.default_daq;
                    _devices = new Gee.TreeMap<string, Cld.Object> ();
                    foreach (var object in daq.objects.values) {
                        if (object is Device)
                            _devices.set (object.id, object);
                    }
                }
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
            lock (builder) {
                if (_ai_channels == null) {
                    _ai_channels = new Gee.TreeMap<string, Cld.Object> ();
                    foreach (var channel in builder.channels.values) {
                        if (channel is AIChannel)
                            _ai_channels.set (channel.id, channel);
                    }
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
            lock (builder) {
                if (_ao_channels == null) {
                    _ao_channels = new Gee.TreeMap<string, Cld.Object> ();
                    foreach (var channel in builder.channels.values) {
                        if (channel is AOChannel)
                            _ao_channels.set (channel.id, channel);
                    }
                }
            }
            return _ao_channels;
        }
        set { _ao_channels = value; }
    }

    /* Virtual channel data
     * XXX also only needed because it hasn't been implemented in CLD yet.
     */
    private Gee.Map<string, Cld.Object>? _vchannels = null;
    public Gee.Map<string, Cld.Object>? vchannels {
        get {
            lock (builder) {
                if (_vchannels == null) {
                    _vchannels = new Gee.TreeMap<string, Cld.Object> ();
                    foreach (var channel in builder.channels.values) {
                        if (channel is VChannel)
                            _vchannels.set (channel.id, channel);
                    }
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
            lock (builder) {
                if (_control_loops == null) {
                    _control_loops = new Gee.TreeMap<string, Cld.Object> ();
                    foreach (var object in builder.objects.values) {
                        if (object is Cld.Control) {
                            foreach (var ctl_object in (object as Cld.Container).objects.values) {
                                if (ctl_object is Cld.Pid)
                                    _control_loops.set (ctl_object.id, ctl_object);
                            }
                        }
                    }
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
            lock (builder) {
                if (_calibrations == null) {
                    _calibrations = new Gee.TreeMap<string, Cld.Object> ();
                    foreach (var calibration in builder.objects.values) {
                        if (calibration is Cld.Calibration) {
                            _calibrations.set (calibration.id, calibration);
                        }
                    }
                }
            }
            return _calibrations;
        }
        set { _calibrations = value; }
    }

//    public Gee.Map<string, Cld.Log.Thread> log_threads = new Gee.TreeMap<string, Cld.Log.Thread> ();
    public Cld.Log.Thread log_thread;
    public Cld.Log log;

    /**
     * Internal thread data for acquisition. Still considering doing this using
     * a HashMap so that one thread per device could be done.
     */
    private bool _acq_active = false;
    public bool acq_active {
        get { return _acq_active; }
        set { _acq_active = value; }
    }

    private unowned Thread<void *> acq_thread;
    //private Mutex acq_mutex = new Mutex ();

    /**
     * Internal thread data for output on device. Again, one thread per device
     * would be the ideal.
     */
    private bool _write_active = false;
    public bool write_active {
        get { return _write_active; }
        set { _write_active = value; }
    }

    private unowned Thread<void *> write_thread;
    //private Mutex write_mutex = new Mutex ();

    /**
     * Default construction.
     */
    public ApplicationData () {
        config = new ApplicationConfig (xml_file);
        xml = new Cld.XmlConfig.from_node (config.get_xml_node ("//dactl/cld:objects"));
        builder = new Cld.Builder.from_xml_config (xml);

        config.property_changed.connect (config_property_changed_cb);

        /* Read configuration settings to control application execution. */
        if (config.get_boolean_property ("launch-input-on-startup"))
            run_acquisition ();

        if (config.get_boolean_property ("launch-output-on-startup"))
            run_device_output ();

        /* This is very application specific, I hate doing this. */
        var port = builder.get_object ("ser0");
        licor = new Cld.LicorModule.full ("lm0", port as Cld.Port, vchannels);
        if (!licor.load ())
            message ("Failed to load the Licor module.");

//        create_log_threads ();
        /* XXX change for multiple log files */
        log = builder.get_object ("log0") as Cld.Log;
    }

    /**
     * Construction that loads configuration using the file name provided.
     */
    public ApplicationData.with_xml_file (string xml_file) {
        this.xml_file = xml_file;

        if (!FileUtils.test (xml_file, FileTest.EXISTS)) {
            /* XXX might be better if somehow done after gui was launched
             *     so that a dialog could be given, or use conditional
             *     ApplicationData construction */
            critical ("Configuration selection '%s' does not exist.", xml_file);
        }

        config = new ApplicationConfig (this.xml_file);
        xml = new Cld.XmlConfig.from_node (config.get_xml_node ("//dactl/cld:objects"));
        builder = new Cld.Builder.from_xml_config (xml);

        config.property_changed.connect (config_property_changed_cb);

        /* Read configuration settings to control application execution. */
        if (config.get_boolean_property ("launch-input-on-startup"))
            run_acquisition ();

        if (config.get_boolean_property ("launch-output-on-startup"))
            run_device_output ();

        /* XXX this is very application specific, I hate doing this. */
//        var port = builder.get_object ("ser0");
        var licor_port = new Cld.SerialPort ();
        licor_port.id = "ser0";
        licor_port.device = "/dev/ttyS1";
        licor_port.baud_rate = 115200;
        licor_port.handshake = Cld.SerialPort.Handshake.HARDWARE;

//        licor = new Cld.LicorModule.full ("lm0", port as Cld.Port, vchannels);
        licor = new Cld.LicorModule ();
        licor.id = "lm0";
        (licor as LicorModule).port = licor_port;
        (licor as LicorModule).channels = vchannels;

//        var port = builder.get_object ("ser1");
        var velmex_port = new Cld.SerialPort ();
        velmex_port.id = "ser1";
        velmex_port.device = "/dev/ttyS2";
        velmex_port.baud_rate = 9600;
        velmex_port.handshake = Cld.SerialPort.Handshake.HARDWARE;

        velmex = new Cld.VelmexModule ();
        velmex.id = "vm0";
        (velmex as VelmexModule).port = velmex_port;

//        create_log_threads ();
        /* XXX change for multiple log files */
        log = builder.get_object ("log0") as Cld.Log;
    }

    /**
     * Destruction occurs when object goes out of scope.
     */
    ~ApplicationData () {
        /* Stop hardware threads. */
        stop_acquisition ();
        stop_device_output ();
    }

/*
    private void create_log_threads () {
        foreach (var log in builder.logs.values) {
            Cld.Log.Thread log_thread = new Cld.Log.Thread (log);
            log_threads.set (log.id, log_thread);
        }
    }
*/

    /**
     * Callback to handle configuration changes that could be done in different
     * pieces of the application.
     */
    private void config_property_changed_cb (string property) {
        message ("Property '%s' was changed.", property);
    }

    /**
     * Start the thread that handles data acquisition.
     */
    public void run_acquisition () {
        if (!Thread.supported ()) {
            stderr.printf ("Cannot run acquisition without thread support.\n");
            _acq_active = false;
            return;
        }

        if (!_acq_active) {
            var acq_thread_data = new AcquisitionThread (this);

            try {
                _acq_active = true;
                /* TODO create is deprecated, check compiler warnings */
                acq_thread = Thread.create<void *> (acq_thread_data.run, true);
            } catch (ThreadError e) {
                stderr.printf ("%s\n", e.message);
                _acq_active = false;
                return;
            }
        }
    }

    /**
     * Stops the thread that handles data acquisition.
     */
    public void stop_acquisition () {
        if (_acq_active) {
            _acq_active = false;
            acq_thread.join ();
        }
    }

    /**
     * Starts the thread that handles output channels.
     */
    public void run_device_output () {
        if (!Thread.supported ()) {
            stderr.printf ("Cannot run device output without thread support.\n");
            _write_active = false;
            return;
        }

        if (!_write_active) {
            var write_thread_data = new DeviceOutputThread (this);

            try {
                _write_active = true;
                /* TODO create is deprecated, check compiler warnings */
                write_thread = Thread.create<void *> (write_thread_data.run, true);
            } catch (ThreadError e) {
                stderr.printf ("%s\n", e.message);
                _write_active = false;
                return;
            }
        }
    }

    /**
     * Stops the thread that handles output channels.
     */
    public void stop_device_output () {
        if (_write_active) {
            _write_active = false;
            write_thread.join ();
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
                (log as Cld.Log).file_mv_and_date (false);
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
            write_func (data);
            return null;
        }
    }
}
