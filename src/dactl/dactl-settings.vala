public enum Dactl.SettingsPage {
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

    public static SettingsPage[] all () {
        return { GENERAL, ACQUISITION, CONTROL, LOG, PLUGIN };
    }
}

[GtkTemplate (ui = "/org/coanda/dactl/ui/settings.ui")]
public class Dactl.Settings : Gtk.Stack {

    [GtkChild]
    private Dactl.GeneralSettings general;

    [GtkChild]
    private Dactl.AcquisitionSettings acquisition;

    [GtkChild]
    private Dactl.ControlSettings control;

    [GtkChild]
    private Dactl.LogSettings log;

    [GtkChild]
    private Dactl.PluginSettings plugin;

    public Dactl.SettingsPage page { get; set; }

    construct {
        notify["page"].connect (page_changed_cb);

        transition_type = Gtk.StackTransitionType.SLIDE_UP_DOWN;
        transition_duration = 400;
    }

    private void page_changed_cb () {

        visible_child_name = page.to_string ();

        /* XXX don't have much reason to check page yet, probably will though */
        switch (page) {
            case Dactl.SettingsPage.GENERAL:
                break;
            case Dactl.SettingsPage.ACQUISITION:
                break;
            case Dactl.SettingsPage.CONTROL:
                break;
            case Dactl.SettingsPage.LOG:
                log.populate_logs_treeview ();
                break;
            case Dactl.SettingsPage.PLUGIN:
                break;
            default:
                break;
        }
    }
}
