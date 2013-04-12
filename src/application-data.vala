using Cld;
using Gee;
using Threads;

/**
 * This is all very plain for now just to get things going.
 */
public class ApplicationData : GLib.Object {

    public string xml_file { get; set; default = "cld.xml"; }
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
            } else {
                /* XXX should perform a clean shutdown of the interface - fix */
                _ui = null;
            }
        }
    }

    /* Application specific classes. */
    private UserInterfaceData _ui;
    public UserInterfaceData ui {
        get { return _ui; }
        set { _ui = value; }
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

    /* lists and maps of CLD data - ? still req'd ? */

    public ApplicationData () {
        xml = new Cld.XmlConfig.with_file_name (xml_file);
        builder = new Cld.Builder.from_xml_config (xml);

        /* This is very application specific, I hate doing this. */
        var port = builder.get_object ("ser0");
        licor = new Cld.LicorModule.full ("lm0", port as Cld.Port, vchannels);
        if (!licor.load ())
            message ("Failed to load the Licor module.");

//        create_log_threads ();
        /* XXX change for multiple log files */
        log = builder.get_object ("log0") as Cld.Log;
    }

    public ApplicationData.with_xml_file (string xml_file) {
        this.xml_file = xml_file;
        xml = new Cld.XmlConfig.with_file_name (this.xml_file);
        builder = new Cld.Builder.from_xml_config (xml);

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

/*
    private void create_log_threads () {
        foreach (var log in builder.logs.values) {
            Cld.Log.Thread log_thread = new Cld.Log.Thread (log);
            log_threads.set (log.id, log_thread);
        }
    }
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

    public void stop_acquisition () {
        if (_acq_active) {
            _acq_active = false;
            acq_thread.join ();
        }
    }

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

    public void stop_device_output () {
        if (_write_active) {
            _write_active = false;
            write_thread.join ();
        }
    }

    public class AcquisitionThread {
        unowned ApplicationData data;

        public AcquisitionThread (ApplicationData data) {
            this.data = data;
        }

        public void * run () {
            acq_func (data);
            return null;
        }
    }

    public class DeviceOutputThread {
        unowned ApplicationData data;

        public DeviceOutputThread (ApplicationData data) {
            this.data = data;
        }

        public void * run () {
            write_func (data);
            return null;
        }
    }
}
