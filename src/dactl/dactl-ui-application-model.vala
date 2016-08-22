public class Dactl.UI.ApplicationModel : Dactl.ApplicationModel {

    private string _startup_page = "pg0";
    /**
     * Which page to load on startup
     */
    public string startup_page {
        get { return _startup_page; }
        set {
            _startup_page = value;
            config.set_string_property ("startup-page", value);
        }
    }

    private bool _dark_theme = true;
    /**
     * Whether or not to use the dark theme
     */
    public bool dark_theme {
        get { return _dark_theme; }
        set {
            _dark_theme = value;
            config.set_boolean_property ("dark-theme", value);
        }
    }

    public ApplicationModel (string config_filename) {
        base (config_filename);

        startup_page = config.get_string_property ("startup-page");
        dark_theme = config.get_boolean_property ("dark-theme");
    }
}
