[GtkTemplate (ui = "/org/coanda/dactl/ui/chart_settings_dialog.ui")]
public class Dactl.ChartSettingsDialog : Gtk.Dialog {

    /* Property backing fields. */
    private ChartWidget _chart;

    [GtkChild]
    private Gtk.Widget btn_height_min;

    [GtkChild]
    private Gtk.Widget btn_width_min;

    [GtkChild]
    private Gtk.Widget btn_x_axis_min;

    [GtkChild]
    private Gtk.Widget btn_x_axis_max;

    [GtkChild]
    private Gtk.Widget btn_y_axis_min;

    [GtkChild]
    private Gtk.Widget btn_y_axis_max;

    [GtkChild]
    private Gtk.Widget entry_title;

    [GtkChild]
    private Gtk.Widget entry_x_axis;

    [GtkChild]
    private Gtk.Widget entry_y_axis;

    /* Properties. */
    public ChartWidget chart {
        get { return _chart; }
        set { _chart = value; }
    }

    /**
     * Default construction.
     */
    public ChartSettingsDialog (ChartWidget chart) {
        this.chart = chart;
        create_dialog ();
        update ();
    }

    [GtkCallback]
    private void response_cb (Gtk.Dialog source, int id) {
        switch (id) {
            case Gtk.ResponseType.OK:
                update ();
                hide ();
                break;
            case Gtk.ResponseType.CANCEL:
                hide ();
                break;
            case Gtk.ResponseType.APPLY:
                update ();
                break;
        }
    }

    private void create_dialog () {
        /* Retrieve chart values and fill SpinButton Entries */
        (btn_height_min as Gtk.SpinButton).set_value (chart.height_min);

        //(btn_width_min as Gtk.SpinButton).set_value (chart.width_min);
        (btn_x_axis_min as Gtk.SpinButton).set_value (chart.x_axis_min);
        (btn_x_axis_max as Gtk.SpinButton).set_value (chart.x_axis_max);
        (btn_y_axis_max as Gtk.SpinButton).set_value (chart.y_axis_max);
        (btn_y_axis_min as Gtk.SpinButton).set_value (chart.y_axis_min);

        /* Retrieve chart attributes and fill in Entry text. */
        (entry_title as Gtk.Entry).set_text (chart.title);
        (entry_x_axis as Gtk.Entry).set_text (chart.x_axis_label);
        (entry_y_axis as Gtk.Entry).set_text (chart.y_axis_label);

        add_button (Gtk.Stock.CANCEL, Gtk.ResponseType.CANCEL);
        add_button (Gtk.Stock.APPLY, Gtk.ResponseType.APPLY);
        add_button (Gtk.Stock.OK, Gtk.ResponseType.OK);

        show_all ();
    }

    private void update () {
        /* Update the ChartWidget with new values from the dialog. */
        chart.title = (entry_title as Gtk.Entry).get_text ();
        chart.x_axis_label = (entry_x_axis as Gtk.Entry).get_text ();
        chart.y_axis_label = (entry_y_axis as Gtk.Entry).get_text ();
        chart.height_min = (int)((btn_height_min as Gtk.SpinButton).get_value ());
        (chart as Gtk.Widget).height_request = chart.height_min;
        //chart.width_min = (btn_width_min as Gtk.SpinButton).get_value ();
        chart.x_axis_min = (btn_x_axis_min as Gtk.SpinButton).get_value ();
        chart.x_axis_max = (btn_x_axis_max as Gtk.SpinButton).get_value ();
        chart.y_axis_min = (btn_y_axis_min as Gtk.SpinButton).get_value ();
        chart.y_axis_max = (btn_y_axis_max as Gtk.SpinButton).get_value ();

        /* Update schema settings */
        chart.update_settings ();
    }
}
