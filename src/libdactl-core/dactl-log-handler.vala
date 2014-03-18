/*
 * This file is a modified version taken from Rygel.
 */

using Gee;

public enum Dactl.LogLevel {
    INVALID = 0,
    CRITICAL = 1,
    ERROR = 2,
    WARNING = 3,
    INFO = 4,
    DEFAULT = 4,
    DEBUG = 5
}

public class Dactl.LogHandler : GLib.Object {
    private const string DEFAULT_LEVELS = "*:4";
    private const LogLevelFlags DEFAULT_FLAGS = LogLevelFlags.LEVEL_WARNING |
                                                LogLevelFlags.LEVEL_CRITICAL |
                                                LogLevelFlags.LEVEL_ERROR |
                                                LogLevelFlags.LEVEL_MESSAGE |
                                                LogLevelFlags.LEVEL_INFO;

    private HashMap<string,LogLevelFlags> log_level_hash;

    private static LogHandler log_handler; // Singleton

    public static LogHandler get_default () {
        if (log_handler == null) {
            log_handler = new LogHandler ();
        }

        return log_handler;
    }

    private LogHandler () {
        this.log_level_hash = new HashMap<string,LogLevelFlags> ();

        // Get the allowed log levels from the config
        //var config = MetaConfig.get_default ();
        string log_levels;

        //try {
            //log_levels = config.get_log_levels ();
        //} catch (Error err) {
            log_levels = DEFAULT_LEVELS;

            //warning (_("Failed to get log level from configuration: %s"),
                     //err.message);
        //}

        foreach (var pair in log_levels.split (",")) {
            var tokens = pair.split (":");
            if (tokens.length < 1) {
                break;
            }

            string domain;
            LogLevel level;

            if (tokens.length == 1) {
                level = (LogLevel) int.parse (tokens[0]);
                domain = "*";
            } else {
                domain = tokens[0];
                level = (LogLevel) int.parse (tokens[1]);
            }

            var flags = this.log_level_to_flags (level);

            this.log_level_hash[domain] = flags;
        }

        Log.set_default_handler (this.log_func);
    }

    private void log_func (string?       log_domain,
                           LogLevelFlags log_levels,
                           string        message) {
        LogLevelFlags flags = 0;

        if (log_domain != null) {
            flags = this.log_level_hash[log_domain];
        }

        if (flags == 0) {
            flags = this.log_level_hash["*"];
        }

        if (log_levels in flags) {
            // Forward the message to default domain
            Log.default_handler (log_domain, log_levels, message);
        }
    }

    private LogLevelFlags log_level_to_flags (LogLevel level) {
        LogLevelFlags flags = DEFAULT_FLAGS;

        switch (level) {
            case LogLevel.CRITICAL:
                flags = LogLevelFlags.LEVEL_CRITICAL;
                break;
            case LogLevel.ERROR:
                flags = LogLevelFlags.LEVEL_CRITICAL |
                        LogLevelFlags.LEVEL_ERROR;
                break;
            case LogLevel.WARNING:
                flags = LogLevelFlags.LEVEL_WARNING |
                        LogLevelFlags.LEVEL_CRITICAL |
                        LogLevelFlags.LEVEL_ERROR;
                break;
            case LogLevel.INFO:
                flags = LogLevelFlags.LEVEL_WARNING |
                        LogLevelFlags.LEVEL_CRITICAL |
                        LogLevelFlags.LEVEL_ERROR |
                        LogLevelFlags.LEVEL_MESSAGE |
                        LogLevelFlags.LEVEL_INFO;
                break;
            case LogLevel.DEBUG:
                flags = LogLevelFlags.LEVEL_WARNING |
                        LogLevelFlags.LEVEL_CRITICAL |
                        LogLevelFlags.LEVEL_ERROR |
                        LogLevelFlags.LEVEL_MESSAGE |
                        LogLevelFlags.LEVEL_INFO |
                        LogLevelFlags.LEVEL_DEBUG;
                break;
            default:
                flags = DEFAULT_FLAGS;
                break;
        }

        return flags;
    }
}
