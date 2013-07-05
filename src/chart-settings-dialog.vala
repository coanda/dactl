using Gtk;
using Cld;

public class ChartSettingsDialog : Dialog {

    private ChartWidget _chart;
    public ChartWidget chart {
        get { return _chart; }
        set { _chart = value; }
    }
    private Gtk.Builder builder;
    private Gtk.Widget dialog;
    private Gtk.Widget btn_height_min;
    private Gtk.Widget btn_width_min;
    private Gtk.Widget btn_x_axis_min;
    private Gtk.Widget btn_x_axis_max;
    private Gtk.Widget btn_y_axis_min;
    private Gtk.Widget btn_y_axis_max;
    private Gtk.Widget entry_title;
    private Gtk.Widget entry_x_axis;
    private Gtk.Widget entry_y_axis;

    construct {
        string path = GLib.Path.build_filename (Config.DATADIR,
                                                "chart_dialog.ui");
        builder = new Gtk.Builder ();
        GLib.debug ("Loaded interface file: %s", path);

        try {
            builder.add_from_file (path);
        } catch (GLib.Error e) {
            var msg = new MessageDialog (null, DialogFlags.MODAL,
                                         MessageType.ERROR,
                                         ButtonsType.CANCEL,
                                         "Failed to load UI\n%s",
                                         e.message);
            msg.run ();
        }

    }

    public ChartSettingsDialog (ChartWidget chart) {
        this.chart = chart;
        create_dialog ();
        update ();
        connect_signals ();
    }

    private void create_dialog () {
        var dialog = builder.get_object ("chart_dialog");
        var content = get_content_area ();
        var action = get_action_area ();
        var _content = (dialog as Dialog).get_content_area ();
        _content.reparent (content);
        /* Get SpinButtons */
         btn_height_min = builder.get_object ("btn_height_min") as Gtk.Widget;
         btn_width_min = builder.get_object ("btn_width_min") as Gtk.Widget;
         btn_x_axis_min = builder.get_object ("btn_x_axis_min") as Gtk.Widget;
         btn_x_axis_max = builder.get_object ("btn_x_axis_max") as Gtk.Widget;
         btn_y_axis_min = builder.get_object ("btn_y_axis_min") as Gtk.Widget;
         btn_y_axis_max = builder.get_object ("btn_y_axis_max") as Gtk.Widget;
        /* Retrieve chart values and fill SpinButton Entries */
        (btn_height_min as Gtk.SpinButton).set_value (chart.height_min);
        //(btn_width_min as Gtk.SpinButton).set_value (chart.width_min);
        (btn_x_axis_min as Gtk.SpinButton).set_value (chart.x_axis_min);
        (btn_x_axis_max as Gtk.SpinButton).set_value (chart.x_axis_max);
        (btn_y_axis_max as Gtk.SpinButton).set_value (chart.y_axis_max);
        (btn_y_axis_min as Gtk.SpinButton).set_value (chart.y_axis_min);
        /* Get Entries */
        entry_title = builder.get_object ("entry_title") as Gtk.Widget;
        entry_x_axis = builder.get_object ("entry_x_axis") as Gtk.Widget;
        entry_y_axis = builder.get_object ("entry_y_axis") as Gtk.Widget;
        /* Retrieve chart attributes and fill in Entry text. */
        (entry_title as Gtk.Entry).set_text (chart.title);
        (entry_x_axis as Gtk.Entry).set_text (chart.x_axis_label);
        (entry_y_axis as Gtk.Entry).set_text (chart.y_axis_label);
        add_button (Stock.CANCEL, ResponseType.CANCEL);
        add_button (Stock.APPLY, ResponseType.APPLY);
        add_button (Stock.OK, ResponseType.OK);
        action.show_all ();
        content.show_all ();
    }

    private void connect_signals () {
        this.response.connect (response_cb);
    }

    private void response_cb (Dialog source, int response_id) {
        switch (response_id) {
            case ResponseType.OK:
                update ();
                hide ();
                break;
            case ResponseType.CANCEL:
                hide ();
                break;
            case ResponseType.APPLY:
                update ();
                break;
        }
    }
    private void update () {
        /* Update the ChartWidget with new values from the dialog. */
        chart.title = (entry_title as Gtk.Entry).get_text ();
        chart.x_axis_label = (entry_x_axis as Gtk.Entry).get_text ();
        chart.y_axis_label = (entry_y_axis as Gtk.Entry).get_text ();
        chart.height_min = (int)((btn_height_min as Gtk.SpinButton).get_value ());
        (chart as Widget).height_request = chart.height_min;
        //chart.width_min = (btn_width_min as Gtk.SpinButton).get_value ();
        chart.x_axis_min = (btn_x_axis_min as Gtk.SpinButton).get_value ();
        chart.x_axis_max = (btn_x_axis_max as Gtk.SpinButton).get_value ();
        chart.y_axis_min = (btn_y_axis_min as Gtk.SpinButton).get_value ();
        chart.y_axis_max = (btn_y_axis_max as Gtk.SpinButton).get_value ();
        /* Update schema settings */
        chart.update_settings ();
    }
}


