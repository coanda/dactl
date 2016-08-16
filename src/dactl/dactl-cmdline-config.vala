public errordomain Dactl.CmdlineConfigError {
    VERSION_ONLY
}

public class Dactl.CmdlineConfig : GLib.Object, Dactl.Configuration {

    public Dactl.ConfigurationFormat format { get; set; default = Dactl.ConfigurationFormat.OPTIONS; }

    private static string log_levels;

    private static bool version;

    private static string plugin_path;

    private static string config_file;

    private static bool replace;

    /* Singleton */
    private static Dactl.CmdlineConfig config;

    const OptionEntry[] options = {
        { "version", 0, 0, OptionArg.NONE, ref version,
          "Display version number", null },
        { "log-level", 'g', 0, OptionArg.STRING, ref log_levels,
          N_ ("Comma-separated list of domain:level pairs. See dactl(1) for details") },
        { "plugin-path", 'u', 0, OptionArg.STRING, ref plugin_path,
          N_ ("Plugin Path"), "PLUGIN_PATH" },
        { "config", 'c', 0, OptionArg.FILENAME, ref config_file,
          N_ ("Use configuration file instead of user configuration"), "FILE" },
        { "replace", 'r', 0, OptionArg.NONE, ref replace,
          N_ ("Replace currently running instance of dactl"), null },
        { null }
    };

    public static CmdlineConfig get_default () {
        if (config == null) {
            config = new Dactl.CmdlineConfig ();
        }
        return config;
    }

    public static void parse_args (ref unowned string[] args)
                                   throws CmdlineConfigError.VERSION_ONLY,
                                          OptionError {
        var parameter_string = "- " + Config.PACKAGE_NAME;
        var opt_context = new OptionContext (parameter_string);
        opt_context.set_help_enabled (true);
        opt_context.set_ignore_unknown_options (true);
        opt_context.add_main_entries (options, null);

        try {
            opt_context.parse (ref args);
        } catch (OptionError.BAD_VALUE err) {
            stdout.printf (opt_context.get_help (true, null));

            throw new CmdlineConfigError.VERSION_ONLY ("");
        }

        if (version) {
            stdout.printf ("%s\n", Config.PACKAGE_STRING);

            throw new CmdlineConfigError.VERSION_ONLY ("");
        }
    }

    public string get_log_levels () throws GLib.Error {
        if (log_levels == null) {
            throw new ConfigurationError.NO_VALUE_SET (_("No value available"));
        }

        return log_levels;
    }

    public string get_plugin_path () throws GLib.Error {
        if (plugin_path == null) {
            throw new ConfigurationError.NO_VALUE_SET ("No value available");
        }

        return plugin_path;
    }

    public string get_config_file () throws GLib.Error {
        if (config_file == null) {
            throw new ConfigurationError.NO_VALUE_SET (_("No value available"));
        }

        return config_file;
    }

    public string get_string (string ns,
                              string key) throws GLib.Error {
        string value = null;
        /*
         *foreach (var option in plugin_options) {
         *    var tokens = option.split (":", 3);
         *    if (tokens[0] != null &&
         *        tokens[1] != null &&
         *        tokens[2] != null &&
         *        tokens[0] == section &&
         *        tokens[1] == key) {
         *        value = tokens[2];
         *        break;
         *    }
         *}
         */

        if (value != null) {
            return value;
        } else {
            throw new ConfigurationError.NO_VALUE_SET (_("No value available"));
        }
    }

    public Gee.ArrayList<string> get_string_list (string ns,
                                                  string key)
                                                  throws GLib.Error {
        Gee.ArrayList<string> value = null;
        /*
         *foreach (var option in plugin_options) {
         *    var tokens = option.split (":", 3);
         *    if (tokens[0] != null &&
         *        tokens[1] != null &&
         *        tokens[2] != null &&
         *        tokens[0] == section &&
         *        tokens[1] == key) {
         *        value = new ArrayList<string> ();
         *        foreach (var val_token in tokens[2].split (",", -1)) {
         *            value.add (val_token);
         *        }
         *        break;
         *    }
         *}
         */

        if (value != null) {
            return value;
        } else {
            throw new ConfigurationError.NO_VALUE_SET (_("No value available"));
        }
    }

    public int get_int (string ns,
                        string key,
                        int    min,
                        int    max)
                        throws GLib.Error {
        int value = 0;
        bool value_set = false;
        /*
         *foreach (var option in plugin_options) {
         *    var tokens = option.split (":", 3);
         *    if (tokens[0] != null &&
         *        tokens[1] != null &&
         *        tokens[2] != null &&
         *        tokens[0] == section &&
         *        tokens[1] == key) {
         *        value = int.parse (tokens[2]);
         *        if (value >= min && value <= max) {
         *            value_set = true;
         *        }
         *        break;
         *    }
         *}
         */

        if (value_set) {
            return value;
        } else {
            throw new ConfigurationError.NO_VALUE_SET (_("No value available"));
        }
    }

    public Gee.ArrayList<int> get_int_list (string ns,
                                            string key)
                                            throws GLib.Error {
        Gee.ArrayList<int> value = null;
        /*
         *foreach (var option in plugin_options) {
         *    var tokens = option.split (":", 3);
         *    if (tokens[0] != null &&
         *        tokens[1] != null &&
         *        tokens[2] != null &&
         *        tokens[0] == section &&
         *        tokens[1] == key) {
         *        value = new ArrayList<int> ();
         *        foreach (var val_token in tokens[2].split (",", -1)) {
         *            value.add (int.parse (val_token));
         *        }
         *        break;
         *    }
         *}
         */

        if (value != null) {
            return value;
        } else {
            throw new ConfigurationError.NO_VALUE_SET (_("No value available"));
        }
    }

    public bool get_bool (string ns,
                          string key)
                          throws GLib.Error {
        bool value = false;
        bool value_set = false;
        /*
         *foreach (var option in plugin_options) {
         *    var tokens = option.split (":", 3);
         *    if (tokens[0] != null &&
         *        tokens[1] != null &&
         *        tokens[2] != null &&
         *        tokens[0] == section &&
         *        tokens[1] == key) {
         *        value = bool.parse (tokens[2]);
         *        value_set = true;
         *        break;
         *    }
         *}
         */

        if (value_set) {
            return value;
        } else {
            throw new ConfigurationError.NO_VALUE_SET (_("No value available"));
        }
    }
}
