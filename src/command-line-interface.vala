using Cld;
using Gee;

public class CommandLineInterface : GLib.Object {

    /**
     * The commands that are recognized.
     */
    public enum Command {
        NONE,
        CLD,
        CONFIG,
        CONTROL,
        HELP,
        LIST,
        LOG,
        READ,
        WRITE,
        QUIT;

        public string to_string () {
            switch (this) {
                case NONE:    return "none";
                case CLD:     return "cld";
                case CONFIG:  return "config";
                case CONTROL: return "control";
                case HELP:    return "help";
                case LIST:    return "list";
                case LOG:     return "log";
                case READ:    return "read";
                case WRITE:   return "write";
                case QUIT:    return "quit";
                default: assert_not_reached ();
            }
        }

        public string description () {
            switch (this) {
                case NONE:    return "No operation";
                case CLD:     return "Interface with the application CLD object tree";
                case CONFIG:  return "Perform an operation with the configuration";
                case CONTROL: return "Perform a control operation";
                case HELP:    return "Show the help for a command";
                case LIST:    return "List all available commands";
                case LOG:     return "Perform a logging operation";
                case READ:    return "Read one or more channels";
                case WRITE:   return "Write one or more channels";
                case QUIT:    return "Quit the command line interface";
                default: assert_not_reached ();
            }
        }

        public static Command[] all () {
            return {
                NONE,
                CLD,
                CONFIG,
                CONTROL,
                HELP,
                LIST,
                LOG,
                READ,
                WRITE,
                QUIT
            };
        }

        public static Command parse (string value) {
            try {
                var regex_none = new Regex ("none", RegexCompileFlags.CASELESS);
                var regex_cld = new Regex ("cld", RegexCompileFlags.CASELESS);
                var regex_config = new Regex ("c|cfg|config", RegexCompileFlags.CASELESS);
                var regex_control = new Regex ("ctl|control", RegexCompileFlags.CASELESS);
                var regex_help = new Regex ("h|help", RegexCompileFlags.CASELESS);
                var regex_list = new Regex ("ls|list", RegexCompileFlags.CASELESS);
                var regex_log = new Regex ("l|log", RegexCompileFlags.CASELESS);
                var regex_read = new Regex ("r|read", RegexCompileFlags.CASELESS);
                var regex_write = new Regex ("w|write", RegexCompileFlags.CASELESS);
                var regex_quit = new Regex ("q|quit", RegexCompileFlags.CASELESS);

                /**
                 * It feels inefficient doing this one at a time, but I can't
                 * come up with a better idea.
                 */
                if (regex_none.match (value)) {
                    return NONE;
                } else if (regex_cld.match (value)) {
                    return CLD;
                } else if (regex_config.match (value)) {
                    return CONFIG;
                } else if (regex_control.match (value)) {
                    return CONTROL;
                } else if (regex_help.match (value)) {
                    return HELP;
                } else if (regex_list.match (value)) {
                    return LIST;
                } else if (regex_log.match (value)) {
                    return LOG;
                } else if (regex_read.match (value)) {
                    return READ;
                } else if (regex_write.match (value)) {
                    return WRITE;
                } else if (regex_quit.match (value)) {
                    return QUIT;
                } else {
                    return NONE;
                }
            } catch (RegexError e) {
                message ("Command regex error: %s", e.message);
            }

            return NONE;
        }
    }

    /**
     * Whether or not the user selected administrative features.
     */
    public bool _admin = false;
    public bool admin {
        get { return _admin; }
        set { _admin = value; }
    }

    /**
     * Whether or not the cli is currently active.
     */
    private bool _active = false;
    public bool active {
        get { return _active; }
        set {
            /* Hopefully anyone using this cli would use the closed signal as
             * it's intended, but this is provided as an alternative. */
            //if (_active == true && value == false)
            //    stop ();
            _active = value;
        }
    }

    /**
     * Used when the command line interface has been stopped.
     */
    public signal void closed ();

    /**
     * XXX should make an enum for cld command requests
     *     some possibilities:
     *     - add, remove, query, set parameter, get parameter, dump
     */
    public signal void cld_request (string request);

    /**
     * XXX should make an enum for config command events
     */
    public signal void config_event (string event);

    /**
     * XXX should make an enum for control command events
     */
    public signal void control_event (string event, string id);

    /**
     * XXX should make an enum for log command events
     */
    public signal void log_event (string event, string id);

    /**
     * Used to read a single channel.
     */
    public virtual signal void read_channel (string id) {
        print_queued_results ();
    }

    /**
     * Used to read multiple channels.
     */
    public virtual signal void read_channels (string[] ids) {
        print_queued_results ();
    }

    /**
     * Used to write to a single channel.
     */
    public signal void write_channel (string id, double value);

    /**
     * Used to write to multiple channels.
     */
    public signal void write_channels (string[] ids, double[] values);

    /* Thread for command line loop execution */
    private unowned GLib.Thread<void *> thread;

    private GLib.Queue<string> results_queue = new GLib.Queue<string> ();

    public CommandLineInterface () { }

    public void run () {
        if (!GLib.Thread.supported ()) {
            critical ("Cannot run cli without thread support.");
            active = false;
            return;
        }

        if (!active) {
            try {
                active = true;
                thread = GLib.Thread.create<void *> (cli_thread, false);
            } catch (ThreadError e) {
                critical ("Thread error: %s", e.message);
                active = false;
                return;
            }
        }
    }

    public void stop () {
        if (active) {
            active = false;
            /* Let someone else deal with shutting down. */
            closed ();
        }
    }

    public void queue_result (string result) {
        results_queue.push_tail (result);
    }

    public void print_queued_results () {
        string item = null;
        while ((item = results_queue.pop_head ()) != null) {
            stdout.printf ("%s\n", item);
        }
    }

    public void * cli_thread () {
        string? args = "dummy";
        Command cmd = Command.NONE;

        do {
            stdout.printf (">>> ");
            args = stdin.read_line ();
            var tokens = args.split (" ");
            cmd = Command.parse (tokens[0]);

            switch (cmd) {
                case Command.NONE:
                    stdout.printf ("received: %s\n", cmd.to_string ());
                    break;
                case Command.CLD:
                    stdout.printf (" -- not implemented --\n");
                    cld_request ("empty");
                    break;
                case Command.CONFIG:
                    stdout.printf (" -- not implemented --\n");
                    config_event ("empty");
                    break;
                case Command.CONTROL:
                    stdout.printf (" -- not implemented --\n");
                    control_event ("empty", "pid0");
                    break;
                case Command.HELP:
                    stdout.printf (" -- not implemented --\n");
                    break;
                case Command.LIST:
                    foreach (var c in Command.all ()) {
                        if (c == Command.NONE)
                            continue;
                        stdout.printf (" > %s - %s\n", c.to_string (), c.description ());
                    }
                    break;
                case Command.LOG:
                    /* XXX would be better to drop into a new "log >" prompt */
                    if (tokens.length < 2)
                        stdout.printf ("usage: l|log start|stop\n");
                    else {
                        var op = tokens[1];
                        stdout.printf ("%sing logging\n", op);
                        /* XXX could consolidate these into a toggle_log */
                        if (op == "start")
                            log_event ("start", "log0");
                        else if (op == "stop")
                            log_event ("stop", "log0");
                        /* XXX should do an else*/
                    }
                    break;
                case Command.READ:
                    if (tokens.length < 2)
                        stdout.printf ("usage: r|read <id[,id,...]>\n");
                    else {
                        var channels = tokens[1].split (",");
                        if (channels.length < 2)
                            read_channel (channels[0]);
                        else
                            read_channels (channels);
                    }

                    //read_channels ({"ai00", "ai01"});
                    break;
                case Command.WRITE:
                    stdout.printf (" -- not implemented --\n");
                    write_channel ("ao00", 0.0);
                    //write_channels ({"ao00", "ao01"}, { 0.0, 0.0 });
                    break;
                case Command.QUIT:
                    stdout.printf ("shutting down\n");
                    break;
                default:
                    assert_not_reached ();
            }

        } while (cmd != Command.QUIT);

        stop ();

        return null;
    }
}
