[GtkTemplate (ui = "/org/coanda/dactl/ui/chart-settings.ui")]
private class Dactl.ChartSettings : Gtk.Box {

    [GtkChild]
    private Gtk.Revealer settings;

    [GtkChild]
    private Gtk.Label lbl_description;

    [GtkChild]
    private Gtk.Box chart_box;

    private Dactl.StripChart chart;

    private Gtk.Widget parent;

    construct {
        settings.reveal_child = false;
        settings.transition_type = Gtk.RevealerTransitionType.SLIDE_DOWN;
        settings.transition_duration = 400;
    }

    public ChartSettings (Dactl.StripChart chart) {
        this.chart = chart;
        parent = chart.parent;
        lbl_description.label = chart.title;
    }

    [GtkCallback]
    private void btn_chart_clicked_cb () {
        if (!settings.reveal_child) {
            chart.reparent (chart_box);
            chart_box.pack_start (chart as Gtk.Widget, true, true, 0);
            settings.reveal_child = true;
        } else {
            settings.reveal_child = false;
            chart.reparent (parent);
        }
    }
}
