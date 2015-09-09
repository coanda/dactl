[GtkTemplate (ui = "/org/coanda/dactl/ui/widget-settings.ui")]
private class Dactl.WidgetSettings : Gtk.Box {

    [GtkChild]
    private Gtk.Revealer settings;

    [GtkChild]
    private Gtk.Label lbl_description;

    [GtkChild]
    private Gtk.Box widget_box;

    private Dactl.CompositeWidget widget;

    private Gtk.Widget parent;

    construct {
        settings.reveal_child = false;
        settings.transition_type = Gtk.RevealerTransitionType.SLIDE_DOWN;
        settings.transition_duration = 400;
    }

    public WidgetSettings (Dactl.CompositeWidget widget) {
        this.widget = widget;
        parent = widget.parent;
        lbl_description.label = widget.title;
    }

    [GtkCallback]
    private void btn_widget_clicked_cb () {
        if (!settings.reveal_child) {
            widget.reparent (widget_box);
            widget_box.pack_start (widget as Gtk.Widget, true, true, 0);
            settings.reveal_child = true;
        } else {
            settings.reveal_child = false;
            widget.reparent (parent);
        }
    }
}
