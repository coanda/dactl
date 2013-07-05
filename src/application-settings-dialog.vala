using Cld;
using Gee;
using Gtk;

/* XXX Consider making each page their own widget that the dialog loads, this
 * would make it cleaner adding additional page types going forward. */

public class ApplicationSettingsDialog : Dialog {

    private ApplicationData data;
    private Gtk.Builder builder;
    private int tab_id;

    /* Application */
    private Gtk.Widget device_treeview;
    private Gtk.Widget lbl_app_name;
    private Gtk.Widget lbl_app_config;
    private Gtk.Widget lbl_daq_rate;
    private Gtk.Widget scrolledwindow_devices;
    private Gtk.Widget entry_dev_id;
    private Gtk.Widget entry_dev_desc;
    private Gtk.Widget entry_dev_file;

    /* Logging */
    private Gtk.Widget log_treeview;
    private Gtk.Widget scrolledwindow_logs;
    private Gtk.Widget entry_log_id;
    private Gtk.Widget entry_log_title;
    private Gtk.Widget entry_log_format;
    private Gtk.Widget btn_log_rate;
    private Gtk.Widget entry_log_path;
    private Gtk.Widget entry_log_file;

    /* Channel */
    private Gtk.Widget channel_notebook;

    /* - AIChannel */
    private Gtk.Widget aichannel_treeview;
    private Gtk.Widget scrolledwindow_aichannel;
    private Gtk.Widget scrolledwindow_aichannel_coefficients;
    private Gtk.Widget? coefficient_treeview = null;
    private Gtk.Widget entry_aichannel_id;
    private Gtk.Widget entry_aichannel_devref;
    private Gtk.Widget entry_aichannel_tag;
    private Gtk.Widget entry_aichannel_desc;
    private Gtk.Widget entry_aichannel_num;

    /* - AOChannel */
    private Gtk.Widget scrolledwindow_aochannel;
    private Gtk.Widget aochannel_treeview;

    /* - DIChannel */
    private Gtk.Widget scrolledwindow_dichannel;

    /* - DOChannel */
    private Gtk.Widget scrolledwindow_dochannel;

    /* - VChannel */
    private Gtk.Widget scrolledwindow_vchannel;

    /* Traverse */
    private Gtk.Widget scrolledwindow_traverse;
    private Gtk.Widget velmex_settings_box;
    /*
     *private Gtk.Widget btn_traverse_execute_prog;
     *private Gtk.Widget btn_traverse_open_prog;
     *private Gtk.Widget textview_traverse;           [> XXX may not need <]
     *private Gtk.Widget textbuffer_traverse;
     *private Gtk.Widget entry_traverse_port;
     *private Gtk.Widget cmb_traverse_baudrate;
     *private Gtk.Widget cmb_traverse_parity;
     *private Gtk.Widget cmb_traverse_stopbits;
     *private Gtk.Widget cmb_traverse_bytesize;
     */

    construct {
        string path = GLib.Path.build_filename (Config.DATADIR,
                                                "settings_dialog.ui");
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

    public ApplicationSettingsDialog (ApplicationData data) {
        this.data = data;

        create_dialog ();
        set_default_size (800, 600);
        populate_application_page ();
        populate_logging_page ();
        populate_channel_page ();
        populate_traverse_page ();
        show_all ();
        connect_signals ();
    }

    public ApplicationSettingsDialog.with_startup_tab_id (ApplicationData data, int tab_id) {
        this.data = data;
        this.tab_id = tab_id;

        create_dialog ();
        set_default_size (800, 600);
        populate_application_page ();
        populate_logging_page ();
        populate_channel_page ();
        populate_traverse_page ();
        show_all ();
        connect_signals ();

        var notebook = builder.get_object ("notebook");
        (notebook as Gtk.Notebook).set_current_page (tab_id);
    }

    private void create_dialog () {
        var content = get_content_area ();
        var action = get_action_area ();
        var dialog = builder.get_object ("settings_dialog") as Gtk.Widget;

        /* Load everything */

        var _content = (dialog as Dialog).get_content_area ();
        _content.reparent (content);

        title = "Application Settings";

        add_button (Stock.APPLY, ResponseType.APPLY);
        add_button (Stock.OK, ResponseType.OK);
        add_button (Stock.CANCEL, ResponseType.CANCEL);
        action.show_all ();
        content.show_all ();
    }

    private void populate_application_page () {
        Cld.XmlConfig xml = data.xml;
        string app_name = xml.value_at_xpath ("//cld/property[@name=\"app\"]");

        lbl_app_name = builder.get_object ("lbl_app_name") as Gtk.Widget;
        lbl_app_config = builder.get_object ("lbl_app_config") as Gtk.Widget;
        lbl_daq_rate = builder.get_object ("lbl_daq_rate") as Gtk.Widget;

        scrolledwindow_devices = builder.get_object ("scrolledwindow_devices") as Gtk.Widget;
        device_treeview = new DeviceTreeView (data.devices);
        (scrolledwindow_devices as ScrolledWindow).add (device_treeview);

        /* These get updated in a callback */
        entry_dev_id = builder.get_object ("entry_dev_id") as Gtk.Widget;
        entry_dev_desc = builder.get_object ("entry_dev_desc") as Gtk.Widget;
        entry_dev_file = builder.get_object ("entry_dev_file") as Gtk.Widget;

        (lbl_app_name as Gtk.Label).label = app_name;
        (lbl_app_config as Gtk.Label).label = data.xml_file;

        var cld_builder = data.builder;
        var daq = cld_builder.get_object ("daq0");
        (lbl_daq_rate as Gtk.Label).label = "%.1f".printf ((daq as Cld.Daq).rate);
    }

    private void populate_logging_page () {
        Cld.Builder cld_builder = data.builder;

        scrolledwindow_logs = builder.get_object ("scrolledwindow_logs") as Gtk.Widget;
        log_treeview = new LogTreeView (cld_builder.logs);
        (scrolledwindow_logs as ScrolledWindow).add (log_treeview);

        /* These get updated in a callback */
        entry_log_id = builder.get_object ("entry_log_id") as Gtk.Widget;
        entry_log_title = builder.get_object ("entry_log_title") as Gtk.Widget;
        entry_log_format = builder.get_object ("entry_log_format") as Gtk.Widget;
        btn_log_rate = builder.get_object ("btn_log_rate") as Gtk.Widget;
        entry_log_path = builder.get_object ("entry_log_path") as Gtk.Widget;
        entry_log_file = builder.get_object ("entry_log_file") as Gtk.Widget;
    }

    private void populate_channel_page () {
        channel_notebook = builder.get_object ("channel_notebook") as Gtk.Widget;

        scrolledwindow_aichannel = builder.get_object ("scrolledwindow_aichannel") as Gtk.Widget;
        aichannel_treeview = new AIChannelTreeView (data.ai_channels);
        (scrolledwindow_aichannel as ScrolledWindow).add (aichannel_treeview);

        scrolledwindow_aochannel = builder.get_object ("scrolledwindow_aochannel") as Gtk.Widget;
        aochannel_treeview = new AOChannelTreeView (data.ao_channels);
        (scrolledwindow_aochannel as ScrolledWindow).add (aochannel_treeview);

        /* XXX these aren't implemented yet */
        scrolledwindow_dichannel = builder.get_object ("scrolledwindow_dichannel") as Gtk.Widget;
        scrolledwindow_dochannel = builder.get_object ("scrolledwindow_dochannel") as Gtk.Widget;
        scrolledwindow_vchannel = builder.get_object ("scrolledwindow_vchannel") as Gtk.Widget;

        /* Updated in a callback */
        scrolledwindow_aichannel_coefficients = builder.get_object ("scrolledwindow_aichannel_coefficients") as Gtk.Widget;
        entry_aichannel_id = builder.get_object ("entry_aichannel_id") as Gtk.Widget;
        entry_aichannel_devref = builder.get_object ("entry_aichannel_devref") as Gtk.Widget;
        entry_aichannel_tag = builder.get_object ("entry_aichannel_tag") as Gtk.Widget;
        entry_aichannel_desc = builder.get_object ("entry_aichannel_desc") as Gtk.Widget;
        entry_aichannel_num = builder.get_object ("entry_aichannel_num") as Gtk.Widget;

    }

    private void populate_traverse_page () {
        /* XXX This will be implemented later on, just a placeholder for now */
        /*
         *btn_traverse_execute_prog = builder.get_object ("btn_traverse_execute_prog") as Gtk.Widget;
         *btn_traverse_open_prog = builder.get_object ("btn_traverse_open_prog") as Gtk.Widget;
         *textview_traverse = builder.get_object ("textview_traverse") as Gtk.Widget;
         *textbuffer_traverse = builder.get_object ("textbuffer_traverse") as Gtk.Widget;
         *entry_traverse_port = builder.get_object ("entry_traverse_port") as Gtk.Widget;
         *cmb_traverse_baudrate = builder.get_object ("cmb_traverse_baudrate") as Gtk.Widget;
         *cmb_traverse_parity = builder.get_object ("cmb_traverse_parity") as Gtk.Widget;
         *cmb_traverse_stopbits = builder.get_object ("cmb_traverse_stopbits") as Gtk.Widget;
         *cmb_traverse_bytesize = builder.get_object ("cmb_traverse_bytesize") as Gtk.Widget;
         */

        scrolledwindow_traverse = builder.get_object ("scrolledwindow_traverse") as Gtk.Widget;

        var alignment = new Alignment (0.50f, 0.50f, 1.0f, 1.0f);
        alignment.top_padding = 5;
        alignment.right_padding = 5;
        alignment.bottom_padding = 5;
        alignment.left_padding = 5;

        var traverse_box = new Box (Orientation.VERTICAL, 10);

        foreach (var module in data.modules.values) {
            if (module is VelmexModule) {
                /* pack module content */
                velmex_settings_box = new VelmexSettingsBox (module as Cld.Module);
                traverse_box.pack_start (velmex_settings_box, true, true, 0);
            }
        }

        alignment.add (traverse_box);
        (scrolledwindow_traverse as Gtk.ScrolledWindow).add_with_viewport (alignment);
    }

    private void connect_signals () {
        this.response.connect (response_cb);

        (channel_notebook as Gtk.Notebook).switch_page.connect (channel_notebook_switch_page_cb);

        /* Callbacks for various TreeView widgets */
        (device_treeview as TreeView).cursor_changed.connect (device_cursor_changed_cb);
        (log_treeview as TreeView).cursor_changed.connect (log_cursor_changed_cb);
        (aichannel_treeview as TreeView).cursor_changed.connect (aichannel_cursor_changed_cb);
        (aochannel_treeview as TreeView).cursor_changed.connect (aochannel_cursor_changed_cb);
        //(coefficient_treeview as TreeView).cursor_changed.connect (coefficient_cursor_changed_cb);
    }

    private void response_cb (Dialog source, int response_id) {
        Cld.debug ("Response ID: %d\n", response_id);
        switch (response_id) {
            case ResponseType.OK:
                update_config ();
                break;
            case ResponseType.CANCEL:
                hide ();
                break;
            case ResponseType.APPLY:
                update_config ();
                break;
           case ResponseType.DELETE_EVENT:
                /* Probably want to track changes and inform user they may
                 * be lost if any were made */
                destroy ();
                break;
        }
    }

    private void channel_notebook_switch_page_cb (Gtk.Widget page, uint page_num) {
        Gtk.Widget channel_settings_notebook = builder.get_object ("channel_settings_notebook") as Gtk.Widget;
        (channel_settings_notebook as Gtk.Notebook).set_current_page ((int)page_num);
    }

    private void device_cursor_changed_cb () {
        string id;
        TreeModel model;
        TreeIter iter;
        TreeSelection selection;
        Cld.Builder cld_builder = data.builder;
        Cld.Object device;

        selection = (device_treeview as Gtk.TreeView).get_selection ();
        selection.get_selected (out model, out iter);
        model.get (iter, DeviceTreeView.Columns.ID, out id);

        device = cld_builder.get_object (id);

        (entry_dev_id as Gtk.Entry).set_text (id);
        (entry_dev_desc as Gtk.Entry).set_text ((device as Cld.Device).description);
        (entry_dev_file as Gtk.Entry).set_text ((device as Cld.Device).filename);
    }

    private void log_cursor_changed_cb () {
        string id;
        TreeModel model;
        TreeIter iter;
        TreeSelection selection;
        Cld.Builder cld_builder = data.builder;
        Cld.Object log;

        selection = (log_treeview as Gtk.TreeView).get_selection ();
        selection.get_selected (out model, out iter);
        model.get (iter, LogTreeView.Columns.ID, out id);

        log = cld_builder.get_object (id);

        (entry_log_id as Gtk.Entry).set_text (id);
        (entry_log_title as Gtk.Entry).set_text ((log as Cld.Log).name);
        (entry_log_format as Gtk.Entry).set_text ((log as Cld.Log).date_format);
        (btn_log_rate as Gtk.SpinButton).set_value ((log as Cld.Log).rate);
        (entry_log_path as Gtk.Entry).set_text ((log as Cld.Log).path);
        (entry_log_file as Gtk.Entry).set_text ((log as Cld.Log).file);
    }

    private void aichannel_cursor_changed_cb () {
        string id;
        TreeModel model;
        TreeIter iter;
        TreeSelection selection;
        Cld.Builder cld_builder = data.builder;
        Cld.Object channel;

        selection = (aichannel_treeview as Gtk.TreeView).get_selection ();
        selection.get_selected (out model, out iter);
        model.get (iter, AIChannelTreeView.Columns.ID, out id);

        channel = cld_builder.get_object (id);

        (entry_aichannel_id as Gtk.Entry).set_text (id);
        (entry_aichannel_devref as Gtk.Entry).set_text ((channel as Cld.Channel).devref);
        (entry_aichannel_tag as Gtk.Entry).set_text ((channel as Cld.Channel).tag);
        (entry_aichannel_desc as Gtk.Entry).set_text ((channel as Cld.Channel).desc);
        (entry_aichannel_num as Gtk.Entry).set_text ("%d".printf ((channel as Cld.Channel).num));

        /* Populate coefficient list */
        var calibration = (channel as ScalableChannel).calibration;
        if (coefficient_treeview != null) {
            (scrolledwindow_aichannel_coefficients as Gtk.Container).remove (coefficient_treeview);
            coefficient_treeview = null;
        }
        coefficient_treeview = new CoefficientTreeView (calibration.coefficients);
        (coefficient_treeview as CoefficientTreeView).change_confirmed.connect (coefficient_treeview_change_confirmed_cb);
        (scrolledwindow_aichannel_coefficients as ScrolledWindow).add (coefficient_treeview);
        scrolledwindow_aichannel_coefficients.show_all ();
    }

    private void aochannel_cursor_changed_cb () {
        string id;
        TreeModel model;
        TreeIter iter;
        TreeSelection selection;
        Cld.Builder cld_builder = data.builder;
        Cld.Object channel;

        selection = (aochannel_treeview as Gtk.TreeView).get_selection ();
        selection.get_selected (out model, out iter);
        model.get (iter, AOChannelTreeView.Columns.ID, out id);

        channel = cld_builder.get_object (id);
    }

    private void coefficient_treeview_change_confirmed_cb (string coefficient_id, double value) {
        string id;
        TreeModel model;
        TreeIter iter;
        TreeSelection selection;
        Cld.Builder cld_builder = data.builder;
        Cld.Object channel;

        /* Find out which channel needs to be updated */
        selection = (aichannel_treeview as Gtk.TreeView).get_selection ();
        selection.get_selected (out model, out iter);
        model.get (iter, AIChannelTreeView.Columns.ID, out id);

        Cld.debug ("Coefficient %s was changed to %f for channel %s\n", coefficient_id, value, id);
        channel = cld_builder.get_object (id);
        var calibration = (channel as ScalableChannel).calibration;
        var coefficient = calibration.get_object (coefficient_id);
        (coefficient as Cld.Coefficient).value = value;
    }

    private void update_config () {
        /* Doing this as multiple separate functions because it might simplify
         * the per-panel update I have in mind */

        update_application_config ();
        update_log_config ();
        update_aichannel_config ();
        update_aochannel_config ();
        update_dichannel_config ();
        update_dochannel_config ();
        update_vchannel_config ();
        update_traverse_config ();
    }

    private void update_application_config () {
    }

    private void update_log_config () {
        Cld.Builder cld_builder = data.builder;

        var log = cld_builder.get_object ((entry_log_id as Gtk.Entry).text);
        (log as Cld.Log).name = (entry_log_title as Gtk.Entry).text;
        (log as Cld.Log).date_format = (entry_log_format as Gtk.Entry).text;
        (log as Cld.Log).rate = (btn_log_rate as Gtk.SpinButton).get_value ();
        Cld.debug ("log_rate: %.3f  get_value: %.3f\n", (log as Cld.Log).rate, (btn_log_rate as Gtk.SpinButton).get_value ());

        (log as Cld.Log).path = (entry_log_path as Gtk.Entry).text;
        (log as Cld.Log).file = (entry_log_file as Gtk.Entry).text;
    }

    private void update_aichannel_config () {
        Cld.Builder cld_builder = data.builder;

        var channel = cld_builder.get_object ((entry_aichannel_id as Gtk.Entry).text);
        (channel as Cld.Channel).devref = (entry_aichannel_devref as Gtk.Entry).text;
        (channel as Cld.Channel).tag = (entry_aichannel_tag as Gtk.Entry).text;
        (channel as Cld.Channel).desc = (entry_aichannel_desc as Gtk.Entry).text;
        (channel as Cld.Channel).num = int.parse ((entry_aichannel_num as Gtk.Entry).text);
    }

    private void update_aochannel_config () {
    }

    private void update_dichannel_config () {
    }

    private void update_dochannel_config () {
    }

    private void update_vchannel_config () {
    }

    private void update_traverse_config () {
    }

}
