public errordomain Dactl.Net.ZmqError {
    INIT;
}

public abstract class Dactl.Net.ZmqService : GLib.Object {

    /**
     * Transport types that are available to ZeroMQ.
     */
    public enum Transport {
        INPROC,
        IPC,
        TCP,
        PGM;

        /**
         * Retrieve the text corresponding to the protocol value.
         *
         * @return String value representing the protocol value.
         */
        public string to_string () {
            switch (this) {
                case INPROC: return "inproc";
                case IPC:    return "ipc";
                case TCP:    return "tcp";
                case PGM:    return "pgm";
                default: assert_not_reached ();
            }
        }

        /**
         * Parse an input string for a ZeroMQ protocol to use.
         *
         * @param value String value to match.
         * @return Transport that matches value, INPROC if no match.
         */
        public static Transport parse (string value) {
            try {
                var regex_inproc = new Regex ("inproc", RegexCompileFlags.CASELESS);
                var regex_ipc = new Regex ("ipc", RegexCompileFlags.CASELESS);
                var regex_tcp = new Regex ("tcp", RegexCompileFlags.CASELESS);
                var regex_pgm = new Regex ("[e]pgm", RegexCompileFlags.CASELESS);

                if (regex_inproc.match (value)) {
                    return INPROC;
                } else if (regex_ipc.match (value)) {
                    return IPC;
                } else if (regex_tcp.match (value)) {
                    return TCP;
                } else if (regex_pgm.match (value)) {
                    return PGM;
                } else {
                    return INPROC;
                }
            } catch (RegexError e) {
                GLib.message ("ZMQ Service Transport regex error: %s", e.message);
            }

            return INPROC;
        }
    }

    protected ZMQ.Context context;

    protected ZMQ.Socket publisher;

    /**
     * Port number to use with the service.
     */
    public int port { get; construct set; default = 5556; }

    /**
     * Transport to use with the service.
     */
    public ZmqService.Transport transport { get; construct set; default = ZmqService.Transport.INPROC; }

    /**
     * Address to use with the service.
     */
    public string address { get; construct set; default = "*"; }

    public ZmqService () {
        try {
            zmq_init ();
        } catch (Dactl.Net.ZmqError e) {
            critical (e.message);
        }
    }

    public ZmqService.with_conn_info (ZmqService.Transport transport, string address, int port) {
        GLib.Object (transport: transport,
                     address: address,
                     port: port);
        try {
            zmq_init ();
        } catch (Dactl.Net.ZmqError e) {
            critical (e.message);
        }
    }

    protected void zmq_init () throws Dactl.Net.ZmqError {
        string endpoint = null;

        context = new ZMQ.Context ();
        publisher = ZMQ.Socket.create (context, ZMQ.SocketType.PUB);

        switch (transport) {
            case Transport.INPROC:
                endpoint = "%s://%s".printf (transport.to_string (), address);
                break;
            case Transport.IPC:
            case Transport.TCP:
            case Transport.PGM:
                endpoint = "%s://%s:%d".printf (transport.to_string (), address, port);
                break;
            default:
                assert_not_reached ();
        }

        debug ("Connect to %s", endpoint);

        var ret = publisher.bind (endpoint);
        assert (ret == 0);

        if (ret == -1) {
            throw new Dactl.Net.ZmqError.INIT (
                _("An error ocurred while binding to endpoint"));
        }
    }

    public abstract void run ();

    protected abstract async void listen () throws ThreadError;
}
