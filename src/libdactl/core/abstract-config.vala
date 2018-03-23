public abstract class Dactl.AbstractConfig : GLib.Object, Dactl.Configuration {

    public Dactl.ConfigFormat format { get; set; }

    /**
     * {@inheritDoc}
     */
    public virtual string get_string (string ns,
                                      string key)
                                      throws GLib.Error {
		string value = null;

        if (value != null) {
            return value;
        } else {
            throw new ConfigError.NO_VALUE_SET (_("No value available"));
		}
    }

    /**
     * {@inheritDoc}
     */
    public virtual Gee.ArrayList<string> get_string_list (string ns,
                                                          string key)
                                                          throws GLib.Error {
        Gee.ArrayList<string> value = null;

        if (value != null) {
            return value;
        } else {
            throw new ConfigError.NO_VALUE_SET (_("No value available"));
		}
    }

    /**
     * {@inheritDoc}
     */
    public virtual int get_int (string ns,
                                string key)
                                throws GLib.Error {
		int value = 0;
		bool value_set = false;

        if (value_set) {
            return value;
        } else {
            throw new ConfigError.NO_VALUE_SET (_("No value available"));
		}
    }

    /**
     * {@inheritDoc}
     */
    public virtual Gee.ArrayList<int> get_int_list (string ns,
                                                    string key)
                                                    throws GLib.Error {
        Gee.ArrayList<int> value = null;

        if (value != null) {
            return value;
        } else {
            throw new ConfigError.NO_VALUE_SET (_("No value available"));
		}
    }

    /**
     * {@inheritDoc}
     */
    public virtual bool get_bool (string ns,
                                  string key)
                                  throws GLib.Error {
		bool value = false;
		bool value_set = false;

        if (value_set) {
            return value;
        } else {
            throw new ConfigError.NO_VALUE_SET (_("No value available"));
		}
    }
}
