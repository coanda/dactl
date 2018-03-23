/**
 * Transport types that are available to ZeroMQ.
 */
public enum Dactl.Net.ZmqTransport {
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
    public static ZmqTransport parse (string value) {
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
