// Just the one for now
private enum Dactl.SidebarPage {
    SETTINGS,
    NONE,
}

[GtkTemplate (ui = "/org/coanda/dactl/ui/sidebar.ui")]
private class Dactl.Sidebar : Gtk.Revealer {

    [GtkChild]
    private Dactl.SettingsSidebar settings_sidebar;

    [GtkChild]
    private Gtk.Notebook notebook;

    public Dactl.SidebarPage page { get; set; }

    public GLib.SimpleAction settings_selection_action { get; private set; }

    construct {
        settings_selection_action = new SimpleAction ("settings-selection", null);
        settings_sidebar.selection_action = settings_selection_action;
        notify["page"].connect (page_changed_cb);
        set_valign (Gtk.Align.START);
        set_transition_duration (750);
    }

    /**
     * There's only one page right now, using enum just in case that changes.
     */
    private void page_changed_cb () {
        switch (page) {
            case Dactl.SidebarPage.SETTINGS:
                reveal_child = true;
                notebook.page = page;
                break;
            default:
                reveal_child = false;
                break;
        }
    }
}
