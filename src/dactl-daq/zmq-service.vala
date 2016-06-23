public errordomain Dactl.DAQ.ZmqError {
    INIT;
}

internal class Dactl.DAQ.ZmqService : GLib.Object {

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

    private ZMQ.Context context;

    private ZMQ.Socket publisher;

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
        } catch (Dactl.DAQ.ZmqError e) {
            critical (e.message);
        }
    }

    public ZmqService.with_conn_info (ZmqService.Transport transport, string address, int port) {
        GLib.Object (port: port,
                     transport: transport,
                     address: address);
        try {
            zmq_init ();
        } catch (Dactl.DAQ.ZmqError e) {
            critical (e.message);
        }
    }

    private void zmq_init () throws Dactl.DAQ.ZmqError {
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
            throw new Dactl.DAQ.ZmqError.INIT (
                _("An error ocurred while binding to endpoint"));
        }
    }

    public void run () {
        listen.begin ((obj, res) => {
            try {
                listen.end (res);
            } catch (ThreadError e) {
                error (e.message);
            }
        });
    }

    private async void listen () throws ThreadError {
        SourceFunc callback = listen.callback;

        ThreadFunc<void*> run = () => {
            try {
                var ntimes = 0;
                // XXX just here to do something
                while (true) {
                    string str = @"1000 nailed it! - $(ntimes)";
                    var reply = ZMQ.Msg.with_data (str.data);
                    var n = reply.send (publisher);
                    Posix.sleep (1);
                    ntimes++;
                }
            } catch (GLib.Error e) {
                error (e.message);
            }

            Idle.add ((owned) callback);
            return null;
        };

        Thread.create<void*> (run, false);
        yield;
    }
}
