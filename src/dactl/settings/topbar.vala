public enum Dactl.SettingsTopbarPage {
    SETTINGS
}

[GtkTemplate (ui = "/org/coanda/dactl/ui/settings-topbar.ui")]
private class Dactl.SettingsTopbar : Gtk.Stack {

    private const string[] page_names = {
        "settings"
    };

    [GtkChild]
    public Dactl.SettingsToolbar settings_toolbar;

    public signal void ok ();
    public signal void cancel ();

    construct {
        // FIXME: doesn't work from .ui file
        transition_type = Gtk.StackTransitionType.CROSSFADE;
        transition_duration = 400;
        settings_toolbar.ok.connect (do_ok);
        settings_toolbar.cancel.connect (do_cancel);
    }

    public void set_subtitle (string subtitle) {
      settings_toolbar.set_subtitle (subtitle);
    }

    private void do_ok () {
        ok ();
    }

    private void do_cancel () {
        cancel ();
    }
}
