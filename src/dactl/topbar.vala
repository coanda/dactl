public enum Dactl.TopbarPage {
    APPLICATION,
    SETTINGS
}

[GtkTemplate (ui = "/org/coanda/dactl/ui/topbar.ui")]
private class Dactl.Topbar : Gtk.Stack {

    private const string[] page_names = {
        "application", "loader", "configuration", "settings"
    };

    [GtkChild]
    public Dactl.ApplicationToolbar application_toolbar;

    construct {
        // FIXME: doesn't work from .ui file
        transition_type = Gtk.StackTransitionType.CROSSFADE;
        transition_duration = 400;
    }
}
