/**
 * Main application class responsible for interfacing with data and different
 * interface types.
 */
public class Dactl.ApplicationModel : GLib.Object, Dactl.Container {

    private string _name = "Untitled";
    /**
     * A name for the configuration
     */
    public string name {
        get { return _name; }
        set {
            _name = value;
            lock (config) {
                config.set_string_property ("app", value);
            }
        }
    }

    private bool _admin = false;
    /**
     * Allow administrative functionality
     */
    public bool admin {
        get { return _admin; }
        set {
            _admin = value;
            lock (config) {
                config.set_boolean_property ("admin", value);
            }
        }
    }

    private bool _def_enabled = false;
    /**
     * Flag to set if user has set the calibrations to <default>
     */
    public bool def_enabled {
        get { return _def_enabled; }
        set { _def_enabled = value; }
    }

    private Gee.Map<string, Dactl.Object> _objects;
    /**
     * {@inheritDoc}
     */
    public Gee.Map<string, Dactl.Object> objects {
        get { return (_objects); }
        set { update_objects (value); }
    }

    /**
     * Default configuration file name.
     */
    public string config_filename { get; set; default = "dactl.xml"; }

    /**
     * Flag indicating thread activity... I think.
     * XXX pretty sure this isn't being used anymore.
     */
    public bool active { get; set; default = false; }

    /* Basic output verbosity, should use an integer to allow for -vvv */
    public bool verbose { get; set; default = false; }

    /* Application data */
    public Dactl.ApplicationConfig config { get; private set; }

    /* CLD data */
    public Cld.XmlConfig xml { get; private set; }
    public Cld.Context ctx { get; private set; }

    /* GSettings data */
    public Settings settings { get; private set; }

    /**
     * Emitted whenever the state of a log has been changed.
     * XXX not sure this is used anymore
     */
    public signal void log_state_changed (string log, bool state);

    /**
     * Default construction.
     */
    public ApplicationModel (string config_filename) {
        this.config_filename = config_filename;

        if (!FileUtils.test (config_filename, FileTest.EXISTS)) {
            /* XXX might be better if somehow done after gui was launched
             *     so that a dialog could be given, or use conditional
             *     ApplicationModel construction */
            critical ("Configuration selection '%s' does not exist.",
                      config_filename);
        }

        /* Load the entire application configuration file */
        config = new Dactl.ApplicationConfig (this.config_filename);

        var factory = Dactl.ApplicationFactory.get_default ();

        /* Get the nodeset to use from the configuration */
        try {
            Xml.Node *node = config.get_xml_node ("/dactl/ui:objects/ui:object");
            objects = factory.make_object_map (node);
        } catch (Dactl.FactoryError e) {
            GLib.error (e.message);
        }

        /* Load the CLD specific configuration and builder */
        try {
            Xml.Node *node = config.get_xml_node ("/dactl/cld:objects");
            xml = new Cld.XmlConfig.from_node (node);
            ctx = new Cld.Context.from_config (xml);
        } catch (Dactl.ConfigError e) {
            GLib.error (e.message);
        }

        setup_model ();
    }

    /**
     * Some generic setup for the configuration components.
     */
    private void setup_model () {
        config.property_changed.connect (config_property_changed_cb);

        /* Property loading */
        name = config.get_string_property ("app");
        admin = config.get_boolean_property ("admin");
    }

    /**
     * Callback to handle configuration changes that could be done in different
     * pieces of the application.
     */
    private void config_property_changed_cb (string property) {
        //message ("Property '%s' was changed.\n", property);
    }

    /**
     * {@inheritDoc}
     */
    public void update_objects (Gee.Map<string, Dactl.Object> val) {
        _objects = val;
    }
}
