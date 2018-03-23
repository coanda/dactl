public enum Dactl.TopbarPage {
    APPLICATION,
    SETTINGS
}

[GtkTemplate (ui = "/org/coanda/dactl/ui/topbar.ui")]
private class Dactl.Topbar : Gtk.Stack {

    private const string[] page_names = {
        "application", "loader", "configuration", "export", "settings"
    };

    [GtkChild]
    public Dactl.ApplicationToolbar application_toolbar;

    [GtkChild]
    public Dactl.LoaderToolbar loader_toolbar;

    [GtkChild]
    public Dactl.ConfigurationToolbar configuration_toolbar;

    [GtkChild]
    public Dactl.CsvExportToolbar export_toolbar;

    //[GtkChild]
    //public Dactl.SettingsToolbar settings_toolbar;

    construct {
        // FIXME: doesn't work from .ui file
        transition_type = Gtk.StackTransitionType.CROSSFADE;
        transition_duration = 400;
    }
}
