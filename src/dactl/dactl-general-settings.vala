[GtkTemplate (ui = "/org/coanda/dactl/ui/general-settings.ui")]
private class Dactl.GeneralSettings : Gtk.Box {

//    [GtkChild]
//    private Gtk.Alignment alignment_ui;

    private Gtk.StackSwitcher switcher;

    private Dactl.UISettings ui_settings;

    construct {
        //switcher = new Gtk.StackSwitcher ();
        //alignment_ui.add (switcher);

        ui_settings = new Dactl.UISettings ();
        ui_settings.transition_duration = 400;
        ui_settings.transition_type = Gtk.StackTransitionType.CROSSFADE;
        //switcher.set_stack (ui_settings as Gtk.Stack);

//        alignment_ui.add (ui_settings);
    }
}
