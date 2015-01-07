[GtkTemplate (ui = "/org/coanda/dactl/ui/chart-settings-page.ui")]
private class Dactl.ChartSettingsPage : Gtk.Box {

    [GtkChild]
    private Gtk.Box content;

    construct {
        var app = Dactl.UI.Application.get_default ();
        var charts = app.model.get_object_map (typeof (Dactl.StripChart));

        foreach (var chart in charts.values) {
            message ("Adding `%s' as a chart settings box", chart.id);
            var chart_settings = new Dactl.ChartSettings (chart as Dactl.StripChart);
            content.pack_start (chart_settings as Gtk.Widget, true, true, 0);
        }
    }
}
