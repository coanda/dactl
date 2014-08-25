[GtkTemplate (ui = "/org/coanda/dactl/ui/ui-settings.ui")]
private class Dactl.UISettings : Gtk.Stack {

    [GtkChild]
    private Gtk.ListStore liststore_axis;

    [GtkChild]
    private Gtk.ListStore liststore_trace;

    [GtkChild]
    private Gtk.ListStore liststore_stripchart;

    [GtkChild]
    private Gtk.TreeModelFilter model_axis;

    [GtkChild]
    private Gtk.TreeModelFilter model_trace;

    [GtkChild]
    private Gtk.TreeModelFilter model_stripchart;

    [GtkChild]
    private Gtk.TreeView treeview_axis;

    [GtkChild]
    private Gtk.TreeView treeview_trace;

    [GtkChild]
    private Gtk.TreeView treeview_stripchart;

    [GtkChild]
    private Gtk.Entry entry_title;

    [GtkChild]
    private Gtk.Entry entry_axis_label;

    [GtkChild]
    private Gtk.Adjustment adjustment_min_height;

    [GtkChild]
    private Gtk.Adjustment adjustment_min_width;

    [GtkChild]
    private Gtk.Adjustment adjustment_time_window;

    [GtkChild]
    private Gtk.Adjustment adjustment_num_points;

    [GtkChild]
    private Gtk.Adjustment adjustment_axis_min;

    [GtkChild]
    private Gtk.Adjustment adjustment_axis_max;

    [GtkChild]
    private Gtk.Adjustment adjustment_axis_minor_steps;

    [GtkChild]
    private Gtk.Adjustment adjustment_axis_major_steps;

    [GtkChild]
    private Gtk.ComboBoxText combo_axis_position;

    [GtkChild]
    private Gtk.ComboBoxText combo_trace_data_source;

    [GtkChild]
    private Gtk.ColorButton btn_trace_color;

    [GtkChild]
    private Gtk.Box box_stripchart_result;

    private Dactl.Chart stripchart;

    construct {
/*
 *        var channel = new Cld.AIChannel ();
 *        channel.id = "tmp_ch0";
 *
 *        var trace = new Dactl.Trace ();
 *        trace.ch_ref = channel.id;
 *
 *        stripchart = new Dactl.Chart ();
 *
 *        stripchart.add_child (trace);
 *        stripchart.request_object.connect ((id) => {
 *            stripchart.offer_cld_object (channel);
 *        });
 */

        populate ();
        model_stripchart.set_visible_column (1);

        var path = new Gtk.TreePath.from_string ("0");
        treeview_stripchart.set_cursor (path, null, false);
    }

    private void populate () {
        // Only need to fill the stripchart list to begin with
        /*
         *var charts = objects.get_object_map (typeof (Dactl.Chart));
         *foreach (var chart in charts.values) {
         *    list_append (liststore_stripchart, chart.title, true);
         *}
         */

         /*
          *box_stripchart_result.pack_start (stripchart);
          */

        var app = Dactl.UI.Application.get_default ();
        var charts = app.model.get_object_map (typeof (Dactl.StripChart));
        foreach (var chart in charts.values) {
            message ("chart id: %s", chart.id);
        }
    }

    private void list_append (Gtk.ListStore model, string label, bool visible) {
        Gtk.TreeIter iter;

        model.append (out iter);
        model.set (iter, 0, label);
        model.set (iter, 1, visible);
    }

    [GtkCallback]
    private void treeview_stripchart_row_activated_cb (Gtk.TreeView treeview,
                                                       Gtk.TreePath path,
                                                       Gtk.TreeViewColumn column) {
        Gtk.TreeIter filter_iter, iter;
        model_stripchart.get_iter (out filter_iter, path);
        model_stripchart.convert_iter_to_child_iter (out iter, filter_iter);

        // Populate chart widgets

        // Populate axes treeview

        // Populate traces treeview
    }

    [GtkCallback]
    private void treeview_axis_row_activated_cb (Gtk.TreeView treeview,
                                                 Gtk.TreePath path,
                                                 Gtk.TreeViewColumn column) {
        Gtk.TreeIter filter_iter, iter;
        model_axis.get_iter (out filter_iter, path);
        model_axis.convert_iter_to_child_iter (out iter, filter_iter);

        // Populate axis widgets
    }

    [GtkCallback]
    private void treeview_trace_row_activated_cb (Gtk.TreeView treeview,
                                                  Gtk.TreePath path,
                                                  Gtk.TreeViewColumn column) {
        Gtk.TreeIter filter_iter, iter;
        model_trace.get_iter (out filter_iter, path);
        model_trace.convert_iter_to_child_iter (out iter, filter_iter);

        // Populate trace widgets
    }

    [GtkCallback]
    private void entry_title_changed_cb () {
    }

    [GtkCallback]
    private void entry_axis_label_changed_cb () {
    }

    [GtkCallback]
    private void combo_axis_position_changed_cb () {
    }

    [GtkCallback]
    private void combo_trace_data_source_changed_cb () {
    }

    [GtkCallback]
    private void btn_trace_color_set_cb () {
    }

    [GtkCallback]
    private void adjustment_min_height_value_changed_cb () {
    }

    [GtkCallback]
    private void adjustment_min_width_value_changed_cb () {
    }

    [GtkCallback]
    private void adjustment_time_window_value_changed_cb () {
    }

    [GtkCallback]
    private void adjustment_num_points_value_changed_cb () {
    }

    [GtkCallback]
    private void adjustment_axis_min_value_changed_cb () {
    }

    [GtkCallback]
    private void adjustment_axis_max_value_changed_cb () {
    }

    [GtkCallback]
    private void adjustment_axis_minor_steps_value_changed_cb () {
    }

    [GtkCallback]
    private void adjustment_axis_major_steps_value_changed_cb () {
    }
}
