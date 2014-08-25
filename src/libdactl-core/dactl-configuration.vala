public errordomain Dactl.ConfigurationError {
    NO_VALUE_SET,
    VALUE_OUT_OF_RANGE
}

public enum Dactl.ConfigurationEntry {
    LOG_LEVELS
}

/**
 * Interface for handling Dactl configuration.
 *
 * General concept taken from Rygel.
 */
public interface Dactl.Configuration : GLib.Object {

    /**
     * Emitted when any known configuration setting has changed.
     */
    public signal void configuration_changed (Dactl.ConfigurationEntry entry);

    /**
     * Emitted when a custom setting has changed.
     */
    public signal void setting_changed (string ns, string key);

    public abstract string get_log_levels () throws GLib.Error;

    public abstract string get_plugin_path () throws GLib.Error;

    public abstract string get_string (string ns,
                                       string key) throws GLib.Error;

    public abstract Gee.ArrayList<string> get_string_list (string ns,
                                                           string key)
                                                           throws GLib.Error;

    /* XXX min and max are likely unnecessary for my needs, revisit */
    public abstract int get_int (string ns,
                                 string key,
                                 int min,
                                 int max) throws GLib.Error;

    public abstract Gee.ArrayList<int> get_int_list (string ns,
                                                     string key)
                                                     throws GLib.Error;

    public abstract bool get_bool (string ns,
                                   string key) throws GLib.Error;
}
