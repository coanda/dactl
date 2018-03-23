public abstract class Dactl.Net.ZmqClient : GLib.Object {

    protected ZMQ.Context context;

    protected ZMQ.Socket subscriber;

    /**
     * Port number to connect to.
     */
    public int port { get; construct set; default = 5000; }

    /**
     * Transport to connect over.
     */
    public Dactl.Net.ZmqTransport transport {
        get;
        construct set;
        default = Dactl.Net.ZmqTransport.INPROC;
    }

    /**
     * Address to use with the service.
     */
    public string address { get; construct set; default = "127.0.0.1"; }

    /**
     * Whether or not the client is connected to a server.
     */
    public bool is_connected { get; private set; default = false; }

    private string? _filter = null;
    /**
     * An optional filter to use to limit what's being received.
     */
    public string? filter {
        get { return _filter; }
        set {
            _filter = value;
            debug (_("Setting ZMQ subscription filter to: %s"), value);
            subscriber.setsockopt (ZMQ.SocketOption.SUBSCRIBE,
                                   filter,
                                   filter.length);
        }
    }

    public signal void data_received (uint8[] data);

    public ZmqClient () {
        try {
            zmq_init ();
        } catch (Dactl.Net.ZmqError e) {
            critical (e.message);
        }
    }

    public ZmqClient.with_conn_info (Dactl.Net.ZmqTransport transport,
                                     string address,
                                     int port) {
        GLib.Object (transport: transport,
                     address: address,
                     port: port);
        try {
            debug (" pre init");
            zmq_init ();
            debug ("post init");
        } catch (Dactl.Net.ZmqError e) {
            critical (e.message);
        }
    }

    protected void zmq_init () throws Dactl.Net.ZmqError {
        string endpoint = null;

        context = new ZMQ.Context ();
        subscriber = ZMQ.Socket.create (context, ZMQ.SocketType.SUB);

        switch (transport) {
            case ZmqTransport.INPROC:
                endpoint = "%s://%s".printf (transport.to_string (), address);
                break;
            case ZmqTransport.IPC:
            case ZmqTransport.TCP:
            case ZmqTransport.PGM:
                endpoint = "%s://%s:%d".printf (transport.to_string (),
                                                address,
                                                port);
                break;
            default:
                assert_not_reached ();
        }

        debug ("Connect to %s", endpoint);

        var ret = subscriber.connect (endpoint);

        if (ret == -1) {
            throw new Dactl.Net.ZmqError.INIT (
                _("An error ocurred while connecting to endpoint"));
        }

        is_connected = true;

        filter = "\"data\":";
        /*
         *if (filter != null) {
         *    subscriber.setsockopt (ZMQ.SocketOption.SUBSCRIBE,
         *                           filter,
         *                           filter.length);
         *}
         */
    }

    public abstract void run ();

    protected abstract async void watch () throws ThreadError;
}
