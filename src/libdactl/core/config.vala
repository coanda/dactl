public errordomain Dactl.ConfigError {
    FILE_NOT_FOUND,
    NO_VALUE_SET,
    VALUE_OUT_OF_RANGE,
    INVALID_KEY,
    INVALID_XPATH_EXPR,
    XML_DOCUMENT_EMPTY
}

public enum Dactl.ConfigFormat {
    OPTIONS,
    JSON,
    XML
}

public enum Dactl.ConfigEntry {
    NAME
}

/**
 * Interface for handling Dactl configuration.
 */
public interface Dactl.Configuration : GLib.Object {

    public abstract Dactl.ConfigFormat format { get; set; }

    /**
     * Emitted when any known configuration setting has changed.
     */
    public signal void config_changed (Dactl.ConfigEntry entry);

    /**
     * Emitted when a custom setting has changed.
     */
    public signal void setting_changed (string ns, string key);

    /**
     * TODO fill me in
     */
    public abstract string get_string (string ns,
                                       string key)
                                       throws GLib.Error;

    /**
     * TODO fill me in
     */
    public abstract Gee.ArrayList<string> get_string_list (string ns,
                                                           string key)
                                                           throws GLib.Error;

    /**
     * TODO fill me in
     */
    public abstract int get_int (string ns,
                                 string key)
                                 throws GLib.Error;

    /**
     * TODO fill me in
     */
    public abstract Gee.ArrayList<int> get_int_list (string ns,
                                                     string key)
                                                     throws GLib.Error;

    /**
     * TODO fill me in
     */
    public abstract bool get_bool (string ns,
                                   string key)
                                   throws GLib.Error;

/*
 *    public abstract float get_float (string ns,
 *                                     string key) throws GLib.Error;
 *
 *    public abstract double get_double (string ns,
 *                                       string key) throws GLib.Error;
 *
 *    public abstract void set_string (string ns,
 *                                     string key,
 *                                     string value) throws GLib.Error;
 *
 *    public abstract void set_int (string ns,
 *                                  string key,
 *                                  int value) throws GLib.Error;
 *
 *    public abstract void set_bool (string ns,
 *                                   string key,
 *                                   bool value) throws GLib.Error;
 *
 *    public abstract void set_float (string ns,
 *                                    string key,
 *                                    float value) throws GLib.Error;
 *
 *    public abstract void set_double (string ns,
 *                                     string key,
 *                                     double value) throws GLib.Error;
 */
}
