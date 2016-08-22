/*
 * This file is a modified version taken from gnome-builder.
 */

public enum Dactl.LogLevel {
    LEVEL_TRACE = LogLevelFlags.LEVEL_DEBUG + 1;
}

public class Dactl.SysLog : GLib.Object {

    public static int verbosity { get; set; default = 0; }

    private static Once<Dactl.SysLog> _instance;

    private static LogFunc last_handler;

    private static GenericArray<IOChannel> channels;

    private delegate string LevelStrFunc (LogLevelFlags log_level);

    private static LevelStrFunc level_str_func;

    /**
     * Retrieves the task id for the current thread.
     */
    private static inline int get_thread () {
        return Linux.syscall (Linux.gettid ());
    }

    /**
     * Retrieves a log level as a string.
     *
     * @param log_level Log level flags
     *
     * @return A string which shouldn't be modified or freed.
     */
    private static string level_str (LogLevelFlags log_level) {
        switch ((ulong) log_level & LogLevelFlags.LEVEL_MASK) {
            case LogLevelFlags.LEVEL_ERROR:    return "   ERROR";
            case LogLevelFlags.LEVEL_CRITICAL: return "CRITICAL";
            case LogLevelFlags.LEVEL_WARNING:  return " WARNING";
            case LogLevelFlags.LEVEL_MESSAGE:  return " MESSAGE";
            case LogLevelFlags.LEVEL_INFO:     return "    INFO";
            case LogLevelFlags.LEVEL_DEBUG:    return "   DEBUG";
            case Dactl.LogLevel.LEVEL_TRACE:   return "   TRACE";

            default:
                return " UNKNOWN";
        }
    }

    /**
     * Retrieves a log  level as a term coloured string.
     *
     * @param log_level Log level flags
     *
     * @return A string which shouldn't be modified or freed.
     */
    private static string level_str_with_color (LogLevelFlags log_level) {
        switch ((ulong) log_level & LogLevelFlags.LEVEL_MASK) {
            case LogLevelFlags.LEVEL_ERROR:    return "   \033[1;31mERROR\033[0m";
            case LogLevelFlags.LEVEL_CRITICAL: return "\033[1;35mCRITICAL\033[0m";
            case LogLevelFlags.LEVEL_WARNING:  return " \033[1;33mWARNING\033[0m";
            case LogLevelFlags.LEVEL_MESSAGE:  return " \033[1;32mMESSAGE\033[0m";
            case LogLevelFlags.LEVEL_INFO:     return "    \033[1;32mINFO\033[0m";
            case LogLevelFlags.LEVEL_DEBUG:    return "   \033[1;32mDEBUG\033[0m";
            case Dactl.LogLevel.LEVEL_TRACE:   return "   \033[1;36mTRACE\033[0m";

            default:
                return " UNKNOWN";
        }
    }

    /**
     * Writes @message to @channel and flushes the channel.
     *
     * @param channel A #GLib.IOChannel.
     * @param message A string log message.
     */
    private static void write_to_channel (IOChannel channel, string message) {
        size_t bytes_written;
        try {
            channel.write_chars (message.to_utf8 (), out bytes_written);
        } catch (ConvertError e) {
            error ("Convert error: %s", e.message);
        } catch (IOChannelError e) {
            error ("IOChannel error: %s", e.message);
        }

        try {
            channel.flush ();
        } catch (IOChannelError e) {
            error ("IOChannel error: %s", e.message);
        }
    }

    /**
     * Default log handler dispatches messages to configured destinations.
     *
     * @param log_domain A string containing the log section
     * @param log_level Log level flags
     * @param message The log message
     */
    private static void log_handler (string?       log_domain,
                                     LogLevelFlags log_level,
                                     string        message) {
        TimeVal tv = TimeVal ();
        time_t t;
        Time tt;
        string level;
        char ftime[32];
        string buffer;

        if (GLib.likely (channels.length > 0)) {
            switch ((int) log_level) {
                case LogLevelFlags.LEVEL_MESSAGE:
                    if (verbosity < 1)
                        return;
                    break;
                case LogLevelFlags.LEVEL_INFO:
                    if (verbosity < 2)
                        return;
                    break;
                case LogLevelFlags.LEVEL_DEBUG:
                    if (verbosity < 3)
                        return;
                    break;
                case Dactl.LogLevel.LEVEL_TRACE:
                    if (verbosity < 4)
                        return;
                    break;
                default:
                    break;
            }
        }

        level = level_str_func (log_level);
        tv.get_current_time ();
        t = (time_t) tv.tv_sec;
        tt = Time.local (t);
        tt.strftime (ftime, "%H:%M:%S");
        buffer = "%s.%04ld  %30s[%d]: %s: %s\n".printf (
                    (string) ftime,
                    tv.tv_usec / 1000,
                    log_domain,
                    get_thread (),
                    level,
                    message);

        lock (channels) {
            channels.foreach ((channel) => {
                write_to_channel (channel, buffer);
            });
        }
    }

    /**
     * Instantiate singleton for logging subsystem.
     *
     * @return Instance of the logging subsystem.
     */
    public static unowned Dactl.SysLog get_default () {
        return _instance.once (() => { return new Dactl.SysLog (); });
    }

    /**
     * Initialize the logging subsystem.
     *
     * @param stdout Indicates that stdout should be used for logging.
     * @param filename Use an optional file to store logs.
     */
    public static void init (bool stdout, string? filename) {
        IOChannel channel = null;

        level_str_func = level_str;
        channels = new GenericArray<IOChannel> ();
        if (filename != null) {
            try {
                channel = new IOChannel.file (filename, "a");
                channels.add (channel);
            } catch (FileError e) {
                error ("File error: %s", e.message);
            }
        }
        if (stdout) {
            channel = new IOChannel.unix_new (Posix.STDOUT_FILENO);
            channels.add (channel);
            if ((filename == null) && Posix.isatty (Posix.STDOUT_FILENO))
                level_str_func = level_str_with_color;
        }

        GLib.Log.set_default_handler (log_handler);
    }

    /**
     * Cleans up after the logging subsystem.
     */
    public static void shutdown () {
        if (last_handler != null) {
            GLib.Log.set_default_handler (last_handler);
            last_handler = null;
        }
    }

    /**
     * Increases the amount of logging that will occur. By default only
     * warnings and above are displayed.
     *
     * Calling once will cause MESSAGE to be displayed.
     * Calling twice will cause INFO to be displayed.
     * Calling three times will cause DEBUG to be displayed.
     * Calling four times will cause TRACE to be displayed.
     *
     * This is meant to be called for every -v provided on the command line.
     */
    public static void increase_verbosity () {
        verbosity++;
    }
}
