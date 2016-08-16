public errordomain Dactl.ConfigurationError {
    NO_VALUE_SET,
    VALUE_OUT_OF_RANGE
}

public enum Dactl.ConfigurationFormat {
    OPTIONS,
    JSON,
    XML
}

public enum Dactl.ConfigurationEntry {
    NAME
}

/**
 * Interface for handling Dactl configuration.
 *
 * General concept taken from Rygel.
 */
public interface Dactl.Configuration : GLib.Object {

    public abstract Dactl.ConfigurationFormat format { get; set; }

    /**
     * Emitted when any known configuration setting has changed.
     */
    public signal void configuration_changed (Dactl.ConfigurationEntry entry);

    /**
     * Emitted when a custom setting has changed.
     */
    public signal void setting_changed (string ns, string key);

    /**
     * TODO fill me in
     */
    public abstract string get_string (string ns,
                                       string key) throws GLib.Error;

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
                                 string key,
                                 int min,
                                 int max) throws GLib.Error;

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
                                   string key) throws GLib.Error;

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
