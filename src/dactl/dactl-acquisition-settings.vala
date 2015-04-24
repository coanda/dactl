[GtkTemplate (ui = "/org/coanda/dactl/ui/acquisition-settings.ui")]
private class Dactl.AcquisitionSettings : Gtk.Box {
    public enum ChanColumns {
        ID,
        NUM,
        TAG,
        DESCRIPTION,
        CALIBRATION,
        AVERAGE,
        DEVICE,
        VALUE,
        UNITS,
        URI,
        EXPRESSION
    }

    public enum DSColumns {
        ID,
        LENGTH,
        URI
    }

    public const int URI = 5;

    public enum CoeffColumns {
        ID,
        N,
        VALUE
    }

    public enum Page {
        AI,
        AO,
        DI,
        DO,
        DS,
        MATH
    }

    public bool show_header { get; set; default = true; }

    [GtkChild]
    private Gtk.ListStore liststore_ai_chan;

    [GtkChild]
    private Gtk.ListStore liststore_ao_chan;

    [GtkChild]
    private Gtk.ListStore liststore_di_chan;

    [GtkChild]
    private Gtk.ListStore liststore_do_chan;

    [GtkChild]
    private Gtk.ListStore liststore_math_chan;

    [GtkChild]
    private Gtk.ListStore liststore_coeff;

    [GtkChild]
    private Gtk.ListStore liststore_ds;

    [GtkChild]
    private Gtk.Notebook notebook_channel;

    [GtkChild]
    private Gtk.Box box_ai;

    [GtkChild]
    private Gtk.Box box_ao;

    [GtkChild]
    private Gtk.Box box_di;

    [GtkChild]
    private Gtk.Box box_do;

    [GtkChild]
    private Gtk.Box box_math;

    [GtkChild]
    private Gtk.Box box_ds;

    [GtkChild]
    private Gtk.ScrolledWindow scrolledwindow_ai;

    [GtkChild]
    private Gtk.TreeView treeview_ai;

    [GtkChild]
    private Gtk.TreeView treeview_coeff_ai;

    [GtkChild]
    private Gtk.TreeSelection treeview_selection_ai;

    [GtkChild]
    private Gtk.TreeSelection treeview_selection_coeff_ai;

    [GtkChild]
    private Gtk.Entry entry_tag_ai;

    [GtkChild]
    private Gtk.Entry entry_desc_ai;

    [GtkChild]
    private Gtk.SpinButton spinbutton_num_ai;

    [GtkChild]
    private Gtk.SpinButton spinbutton_subdev_ai;

    [GtkChild]
    private Gtk.SpinButton spinbutton_avg_ai;

    [GtkChild]
    private Gtk.SpinButton spinbutton_range_ai;

    [GtkChild]
    private Gtk.Entry entry_alias_ai;

    [GtkChild]
    private Gtk.Entry entry_cal_ai;

    [GtkChild]
    private Gtk.Entry entry_cal_units_ai;

    [GtkChild]
    private Gtk.ScrolledWindow scrolledwindow_ao;

    [GtkChild]
    private Gtk.TreeView treeview_ao;

    [GtkChild]
    private Gtk.TreeView treeview_coeff_ao;

    [GtkChild]
    private Gtk.TreeSelection treeview_selection_ao;

    [GtkChild]
    private Gtk.TreeSelection treeview_selection_coeff_ao;

    [GtkChild]
    private Gtk.Entry entry_tag_ao;

    [GtkChild]
    private Gtk.Entry entry_desc_ao;

    [GtkChild]
    private Gtk.SpinButton spinbutton_num_ao;

    [GtkChild]
    private Gtk.SpinButton spinbutton_subdev_ao;

    [GtkChild]
    private Gtk.SpinButton spinbutton_range_ao;

    [GtkChild]
    private Gtk.Entry entry_alias_ao;

    [GtkChild]
    private Gtk.Entry entry_cal_ao;

    [GtkChild]
    private Gtk.Entry entry_cal_units_ao;

    [GtkChild]
    private Gtk.ScrolledWindow scrolledwindow_di;

    [GtkChild]
    private Gtk.TreeView treeview_di;

    [GtkChild]
    private Gtk.TreeSelection treeview_selection_di;

    [GtkChild]
    private Gtk.Entry entry_tag_di;

    [GtkChild]
    private Gtk.Entry entry_desc_di;

    [GtkChild]
    private Gtk.SpinButton spinbutton_num_di;

    [GtkChild]
    private Gtk.SpinButton spinbutton_subdev_di;

    [GtkChild]
    private Gtk.ScrolledWindow scrolledwindow_do;

    [GtkChild]
    private Gtk.TreeView treeview_do;

    [GtkChild]
    private Gtk.TreeSelection treeview_selection_do;

    [GtkChild]
    private Gtk.Entry entry_tag_do;

    [GtkChild]
    private Gtk.Entry entry_desc_do;

    [GtkChild]
    private Gtk.SpinButton spinbutton_num_do;

    [GtkChild]
    private Gtk.SpinButton spinbutton_subdev_do;

    [GtkChild]
    private Gtk.ScrolledWindow scrolledwindow_math;

    [GtkChild]
    private Gtk.TreeView treeview_math;

    [GtkChild]
    private Gtk.TreeView treeview_coeff_math;

    [GtkChild]
    private Gtk.TreeSelection treeview_selection_math;

    [GtkChild]
    private Gtk.TreeSelection treeview_selection_coeff_math;

    [GtkChild]
    private Gtk.Entry entry_tag_math;

    [GtkChild]
    private Gtk.Entry entry_desc_math;

    [GtkChild]
    private Gtk.Entry entry_expression_math;

    [GtkChild]
    private Gtk.Entry entry_alias_math;

    [GtkChild]
    private Gtk.Entry entry_cal_math;

    [GtkChild]
    private Gtk.Entry entry_cal_units_math;

    [GtkChild]
    private Gtk.TreeView treeview_ds;

    [GtkChild]
    private Gtk.TreeSelection treeview_selection_ds;

    [GtkChild]
    private Gtk.SpinButton spinbutton_length_ds;

    [GtkChild]
    private Gtk.ComboBox combobox_ds_chref;

    [GtkChild]
    private Gtk.ListStore liststore_ds_chref;

    private Cld.AIChannel ai_selected;
    private Cld.AOChannel ao_selected;
    private Cld.DIChannel di_selected;
    private Cld.DOChannel do_selected;
    private Cld.MathChannel math_selected;
    private Cld.DataSeries ds_selected;
    private bool ignore_combobox_ds_changed;

    construct {
        notebook_channel.switch_page.connect (notebook_channel_switch_page_cb);

        treeview_ai.set_activate_on_single_click (true);
        treeview_ao.set_activate_on_single_click (true);
        treeview_di.set_activate_on_single_click (true);
        treeview_do.set_activate_on_single_click (true);
        treeview_math.set_activate_on_single_click (true);
        treeview_ds.set_activate_on_single_click (true);

        populate_ai_treeview ();
        populate_ao_treeview ();
        populate_di_treeview ();
        populate_do_treeview ();
        populate_math_treeview ();
        populate_ds_treeview ();

        create_coefficient_treeview_ai ();
        create_coefficient_treeview_ao ();
        create_coefficient_treeview_math ();

        setup_ds_chref_combobox ();
    }

    private void notebook_channel_switch_page_cb (Gtk.Widget page, uint page_num) {
        switch (page_num) {
            case Page.AI:
                debug ("page switched to %u %d", page_num, Page.AI);
                break;
            default:
                break;
        }
    }

    /* Analog Input Channels */

    private void populate_ai_treeview () {
        var app = Dactl.UI.Application.get_default ();
        var channels = app.model.ctx.get_object_map_from_uri (typeof (Cld.AIChannel));

        if (channels.size > 0) {
            treeview_ai.set_model (liststore_ai_chan);
            treeview_ai.insert_column_with_attributes
                (-1, "ID", new Gtk.CellRendererText (), "text", ChanColumns.ID);
            treeview_ai.insert_column_with_attributes
                (-1, "Num", new Gtk.CellRendererText (), "text", ChanColumns.NUM);
            var renderer_tag = new Gtk.CellRendererText ();
            renderer_tag.editable = true;
            treeview_ai.insert_column_with_attributes
                (-1, "Tag", renderer_tag, "text", ChanColumns.TAG);
            treeview_ai.insert_column_with_attributes
                (-1, "Description", new Gtk.CellRendererText (), "text", ChanColumns.DESCRIPTION);
            treeview_ai.insert_column_with_attributes
                (-1, "Calibration", new Gtk.CellRendererText (), "text", ChanColumns.CALIBRATION);
            treeview_ai.insert_column_with_attributes
                (-1, "Average", new Gtk.CellRendererText (), "text", ChanColumns.AVERAGE);
            treeview_ai.insert_column_with_attributes
                (-1, "Device", new Gtk.CellRendererText (), "text", ChanColumns.DEVICE);

            Gtk.TreeIter iter;
            foreach (var channel in channels.values) {
                liststore_ai_chan.append (out iter);
                liststore_ai_chan.set (iter, ChanColumns.ID, channel.id,
                    ChanColumns.NUM, (channel as Cld.Channel).num,
                    ChanColumns.TAG, (channel as Cld.Channel).tag,
                    ChanColumns.DESCRIPTION, (channel as Cld.Channel).desc,
                    ChanColumns.CALIBRATION, (channel as Cld.ScalableChannel).calref,
                    ChanColumns.AVERAGE, (channel as Cld.AIChannel).raw_value_list_size,
                    ChanColumns.DEVICE, (channel as Cld.AIChannel).devref,
                    ChanColumns.URI, (channel as Cld.AIChannel).uri);
            }

            treeview_ai.set_rules_hint (true);
            var path = new Gtk.TreePath.first ();
            treeview_ai.set_cursor (path, null, false);
            row_activated_ai_cb (path, treeview_ai.get_column (0));
        }
    }

    private void refresh_ai_treeview () {
        var app = Dactl.UI.Application.get_default ();
        var channels = app.model.ctx.get_object_map_from_uri (typeof (Cld.AIChannel));

        liststore_ai_chan.clear ();
        Gtk.TreeIter iter;
        foreach (var channel in channels.values) {
            liststore_ai_chan.append (out iter);
            liststore_ai_chan.set (iter, ChanColumns.ID, channel.id,
                ChanColumns.NUM, (channel as Cld.Channel).num,
                ChanColumns.TAG, (channel as Cld.Channel).tag,
                ChanColumns.DESCRIPTION, (channel as Cld.Channel).desc,
                ChanColumns.CALIBRATION, (channel as Cld.ScalableChannel).calref,
                ChanColumns.AVERAGE, (channel as Cld.AIChannel).raw_value_list_size,
                ChanColumns.DEVICE, (channel as Cld.AIChannel).devref,
                ChanColumns.URI, (channel as Cld.AIChannel).uri);
        }

    }

    private void create_coefficient_treeview_ai () {
        treeview_coeff_ai.set_model (liststore_coeff);
        treeview_coeff_ai.insert_column_with_attributes
                (-1, "ID", new Gtk.CellRendererText (), "text", CoeffColumns.ID);
        treeview_coeff_ai.insert_column_with_attributes
                (-1, "n", new Gtk.CellRendererText (), "text", CoeffColumns.N);
        var value_cell = new Gtk.CellRendererText ();
        value_cell.editable = true;
        treeview_coeff_ai.insert_column_with_attributes
                (-1, "Value", value_cell, "text", CoeffColumns.VALUE);
        value_cell.edited.connect (value_cell_edited_ai_cb);
    }

    [GtkCallback]
    private void row_activated_ai_cb (Gtk.TreePath path, Gtk.TreeViewColumn column) {
        Gtk.TreeIter iter;
        string uri;

        var app = Dactl.UI.Application.get_default ();
        if (treeview_selection_ai == null )
            critical ("AI channel selection is null");
        liststore_ai_chan.get_iter (out iter, path);
        liststore_ai_chan.get (iter, ChanColumns.URI, out uri);
        ai_selected = app.model.ctx.get_object_from_uri (uri) as Cld.AIChannel;
        update_ai_entries ();
        populate_ai_coeff_treeview ();
    }

    private void populate_ai_coeff_treeview () {
        Gtk.TreeIter iter;

        liststore_coeff.clear ();
        foreach (var coefficient in ai_selected.calibration.coefficients.values) {
            liststore_coeff.append (out iter);
            liststore_coeff.set (iter, CoeffColumns.ID, coefficient.id,
                                 CoeffColumns.N, (coefficient as Cld.Coefficient).n,
                                 CoeffColumns.VALUE, (coefficient as Cld.Coefficient).value);
        }

        treeview_coeff_ai.set_rules_hint (true);
        var path = new Gtk.TreePath.from_string ("0");
        treeview_coeff_ai.set_cursor (path, null, false);
    }

    private void refresh_ai_coeff_treeview () {
        Gtk.TreeIter iter;

        liststore_coeff.clear ();
        foreach (var coefficient in ai_selected.calibration.coefficients.values) {
            liststore_coeff.append (out iter);
            liststore_coeff.set (iter, CoeffColumns.ID, coefficient.id,
                                 CoeffColumns.N, (coefficient as Cld.Coefficient).n,
                                 CoeffColumns.VALUE, (coefficient as Cld.Coefficient).value);
        }
    }


    private void update_ai_entries () {
        /* Update entries */
        entry_tag_ai.set_text (ai_selected.tag);
        entry_desc_ai.set_text (ai_selected.desc);
        spinbutton_num_ai.set_value (ai_selected.num);
        spinbutton_subdev_ai.set_value (ai_selected.subdevnum);
        spinbutton_avg_ai.set_value (ai_selected.raw_value_list_size);
        spinbutton_range_ai.set_value (ai_selected.range);
        entry_alias_ai.set_text (ai_selected.alias);
        entry_cal_ai.set_text (ai_selected.calref);

        var app = Dactl.UI.Application.get_default ();
        var cal = app.model.ctx.get_object_from_uri (entry_cal_ai.get_text ());
        entry_cal_units_ai.set_text ((cal as Cld.Calibration).units);
    }

    [GtkCallback]
    private void entry_tag_ai_activate_cb () {
        ai_selected.tag = entry_tag_ai.get_text ();
        refresh_ai_treeview ();
        /**
         * XXX FIXME This is how all the values should be edited ie. make changes
         * to the list model data only. The settings dialog for the application
         * should handle updating the Cld objects after confirmation by the user.
         */
/*
 *        Gtk.TreeModel model;
 *        Gtk.TreeIter iter;
 *        treeview_selection_ai.get_selected (out model, out iter);
 *
 *        liststore_ai_chan.set (iter, ChanColumns.TAG, entry_tag_ai.get_text ());
 */
    }

    [GtkCallback]
    private void entry_desc_ai_activate_cb () {
        ai_selected.desc = entry_desc_ai.get_text ();
        refresh_ai_treeview ();
    }

    [GtkCallback]
    private void spinbutton_num_ai_value_changed_cb () {
        ai_selected.num = (int) spinbutton_num_ai.get_value ();
        refresh_ai_treeview ();
    }

    [GtkCallback]
    private void spinbutton_subdev_ai_value_changed_cb () {
        ai_selected.subdevnum = (int) spinbutton_subdev_ai.get_value ();
        refresh_ai_treeview ();
    }

    [GtkCallback]
    private void spinbutton_avg_ai_value_changed_cb () {
        ai_selected.raw_value_list_size = (int) spinbutton_avg_ai.get_value ();
        refresh_ai_treeview ();
    }

    [GtkCallback]
    private void spinbutton_range_ai_value_changed_cb () {
        ai_selected.range = (int) spinbutton_range_ai.get_value ();
        refresh_ai_treeview ();
    }

    [GtkCallback]
    private void entry_alias_ai_activate_cb () {
        ai_selected.alias = entry_alias_ai.get_text ();
        refresh_ai_treeview ();
    }

    [GtkCallback]
    private void entry_cal_ai_activate_cb () {
        var app = Dactl.UI.Application.get_default ();
        var cal = app.model.ctx.get_object_from_uri (entry_cal_ai.get_text ());
        if (cal != null) {
            ai_selected.calibration = cal as Cld.Calibration;
            ai_selected.calref = entry_cal_ai.get_text ();
            refresh_ai_treeview ();
            refresh_ai_coeff_treeview ();
        } else {
            entry_cal_ai.set_text ("invalid entry");
        }
    }

    [GtkCallback]
    private void entry_cal_units_ai_activate_cb () {
        var app = Dactl.UI.Application.get_default ();
        var cal = app.model.ctx.get_object_from_uri (entry_cal_ai.get_text ());
        ai_selected.calibration.units = entry_cal_units_ai.get_text ();
        refresh_ai_treeview ();
    }

    private void value_cell_edited_ai_cb (string path_string, string new_text) {
        int n;

        var app = Dactl.UI.Application.get_default ();
        var cal = app.model.ctx.get_object_from_uri (entry_cal_ai.get_text ());

        Gtk.TreePath path = new Gtk.TreePath.from_string (path_string);
        Gtk.TreeIter iter;
        liststore_coeff.get_iter (out iter, path);
        liststore_coeff.get (iter, CoeffColumns.N, out n);
        liststore_coeff.set (iter, CoeffColumns.VALUE, double.parse (new_text));
        var coeff = (cal as Cld.Calibration).get_coefficient (n);
        (coeff as Cld.Coefficient).value = double.parse (new_text);

        GLib.message ("%s %s %s", path_string, new_text, coeff.uri);
        refresh_ai_coeff_treeview ();
    }

    /* Analog Output Channels */

    private void populate_ao_treeview () {
        var app = Dactl.UI.Application.get_default ();
        var channels = app.model.ctx.get_object_map_from_uri (typeof (Cld.AOChannel));

        if (channels.size > 0) {
            treeview_ao.set_model (liststore_ao_chan);
            treeview_ao.insert_column_with_attributes
                (-1, "ID", new Gtk.CellRendererText (), "text", ChanColumns.ID);
            treeview_ao.insert_column_with_attributes
                (-1, "Num", new Gtk.CellRendererText (), "text", ChanColumns.NUM);
            treeview_ao.insert_column_with_attributes
                (-1, "Tag", new Gtk.CellRendererText (), "text", ChanColumns.TAG);
            treeview_ao.insert_column_with_attributes
                (-1, "Description", new Gtk.CellRendererText (), "text", ChanColumns.DESCRIPTION);
            treeview_ao.insert_column_with_attributes
                (-1, "Calibration", new Gtk.CellRendererText (), "text", ChanColumns.CALIBRATION);
            treeview_ao.insert_column_with_attributes
                (-1, "Device", new Gtk.CellRendererText (), "text", ChanColumns.DEVICE);

            Gtk.TreeIter iter;
            foreach (var channel in channels.values) {
                liststore_ao_chan.append (out iter);
                liststore_ao_chan.set (iter, ChanColumns.ID, channel.id,
                    ChanColumns.NUM, (channel as Cld.Channel).num,
                    ChanColumns.TAG, (channel as Cld.Channel).tag,
                    ChanColumns.DESCRIPTION, (channel as Cld.Channel).desc,
                    ChanColumns.CALIBRATION, (channel as Cld.ScalableChannel).calref,
                    ChanColumns.DEVICE, (channel as Cld.AOChannel).devref,
                    ChanColumns.URI, (channel as Cld.AOChannel).uri);
            }

            treeview_ao.set_rules_hint (true);
            var path = new Gtk.TreePath.first ();
            treeview_ao.set_cursor (path, null, false);
            row_activated_ao_cb (path, treeview_ao.get_column (0));
        }
    }

    private void refresh_ao_treeview () {
        var app = Dactl.UI.Application.get_default ();
        var channels = app.model.ctx.get_object_map_from_uri (typeof (Cld.AOChannel));

        liststore_ao_chan.clear ();
        Gtk.TreeIter iter;
        foreach (var channel in channels.values) {
            liststore_ao_chan.append (out iter);
            liststore_ao_chan.set (iter, ChanColumns.ID, channel.id,
                ChanColumns.NUM, (channel as Cld.Channel).num,
                ChanColumns.TAG, (channel as Cld.Channel).tag,
                ChanColumns.DESCRIPTION, (channel as Cld.Channel).desc,
                ChanColumns.CALIBRATION, (channel as Cld.ScalableChannel).calref,
                ChanColumns.DEVICE, (channel as Cld.AOChannel).devref,
                ChanColumns.URI, (channel as Cld.AOChannel).uri);
        }
    }

    private void create_coefficient_treeview_ao () {
        treeview_coeff_ao.set_model (liststore_coeff);
        treeview_coeff_ao.insert_column_with_attributes
                (-1, "ID", new Gtk.CellRendererText (), "text", CoeffColumns.ID);
        treeview_coeff_ao.insert_column_with_attributes
                (-1, "n", new Gtk.CellRendererText (), "text", CoeffColumns.N);
        var value_cell = new Gtk.CellRendererText ();
        value_cell.editable = true;
        treeview_coeff_ao.insert_column_with_attributes
                (-1, "Value", value_cell, "text", CoeffColumns.VALUE);
        value_cell.edited.connect (value_cell_edited_ao_cb);
    }

    [GtkCallback]
    private void row_activated_ao_cb (Gtk.TreePath path, Gtk.TreeViewColumn column) {

        Cld.Calibration calibration;
        Cld.AOChannel channel;
        Gtk.TreeIter iter;
        string uri;

        var app = Dactl.UI.Application.get_default ();
        if (treeview_selection_ao == null ) GLib.message ("selection is null");
        liststore_ao_chan.get_iter (out iter, path);
        liststore_ao_chan.get (iter, ChanColumns.URI, out uri);
        ao_selected = app.model.ctx.get_object_from_uri (uri) as Cld.AOChannel;
        update_ao_entries ();
        populate_ao_coeff_treeview ();
    }

    private void populate_ao_coeff_treeview () {
        Gtk.TreeIter iter;

        liststore_coeff.clear ();
        foreach (var coefficient in ao_selected.calibration.coefficients.values) {
            liststore_coeff.append (out iter);
            liststore_coeff.set (iter, CoeffColumns.ID, coefficient.id,
                                 CoeffColumns.N, (coefficient as Cld.Coefficient).n,
                                 CoeffColumns.VALUE, (coefficient as Cld.Coefficient).value);
        }

        treeview_coeff_ao.set_rules_hint (true);
        var path = new Gtk.TreePath.from_string ("0");
        treeview_coeff_ao.set_cursor (path, null, false);
    }

    private void refresh_ao_coeff_treeview () {
        Gtk.TreeIter iter;

        liststore_coeff.clear ();
        foreach (var coefficient in ao_selected.calibration.coefficients.values) {
            liststore_coeff.append (out iter);
            liststore_coeff.set (iter, CoeffColumns.ID, coefficient.id,
                                 CoeffColumns.N, (coefficient as Cld.Coefficient).n,
                                 CoeffColumns.VALUE, (coefficient as Cld.Coefficient).value);
        }
    }


    private void update_ao_entries () {
        /* Update entries */
        entry_tag_ao.set_text (ao_selected.tag);
        entry_desc_ao.set_text (ao_selected.desc);
        spinbutton_num_ao.set_value (ao_selected.num);
        spinbutton_subdev_ao.set_value (ao_selected.subdevnum);
        spinbutton_range_ao.set_value (ao_selected.range);
        entry_alias_ao.set_text (ao_selected.alias);
        entry_cal_ao.set_text (ao_selected.calref);

        var app = Dactl.UI.Application.get_default ();
        var cal = app.model.ctx.get_object_from_uri (entry_cal_ao.get_text ());
        entry_cal_units_ao.set_text ((cal as Cld.Calibration).units);
    }

    [GtkCallback]
    private void entry_tag_ao_activate_cb () {
        ao_selected.tag = entry_tag_ao.get_text ();
        message ("entry tag ao: %s %s", ao_selected.tag, entry_tag_ao.get_text ());
        refresh_ao_treeview ();
    }

    [GtkCallback]
    private void entry_desc_ao_activate_cb () {
        ao_selected.desc = entry_desc_ao.get_text ();
        refresh_ao_treeview ();
    }

    [GtkCallback]
    private void spinbutton_num_ao_value_changed_cb () {
        ao_selected.num = (int) spinbutton_num_ao.get_value ();
        refresh_ao_treeview ();
    }

    [GtkCallback]
    private void spinbutton_subdev_ao_value_changed_cb () {
        ao_selected.subdevnum = (int) spinbutton_subdev_ao.get_value ();
        refresh_ao_treeview ();
    }

    [GtkCallback]
    private void spinbutton_range_ao_value_changed_cb () {
        ao_selected.range = (int) spinbutton_range_ao.get_value ();
        refresh_ao_treeview ();
    }

    [GtkCallback]
    private void entry_alias_ao_activate_cb () {
        ao_selected.alias = entry_alias_ao.get_text ();
        refresh_ao_treeview ();
    }

    [GtkCallback]
    private void entry_cal_ao_activate_cb () {
        var app = Dactl.UI.Application.get_default ();
        var cal = app.model.ctx.get_object_from_uri (entry_cal_ao.get_text ());
        if (cal != null) {
            ao_selected.calibration = cal as Cld.Calibration;
            ao_selected.calref = entry_cal_ao.get_text ();
            refresh_ao_treeview ();
            refresh_ao_coeff_treeview ();
        } else {
            entry_cal_ao.set_text ("invalid entry");
        }
    }

    [GtkCallback]
    private void entry_cal_units_ao_activate_cb () {
        var app = Dactl.UI.Application.get_default ();
        var cal = app.model.ctx.get_object_from_uri (entry_cal_ao.get_text ());
        ao_selected.calibration.units = entry_cal_units_ao.get_text ();
        refresh_ao_treeview ();
    }

    private void value_cell_edited_ao_cb (string path_string, string new_text) {
        int n;

        var app = Dactl.UI.Application.get_default ();
        var cal = app.model.ctx.get_object_from_uri (entry_cal_ao.get_text ());

        Gtk.TreePath path = new Gtk.TreePath.from_string (path_string);
        Gtk.TreeIter iter;
        liststore_coeff.get_iter (out iter, path);
        liststore_coeff.get (iter, CoeffColumns.N, out n);
        liststore_coeff.set (iter, CoeffColumns.VALUE, double.parse (new_text));
        var coeff = (cal as Cld.Calibration).get_coefficient (n);
        (coeff as Cld.Coefficient).value = double.parse (new_text);

        GLib.message ("%s %s %s", path_string, new_text, coeff.uri);
        refresh_ao_coeff_treeview ();
    }

    /* Digital Input Channels */

    private void populate_di_treeview () {
        var app = Dactl.UI.Application.get_default ();
        var channels = app.model.ctx.get_object_map_from_uri (typeof (Cld.DIChannel));

        if (channels.size > 0) {
            treeview_di.set_model (liststore_di_chan);
            treeview_di.insert_column_with_attributes
                (-1, "ID", new Gtk.CellRendererText (), "text", ChanColumns.ID);
            treeview_di.insert_column_with_attributes
                (-1, "Num", new Gtk.CellRendererText (), "text", ChanColumns.NUM);
            treeview_di.insert_column_with_attributes
                (-1, "Tag", new Gtk.CellRendererText (), "text", ChanColumns.TAG);
            treeview_di.insert_column_with_attributes
                (-1, "Description", new Gtk.CellRendererText (), "text", ChanColumns.DESCRIPTION);

            Gtk.TreeIter iter;
            foreach (var channel in channels.values) {
                liststore_di_chan.append (out iter);
                liststore_di_chan.set (iter, ChanColumns.ID, channel.id,
                    ChanColumns.NUM, (channel as Cld.Channel).num,
                    ChanColumns.TAG, (channel as Cld.Channel).tag,
                    ChanColumns.DESCRIPTION, (channel as Cld.Channel).desc,
                    URI, (channel as Cld.DIChannel).uri);
            }

            treeview_di.set_rules_hint (true);
            var path = new Gtk.TreePath.first ();
            treeview_di.set_cursor (path, null, false);
            row_activated_di_cb (path, treeview_di.get_column (0));
        }
    }

    private void refresh_di_treeview () {
        var app = Dactl.UI.Application.get_default ();
        var channels = app.model.ctx.get_object_map_from_uri (typeof (Cld.DIChannel));

        liststore_di_chan.clear ();
        Gtk.TreeIter iter;
        foreach (var channel in channels.values) {
            liststore_di_chan.append (out iter);
            liststore_di_chan.set (iter, ChanColumns.ID, channel.id,
                ChanColumns.NUM, (channel as Cld.Channel).num,
                ChanColumns.TAG, (channel as Cld.Channel).tag,
                ChanColumns.DESCRIPTION, (channel as Cld.Channel).desc,
                URI, (channel as Cld.DIChannel).uri);
        }
    }

    [GtkCallback]
    private void row_activated_di_cb (Gtk.TreePath path, Gtk.TreeViewColumn column) {

        Cld.Calibration calibration;
        Cld.DIChannel channel;
        Gtk.TreeIter iter;
        string uri;

        var app = Dactl.UI.Application.get_default ();
        if (treeview_selection_di == null ) GLib.message ("selection is null");
        liststore_di_chan.get_iter (out iter, path);
        liststore_di_chan.get (iter, URI, out uri);
        di_selected = app.model.ctx.get_object_from_uri (uri) as Cld.DIChannel;
        update_di_entries ();
    }

    private void update_di_entries () {
        /* Update entries */
        entry_tag_di.set_text (di_selected.tag);
        entry_desc_di.set_text (di_selected.desc);
        spinbutton_num_di.set_value (di_selected.num);
        spinbutton_subdev_di.set_value (di_selected.subdevnum);
    }

    [GtkCallback]
    private void entry_tag_di_activate_cb () {
        di_selected.tag = entry_tag_di.get_text ();
        message ("entry tag di: %s %s", di_selected.tag, entry_tag_di.get_text ());
        refresh_di_treeview ();
    }

    [GtkCallback]
    private void entry_desc_di_activate_cb () {
        di_selected.desc = entry_desc_di.get_text ();
        refresh_di_treeview ();
    }

    [GtkCallback]
    private void spinbutton_num_di_value_changed_cb () {
        di_selected.num = (int) spinbutton_num_di.get_value ();
        refresh_di_treeview ();
    }

    [GtkCallback]
    private void spinbutton_subdev_di_value_changed_cb () {
        di_selected.subdevnum = (int) spinbutton_subdev_di.get_value ();
        refresh_di_treeview ();
    }

    /* Digital Output Channels */
    private void populate_do_treeview () {
        var app = Dactl.UI.Application.get_default ();
        var channels = app.model.ctx.get_object_map_from_uri (typeof (Cld.DOChannel));

        if (channels.size > 0) {
            treeview_do.set_model (liststore_do_chan);
            treeview_do.insert_column_with_attributes
                (-1, "ID", new Gtk.CellRendererText (), "text", ChanColumns.ID);
            treeview_do.insert_column_with_attributes
                (-1, "Num", new Gtk.CellRendererText (), "text", ChanColumns.NUM);
            treeview_do.insert_column_with_attributes
                (-1, "Tag", new Gtk.CellRendererText (), "text", ChanColumns.TAG);
            treeview_do.insert_column_with_attributes
                (-1, "Description", new Gtk.CellRendererText (), "text", ChanColumns.DESCRIPTION);

            Gtk.TreeIter iter;
            foreach (var channel in channels.values) {
                liststore_do_chan.append (out iter);
                liststore_do_chan.set (iter, ChanColumns.ID, channel.id,
                    ChanColumns.NUM, (channel as Cld.Channel).num,
                    ChanColumns.TAG, (channel as Cld.Channel).tag,
                    ChanColumns.DESCRIPTION, (channel as Cld.Channel).desc,
                    URI, (channel as Cld.DOChannel).uri);
            }

            treeview_do.set_rules_hint (true);
            var path = new Gtk.TreePath.first ();
            treeview_do.set_cursor (path, null, false);
            row_activated_do_cb (path, treeview_do.get_column (0));
        }
    }

    private void refresh_do_treeview () {
        var app = Dactl.UI.Application.get_default ();
        var channels = app.model.ctx.get_object_map_from_uri (typeof (Cld.DOChannel));

        liststore_do_chan.clear ();
        Gtk.TreeIter iter;
        foreach (var channel in channels.values) {
            message ("%s", (channel as Cld.DOChannel).to_string ());
            liststore_do_chan.append (out iter);
            liststore_do_chan.set (iter, ChanColumns.ID, channel.id,
                ChanColumns.NUM, (channel as Cld.Channel).num,
                ChanColumns.TAG, (channel as Cld.Channel).tag,
                ChanColumns.DESCRIPTION, (channel as Cld.Channel).desc,
                URI, (channel as Cld.DOChannel).uri);
        }
    }

    [GtkCallback]
    private void row_activated_do_cb (Gtk.TreePath path, Gtk.TreeViewColumn column) {

        Cld.Calibration calibration;
        Cld.DOChannel channel;
        Gtk.TreeIter iter;
        string uri;

        var app = Dactl.UI.Application.get_default ();
        if (treeview_selection_do == null ) GLib.message ("selection is null");
        liststore_do_chan.get_iter (out iter, path);
        liststore_do_chan.get (iter, URI, out uri);
        do_selected = app.model.ctx.get_object_from_uri (uri) as Cld.DOChannel;
        update_do_entries ();
    }

    private void update_do_entries () {
        /* Update entries */
        entry_tag_do.set_text (do_selected.tag);
        entry_desc_do.set_text (do_selected.desc);
        spinbutton_num_do.set_value (do_selected.num);
        spinbutton_subdev_do.set_value (do_selected.subdevnum);
    }

    [GtkCallback]
    private void entry_tag_do_activate_cb () {
        do_selected.tag = entry_tag_do.get_text ();
        message ("entry tag do: %s %s", do_selected.tag, entry_tag_do.get_text ());
        refresh_do_treeview ();
    }

    [GtkCallback]
    private void entry_desc_do_activate_cb () {
        do_selected.desc = entry_desc_do.get_text ();
        refresh_do_treeview ();
    }

    [GtkCallback]
    private void spinbutton_num_do_value_changed_cb () {
        do_selected.num = (int) spinbutton_num_do.get_value ();
        refresh_do_treeview ();
    }

    [GtkCallback]
    private void spinbutton_subdev_do_value_changed_cb () {
        do_selected.subdevnum = (int) spinbutton_subdev_do.get_value ();
        refresh_do_treeview ();
    }

    /* Math Channels */

    private void populate_math_treeview () {
        var app = Dactl.UI.Application.get_default ();
        var channels = app.model.ctx.get_object_map_from_uri (typeof (Cld.MathChannel));

        if (channels.size > 0) {
            treeview_math.set_model (liststore_math_chan);
            treeview_math.insert_column_with_attributes
                (-1, "ID", new Gtk.CellRendererText (), "text", ChanColumns.ID);
            treeview_math.insert_column_with_attributes
                (-1, "Tag", new Gtk.CellRendererText (), "text", ChanColumns.TAG);
            treeview_math.insert_column_with_attributes
                (-1, "Description", new Gtk.CellRendererText (), "text", ChanColumns.DESCRIPTION);
            treeview_math.insert_column_with_attributes
                (-1, "Calibration", new Gtk.CellRendererText (), "text", ChanColumns.CALIBRATION);

            Gtk.TreeIter iter;
            foreach (var channel in channels.values) {
                liststore_math_chan.append (out iter);
                liststore_math_chan.set (iter, ChanColumns.ID, channel.id,
                    ChanColumns.TAG, (channel as Cld.Channel).tag,
                    ChanColumns.DESCRIPTION, (channel as Cld.Channel).desc,
                    ChanColumns.CALIBRATION, (channel as Cld.ScalableChannel).calref,
                    ChanColumns.URI, (channel as Cld.MathChannel).uri);
            }

            treeview_math.set_rules_hint (true);
            var path = new Gtk.TreePath.first ();
            treeview_math.set_cursor (path, null, false);
            row_activated_math_cb (path, treeview_math.get_column (0));
        }
    }

    private void refresh_math_treeview () {
        var app = Dactl.UI.Application.get_default ();
        var channels = app.model.ctx.get_object_map_from_uri (typeof (Cld.MathChannel));

        liststore_math_chan.clear ();
        Gtk.TreeIter iter;
        foreach (var channel in channels.values) {
            liststore_math_chan.append (out iter);
            liststore_math_chan.set (iter, ChanColumns.ID, channel.id,
                ChanColumns.TAG, (channel as Cld.Channel).tag,
                ChanColumns.DESCRIPTION, (channel as Cld.Channel).desc,
                ChanColumns.CALIBRATION, (channel as Cld.ScalableChannel).calref,
                ChanColumns.URI, (channel as Cld.MathChannel).uri);
        }
    }

    private void create_coefficient_treeview_math () {
        treeview_coeff_math.set_model (liststore_coeff);
        treeview_coeff_math.insert_column_with_attributes
                (-1, "ID", new Gtk.CellRendererText (), "text", CoeffColumns.ID);
        treeview_coeff_math.insert_column_with_attributes
                (-1, "n", new Gtk.CellRendererText (), "text", CoeffColumns.N);
        var value_cell = new Gtk.CellRendererText ();
        value_cell.editable = true;
        treeview_coeff_math.insert_column_with_attributes
                (-1, "Value", value_cell, "text", CoeffColumns.VALUE);
        value_cell.edited.connect (value_cell_edited_math_cb);
    }

    [GtkCallback]
    private void row_activated_math_cb (Gtk.TreePath path, Gtk.TreeViewColumn column) {

        Cld.Calibration calibration;
        Cld.MathChannel channel;
        Gtk.TreeIter iter;
        string uri;

        var app = Dactl.UI.Application.get_default ();
        if (treeview_selection_math == null ) GLib.message ("selection is null");
        liststore_math_chan.get_iter (out iter, path);
        liststore_math_chan.get (iter, ChanColumns.URI, out uri);
        math_selected = app.model.ctx.get_object_from_uri (uri) as Cld.MathChannel;
        update_math_entries ();
        populate_math_coeff_treeview ();
    }

    private void populate_math_coeff_treeview () {
        Gtk.TreeIter iter;

        liststore_coeff.clear ();
        foreach (var coefficient in math_selected.calibration.coefficients.values) {
            liststore_coeff.append (out iter);
            liststore_coeff.set (iter, CoeffColumns.ID, coefficient.id,
                                 CoeffColumns.N, (coefficient as Cld.Coefficient).n,
                                 CoeffColumns.VALUE, (coefficient as Cld.Coefficient).value);
        }

        treeview_coeff_math.set_rules_hint (true);
        var path = new Gtk.TreePath.from_string ("0");
        treeview_coeff_math.set_cursor (path, null, false);
    }

    private void refresh_math_coeff_treeview () {
        Gtk.TreeIter iter;

        liststore_coeff.clear ();
        foreach (var coefficient in math_selected.calibration.coefficients.values) {
            liststore_coeff.append (out iter);
            liststore_coeff.set (iter, CoeffColumns.ID, coefficient.id,
                                 CoeffColumns.N, (coefficient as Cld.Coefficient).n,
                                 CoeffColumns.VALUE, (coefficient as Cld.Coefficient).value);
        }
    }

    private void update_math_entries () {
        /* Update entries */
        entry_tag_math.set_text (math_selected.tag);
        entry_desc_math.set_text (math_selected.desc);
        entry_expression_math.set_text (math_selected.expression);
        entry_alias_math.set_text (math_selected.alias);
        entry_cal_math.set_text (math_selected.calref);

        var app = Dactl.UI.Application.get_default ();
        var cal = app.model.ctx.get_object_from_uri (entry_cal_math.get_text ());
        entry_cal_units_math.set_text ((cal as Cld.Calibration).units);
    }

    [GtkCallback]
    private void entry_tag_math_activate_cb () {
        math_selected.tag = entry_tag_math.get_text ();
        refresh_math_treeview ();
    }

    [GtkCallback]
    private void entry_desc_math_activate_cb () {
        math_selected.desc = entry_desc_math.get_text ();
        refresh_math_treeview ();
    }

    [GtkCallback]
    private void entry_alias_math_activate_cb () {
        math_selected.alias = entry_alias_math.get_text ();
        refresh_math_treeview ();
    }

    [GtkCallback]
    private void entry_expression_math_activate_cb () {
        math_selected.expression = entry_expression_math.get_text ();
        refresh_math_treeview ();
    }

    [GtkCallback]
    private void entry_cal_math_activate_cb () {
        var app = Dactl.UI.Application.get_default ();
        var cal = app.model.ctx.get_object_from_uri (entry_cal_math.get_text ());
        if (cal != null) {
            math_selected.calibration = cal as Cld.Calibration;
            math_selected.calref = entry_cal_math.get_text ();
            refresh_math_treeview ();
            refresh_math_coeff_treeview ();
        } else {
            entry_cal_math.set_text ("invalid entry");
        }
    }

    [GtkCallback]
    private void entry_cal_units_math_activate_cb () {
        var app = Dactl.UI.Application.get_default ();
        var cal = app.model.ctx.get_object_from_uri (entry_cal_math.get_text ());
        math_selected.calibration.units = entry_cal_units_math.get_text ();
        refresh_math_treeview ();
    }

    private void value_cell_edited_math_cb (string path_string, string new_text) {
        int n;

        var app = Dactl.UI.Application.get_default ();
        var cal = app.model.ctx.get_object_from_uri (entry_cal_math.get_text ());

        Gtk.TreePath path = new Gtk.TreePath.from_string (path_string);
        Gtk.TreeIter iter;
        liststore_coeff.get_iter (out iter, path);
        liststore_coeff.get (iter, CoeffColumns.N, out n);
        liststore_coeff.set (iter, CoeffColumns.VALUE, double.parse (new_text));
        var coeff = (cal as Cld.Calibration).get_coefficient (n);
        (coeff as Cld.Coefficient).value = double.parse (new_text);

        GLib.message ("%s %s %s", path_string, new_text, coeff.uri);
        refresh_math_coeff_treeview ();
    }

    private void populate_ds_treeview () {
        var app = Dactl.UI.Application.get_default ();
        var dslist = app.model.ctx.get_object_map_from_uri (typeof (Cld.DataSeries));

        if (dslist.size > 0) {
            treeview_ds.set_model (liststore_ds);
            treeview_ds.insert_column_with_attributes
                (-1, "ID", new Gtk.CellRendererText (), "text", DSColumns.ID);
            treeview_ds.insert_column_with_attributes
                (-1, "Length", new Gtk.CellRendererText (), "text", DSColumns.LENGTH);
            treeview_ds.insert_column_with_attributes
                (-1, "URI", new Gtk.CellRendererText (), "text", DSColumns.URI);

            Gtk.TreeIter iter;
            foreach (var dataseries in dslist.values) {
                liststore_ds.append (out iter);
                liststore_ds.set (iter, DSColumns.ID, dataseries.id,
                    DSColumns.LENGTH, (dataseries as Cld.DataSeries).length,
                    DSColumns.URI, (dataseries as Cld.DataSeries).uri);
          }
            treeview_ds.set_rules_hint (true);
            var path = new Gtk.TreePath.first ();
            treeview_ds.set_cursor (path, null, false);
            row_activated_ds_cb (path, treeview_ds.get_column (0));
        }
    }

    private void setup_ds_chref_combobox () {
        Gtk.CellRendererText renderer = new Gtk.CellRendererText ();
        combobox_ds_chref.pack_start (renderer, true);
        combobox_ds_chref.add_attribute (renderer, "text", 0);
        combobox_ds_chref.active = 0;
    }

    private void refresh_ds_treeview () {
        var app = Dactl.UI.Application.get_default ();
        var dslist = app.model.ctx.get_object_map_from_uri (typeof (Cld.DataSeries));

        liststore_ds.clear ();
        Gtk.TreeIter iter;
        foreach (var dataseries in dslist.values) {
            liststore_ds.append (out iter);
            liststore_ds.set (iter, DSColumns.ID, dataseries.id,
                DSColumns.LENGTH, (dataseries as Cld.DataSeries).length,
                DSColumns.URI, (dataseries as Cld.DataSeries).uri);
        }
    }

    [GtkCallback]
    private void row_activated_ds_cb (Gtk.TreePath path, Gtk.TreeViewColumn column) {
        Gtk.TreeIter iter;
        string uri;

        var app = Dactl.UI.Application.get_default ();
        if (treeview_selection_ds == null ) GLib.message ("selection is null");
        liststore_ds.get_iter (out iter, path);
        liststore_ds.get (iter, DSColumns.URI, out uri);
        ds_selected = app.model.ctx.get_object_from_uri (uri) as Cld.DataSeries;
        message ("Dataseries URI selected: %s", ds_selected.uri);
        ignore_combobox_ds_changed = true;
        update_ds_entries ();
        ignore_combobox_ds_changed = false;
    }

    private void update_ds_entries () {
        Gtk.TreeIter iter;
        var app = Dactl.UI.Application.get_default ();
        var ch_list = app.model.ctx.get_object_map_from_uri (typeof (Cld.Channel));

        /* Populate selection list */
        liststore_ds_chref.clear ();
        liststore_ds_chref.append (out iter);
        liststore_ds_chref.set (iter, 0, (ds_selected as Cld.DataSeries).chref);
        foreach (var ch in ch_list.values) {
            if ((ch as Cld.Channel).uri != (ds_selected as Cld.DataSeries).chref) {
                liststore_ds_chref.append (out iter);
                liststore_ds_chref.set (iter, 0, (ch as Cld.Channel).uri);
            }
        }
        combobox_ds_chref.active = 0;

        /* Update entries */
        spinbutton_length_ds.set_value (ds_selected.length);
    }

    [GtkCallback]
    private void combobox_ds_chref_changed_cb () {
        Value chref;
        Gtk.TreeIter iter;
        var app = Dactl.UI.Application.get_default ();
        combobox_ds_chref.get_active_iter (out iter);

        if (!ignore_combobox_ds_changed) {
            liststore_ds_chref.get_value (iter, 0, out chref);
            (ds_selected as Cld.DataSeries).chref = (string) chref;
            message ("DataSeries %s references %s", (ds_selected as Cld.DataSeries).uri,
                        (ds_selected as Cld.DataSeries).chref);
        }
    }

    [GtkCallback]
    private void spinbutton_length_ds_value_changed_cb () {
        ds_selected.length = (int) spinbutton_length_ds.get_value ();
        refresh_ds_treeview ();
    }

    public void update_preferences () {
        update_ai_preferences ();
        update_ao_preferences ();
        update_di_preferences ();
        update_do_preferences ();
        update_math_preferences ();
        update_ds_preferences ();
    }

    private void update_ai_preferences () {
        string str;
        int i;
        Gtk.TreeIter iter;
        Cld.AIChannel chan;
        Gtk.TreePath path = new Gtk.TreePath.first ();

        var app = Dactl.UI.Application.get_default ();
        liststore_ai_chan.get_iter (out iter, path);
        /* Analog input */
        do {
            liststore_ai_chan.get (iter, ChanColumns.URI, out str);
            chan = app.model.ctx.get_object_from_uri (str) as Cld.AIChannel;
            liststore_ai_chan.get (iter, ChanColumns.NUM, out i);
            chan.num = i;
            liststore_ai_chan.get (iter, ChanColumns.TAG, out str);
            chan.tag = str;
            message ("tag for %s is %s", chan.uri, chan.tag);
            liststore_ai_chan.get (iter, ChanColumns.DESCRIPTION, out str);
            chan.desc = str;
            liststore_ai_chan.get (iter, ChanColumns.CALIBRATION, out str);
            chan.calref = str;
            liststore_ai_chan.get (iter, ChanColumns.AVERAGE, out i);
            chan.raw_value_list_size = i;
        } while (liststore_ai_chan.iter_next (ref iter));
    }

    private void update_ao_preferences () {

    }

    private void update_di_preferences () {

    }

    private void update_do_preferences () {

    }

    private void update_math_preferences () {

    }

    private void update_ds_preferences () {

    }
}
