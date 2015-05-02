public enum Dactl.SettingsStackPage {
    GENERAL,
    ACQUISITION,
    CONTROL,
    LOG,
    PLUGIN,
    NONE;

    public string to_string () {
        switch (this) {
            case GENERAL:     return "general";
            case ACQUISITION: return "acquisition";
            case CONTROL:     return "control";
            case LOG:         return "log";
            case PLUGIN:      return "plugin";
            default: assert_not_reached ();
        }
    }

    public static SettingsStackPage[] all () {
        return { GENERAL, ACQUISITION, CONTROL, LOG, PLUGIN };
    }
}

[GtkTemplate (ui = "/org/coanda/dactl/ui/settings.ui")]
public class Dactl.Settings : Gtk.Stack {

    [GtkChild]
    public Dactl.GeneralSettings general;

    [GtkChild]
    public Dactl.AcquisitionSettings acquisition;

    [GtkChild]
    public Dactl.ControlSettings control;

    [GtkChild]
    public Dactl.LogSettings log;

    [GtkChild]
    private Dactl.PluginSettings plugin;

    public Dactl.SettingsStackPage page { get; set; }

    construct {
        notify["page"].connect (page_changed_cb);

        transition_type = Gtk.StackTransitionType.SLIDE_UP_DOWN;
        transition_duration = 400;
    }

    private void page_changed_cb () {
        visible_child_name = page.to_string ();

        /* XXX don't have much reason to check page yet, probably will though */
        switch (page) {
            case Dactl.SettingsStackPage.GENERAL:
                break;
            case Dactl.SettingsStackPage.ACQUISITION:
                break;
            case Dactl.SettingsStackPage.CONTROL:
                break;
            case Dactl.SettingsStackPage.LOG:
                break;
            case Dactl.SettingsStackPage.PLUGIN:
                break;
            default:
                break;
        }
    }
}
