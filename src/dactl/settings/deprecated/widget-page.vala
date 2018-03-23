[GtkTemplate (ui = "/org/coanda/dactl/ui/widget-settings-page.ui")]
private class Dactl.WidgetSettingsPage : Gtk.Box {

    [GtkChild]
    private Gtk.Box content;

    construct {
        var app = Dactl.UI.Application.get_default ();
        var widgets = app.model.get_object_map (typeof (Dactl.CompositeWidget));

        foreach (var widget in widgets.values) {
            message ("Adding `%s' as a widget settings box", widget.id);
            var widget_settings = new Dactl.WidgetSettings (widget as Dactl.CompositeWidget);
            content.pack_start (widget_settings as Gtk.Widget, true, true, 0);
        }
    }
}
