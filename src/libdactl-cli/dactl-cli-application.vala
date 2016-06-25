public class Dactl.CLI.Application : GLib.Application, Dactl.Application {

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
                GLib.message ("Command regex error: %s", e.message);
            }

            return NONE;
        }
    }

    private static Once<Dactl.CLI.Application> _instance;

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
     * {@inheritDoc}
     */
    public virtual Gee.ArrayList<Dactl.Plugin> plugins { get; set; }

    /**
     * Used when the user requests a configuration save.
     */
    public signal void save_requested ();

    /**
     * Instantiate a new command line application.
     *
     * @return Instance of the application.
     */
    /*
     *public static unowned Dactl.CLI.Application get_default () {
     *    return _instance.once (() => {
     *        return new Dactl.CLI.Application ();
     *    });
     *}
     */

    internal Application () {
        debug ("CLI application construction");

        GLib.Object (application_id: "org.coanda.dactl.cli",
                     flags: ApplicationFlags.HANDLES_COMMAND_LINE |
                            ApplicationFlags.HANDLES_OPEN);

        plugins = new Gee.ArrayList<Dactl.Plugin> ();
    }

    /**
     * {@inheritDoc}
     */
    public void register_plugin (Dactl.Plugin plugin) {
        //if (plugin.has_factory) { }
    }

    /**
     * {@inheritDoc}
     */
    public virtual int launch (string[] args) {
        return (this as GLib.Application).run (args);
    }
}
