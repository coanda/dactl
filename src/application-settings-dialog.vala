using Cld;
using Gee;
using Gtk;

/* XXX Consider making each page their own widget that the dialog loads, this
 * would make it cleaner adding additional page types going forward. */

public class ApplicationSettingsDialog : Dialog {

    private ApplicationModel model;
    private Gtk.Builder builder;
    private Cld.Builder cld_builder;
    private int tab_id;
    private Gtk.Widget btn_apply;
    private Gtk.Widget btn_ok;
    private Gtk.Widget btn_cancel;

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
    private Gtk.Widget channel_settings_notebook;
    private int        channel_settings_notebook_page_num;
    private Gtk.Widget entry_channel_id;
    private Gtk.Widget entry_channel_devref;
    private Gtk.Widget entry_channel_tag;
    private Gtk.Widget entry_channel_desc;
    private Gtk.Widget entry_channel_num;
    private string     channel_settings_notebook_page_text;

    /* - ScalableChannel */
    private Gtk.Widget scrolledwindow_channel_coefficients;
    private Gtk.Widget? coefficient_treeview = null;

    /* - AIChannel */
    private Gtk.Widget aichannel_treeview;
    private Gtk.Widget scrolledwindow_aichannel;

    /* - AOChannel */
    private Gtk.Widget aochannel_treeview;
    private Gtk.Widget scrolledwindow_aochannel;

    /* - DIChannel */
    private Gtk.Widget dichannel_treeview;
    private Gtk.Widget scrolledwindow_dichannel;

    /* - DOChannel */
    private Gtk.Widget dochannel_treeview;
    private Gtk.Widget scrolledwindow_dochannel;

    /* - VChannel */
    private Gtk.Widget vchannel_treeview;
    private Gtk.Widget scrolledwindow_vchannel;

    /* - Module */
    private Gtk.Widget module_treeview;
    private Gtk.Widget scrolledwindow_module_tv;
    private Gtk.Widget scrolledwindow_module_view1;
    private Gtk.Widget scrolledwindow_module_view2;
    /* Traverse */
    //private Gtk.Widget scrolledwindow_traverse;
    //private Gtk.Widget velmex_settings_box;
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
        string path = GLib.Path.build_filename (Config.UI_DIR,
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

    public ApplicationSettingsDialog (ApplicationModel model) {
        this.model = model;
        cld_builder = model.builder;

        create_dialog ();
        set_default_size (800, 600);
        populate_application_page ();
        populate_logging_page ();
        populate_channel_page ();
        populate_module_page ();
        //populate_traverse_page ();
        connect_signals ();
        show_all ();
    }

    public ApplicationSettingsDialog.with_startup_tab_id (ApplicationModel model, int tab_id) {
        this.model = model;
        this.tab_id = tab_id;
        cld_builder = model.builder;

        create_dialog ();
        set_default_size (800, 600);
        populate_application_page ();
        populate_logging_page ();
        populate_channel_page ();
        populate_module_page ();
        //populate_traverse_page ();
        connect_signals ();
        var notebook = builder.get_object ("notebook");
        (notebook as Notebook).switch_page.connect (notebook_switch_page_cb);
        (notebook as Gtk.Notebook).set_current_page (tab_id);
        show_all ();
    }

    private void create_dialog () {
        var content = get_content_area ();
        var action = get_action_area ();
        var dialog = builder.get_object ("settings_dialog") as Gtk.Widget;

        /* Load everything */

        var _content = (dialog as Dialog).get_content_area ();
        _content.reparent (content);
        var _action = (dialog as Dialog).get_action_area ();
        _action.reparent (action);
        title = "Application Settings";

        btn_apply = add_button (Stock.APPLY, ResponseType.APPLY);
        btn_ok = add_button (Stock.OK, ResponseType.OK);
        btn_cancel = add_button (Stock.CANCEL, ResponseType.CANCEL);
        action.show_all ();
        content.show_all ();
    }

    private void populate_application_page () {
        Cld.XmlConfig xml = model.xml;
        string app_name = xml.value_at_xpath ("//cld/property[@name=\"app\"]");

        lbl_app_name = builder.get_object ("lbl_app_name") as Gtk.Widget;
        lbl_app_config = builder.get_object ("lbl_app_config") as Gtk.Widget;
        lbl_daq_rate = builder.get_object ("lbl_daq_rate") as Gtk.Widget;

        scrolledwindow_devices = builder.get_object ("scrolledwindow_devices") as Gtk.Widget;
        device_treeview = new DeviceTreeView (model.devices);
        (scrolledwindow_devices as ScrolledWindow).add (device_treeview);

        /* These get updated in a callback */
        entry_dev_id = builder.get_object ("entry_dev_id") as Gtk.Widget;
        entry_dev_desc = builder.get_object ("entry_dev_desc") as Gtk.Widget;
        entry_dev_file = builder.get_object ("entry_dev_file") as Gtk.Widget;

        (lbl_app_name as Gtk.Label).label = app_name;
        (lbl_app_config as Gtk.Label).label = model.xml_file;

        var cld_builder = model.builder;
        var daq = cld_builder.get_object ("daq0");
        (lbl_daq_rate as Gtk.Label).label = "%.1f".printf ((daq as Cld.Daq).rate);
    }

    private void populate_logging_page () {
        Cld.Builder cld_builder = model.builder;

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
        TreePath treepath = new TreePath.first ();
        channel_settings_notebook = builder.get_object ("channel_notebook") as Gtk.Widget;

        scrolledwindow_aichannel = builder.get_object ("scrolledwindow_aichannel") as Gtk.Widget;
        aichannel_treeview = new AIChannelTreeView (model.ai_channels);
        (aichannel_treeview as TreeView).set_cursor (treepath, null, false);
        (scrolledwindow_aichannel as ScrolledWindow).add (aichannel_treeview);

        scrolledwindow_aochannel = builder.get_object ("scrolledwindow_aochannel") as Gtk.Widget;
        aochannel_treeview = new AOChannelTreeView (model.ao_channels);
        (aochannel_treeview as TreeView).set_cursor (treepath, null, false);
        (scrolledwindow_aochannel as ScrolledWindow).add (aochannel_treeview);

        scrolledwindow_dichannel = builder.get_object ("scrolledwindow_dichannel") as Gtk.Widget;
        dichannel_treeview = new DIChannelTreeView (model.di_channels);
        (dichannel_treeview as TreeView).set_cursor (treepath, null, false);
        (scrolledwindow_dichannel as ScrolledWindow).add (dichannel_treeview);

        scrolledwindow_dochannel = builder.get_object ("scrolledwindow_dochannel") as Gtk.Widget;
        dochannel_treeview = new DOChannelTreeView (model.do_channels);
        (dochannel_treeview as TreeView).set_cursor (treepath, null, false);
        (scrolledwindow_dochannel as ScrolledWindow).add (dochannel_treeview);

        scrolledwindow_vchannel = builder.get_object ("scrolledwindow_vchannel") as Gtk.Widget;
        vchannel_treeview = new VChannelTreeView (model.vchannels);
        (vchannel_treeview as TreeView).set_cursor (treepath, null, false);
        (scrolledwindow_vchannel as ScrolledWindow).add (vchannel_treeview);

        /* Updated in a callback */
        scrolledwindow_channel_coefficients = builder.get_object ("scrolledwindow_channel_coefficients") as Gtk.Widget;
        entry_channel_id = builder.get_object ("entry_channel_id") as Gtk.Widget;
        entry_channel_devref = builder.get_object ("entry_channel_devref") as Gtk.Widget;
        entry_channel_tag = builder.get_object ("entry_channel_tag") as Gtk.Widget;
        entry_channel_desc = builder.get_object ("entry_channel_desc") as Gtk.Widget;
        entry_channel_num = builder.get_object ("entry_channel_num") as Gtk.Widget;

    }

    private void populate_module_page () {
        TreePath treepath = new TreePath.first ();
        scrolledwindow_module_tv = builder.get_object ("scrolledwindow_module_tv") as Gtk.Widget;
        scrolledwindow_module_view1 = builder.get_object ("scrolledwindow_module_view1") as Gtk.Widget;
        scrolledwindow_module_view2 = builder.get_object ("scrolledwindow_module_view2") as Gtk.Widget;
        module_treeview = new ModuleTreeView (model.modules);
        (module_treeview as TreeView).set_cursor (treepath, null, false);
        (scrolledwindow_module_tv as ScrolledWindow).add (module_treeview);
    }

//    private void populate_traverse_page () {
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
//
//        scrolledwindow_traverse = builder.get_object ("scrolledwindow_traverse") as Gtk.Widget;
//
//        var alignment = new Alignment (0.50f, 0.50f, 1.0f, 1.0f);
//        alignment.top_padding = 5;
//        alignment.right_padding = 5;
//        alignment.bottom_padding = 5;
//        alignment.left_padding = 5;
//
//        var traverse_box = new Box (Orientation.VERTICAL, 10);
//
//        foreach (var module in model.modules.values) {
//            if (module is VelmexModule) {
//                /* pack module content */
//                velmex_settings_box = new VelmexSettingsBox (module as Cld.Module);
//                traverse_box.pack_start (velmex_settings_box, true, true, 0);
//            }
//        }
//
//        alignment.add (traverse_box);
//        (scrolledwindow_traverse as Gtk.ScrolledWindow).add_with_viewport (alignment);
//    }

    private void connect_signals () {
       // this.response.connect (response_cb);
        (channel_settings_notebook as Gtk.Notebook).switch_page.connect (channel_notebook_switch_page_cb);

        /* Callbacks for various TreeView widgets */
        (device_treeview as TreeView).cursor_changed.connect (device_cursor_changed_cb);
        (log_treeview as TreeView).cursor_changed.connect (log_cursor_changed_cb);
        (aichannel_treeview as TreeView).cursor_changed.connect (scalable_channel_cursor_changed_cb);
        (aochannel_treeview as TreeView).cursor_changed.connect (scalable_channel_cursor_changed_cb);
        (vchannel_treeview as TreeView).cursor_changed.connect (scalable_channel_cursor_changed_cb);
        (dichannel_treeview as TreeView).cursor_changed.connect (di_channel_cursor_changed_cb);
        (dochannel_treeview as TreeView).cursor_changed.connect (do_channel_cursor_changed_cb);
        (module_treeview as TreeView).cursor_changed.connect (module_cursor_changed_cb);
    }

    public void response_cb (Dialog source, int response_id) {
        Cld.debug ("Response ID: %d\n", response_id);
        switch (response_id) {
            case ResponseType.OK:
                Cld.debug ("OK\n");
                update_config ();
                Cld.debug ("updated (ok)\n");
                hide ();
                break;
            case ResponseType.CANCEL:
                hide ();
                break;
            case ResponseType.APPLY:
                Cld.debug ("Apply\n");
                update_config ();
                Cld.debug ("updated (apply)\n");
                break;
           case ResponseType.DELETE_EVENT:
                /* Probably want to track changes and inform user they may
                 * be lost if any were made */
                Cld.debug ("Delete Event\n");
                destroy ();
                Cld.debug ("destroyed");
                break;
        }
    }

    private void notebook_switch_page_cb (Gtk.Widget page, uint page_num) {
        Channel channel;

        if (page_num == 2) {
            channel = get_selected_channel ();
            update_channel_entry_text (channel);
            populate_coefficient_treeview (channel);
        }
    }

    private void channel_notebook_switch_page_cb (Gtk.Widget page, uint page_num) {
        Channel channel;
        TreePath treepath = new TreePath.first ();
        TreePath cftreepath = new TreePath ();
        Gtk.Widget current_page;

        channel_settings_notebook_page_num = (int) page_num;
        current_page = (channel_settings_notebook as Notebook).get_nth_page (channel_settings_notebook_page_num);
        channel_settings_notebook_page_text = (channel_settings_notebook as Notebook).get_tab_label_text (current_page);
        switch (channel_settings_notebook_page_text) {
            case "Analog Input":
                (aichannel_treeview as TreeView).set_cursor (treepath, null, false);
                channel = get_selected_channel ();
                update_channel_entry_text (channel);
                Cld.debug ("Analog Input tab selected. Channel: %s\n", channel.id);
                populate_coefficient_treeview (channel);
                break;
            case "Analog Output":
                (aochannel_treeview as TreeView).set_cursor (treepath, null, false);
                channel = get_selected_channel ();
                update_channel_entry_text (channel);
                Cld.debug ("Analog Output tab selected. Channel: %s\n", channel.id);
                populate_coefficient_treeview (channel);
                break;
            case "Digital Input":
                (dichannel_treeview as TreeView).set_cursor (treepath, null, false);
                channel = get_selected_channel ();
                update_channel_entry_text (channel);
                break;
            case "Digital Output":
                (dochannel_treeview as TreeView).set_cursor (treepath, null, false);
                channel = get_selected_channel ();
                update_channel_entry_text (channel);
                break;
            case "Virtual":
                (vchannel_treeview as TreeView).set_cursor (treepath, null, false);
                channel = get_selected_channel ();
                update_channel_entry_text (channel);
                break;
            default:
                break;
        }
    }

    private void populate_coefficient_treeview (Channel channel) {
        var calibration = (channel as ScalableChannel).calibration;
        if (coefficient_treeview != null) {
            (scrolledwindow_channel_coefficients as Gtk.Container).remove (coefficient_treeview);
            coefficient_treeview = null;
        }
        coefficient_treeview = new CoefficientTreeView (calibration.coefficients);
        (coefficient_treeview as CoefficientTreeView).change_confirmed.connect (coefficient_treeview_change_confirmed_cb);
        (scrolledwindow_channel_coefficients as ScrolledWindow).add (coefficient_treeview);
        scrolledwindow_channel_coefficients.show_all ();
    }


    private void device_cursor_changed_cb () {
        string id;
        TreeModel tree_model;
        TreeIter iter;
        TreeSelection selection;
        Cld.Builder cld_builder = this.model.builder;
        Cld.Object device;

        selection = (device_treeview as Gtk.TreeView).get_selection ();
        selection.get_selected (out tree_model, out iter);
        tree_model.get (iter, DeviceTreeView.Columns.ID, out id);

        device = cld_builder.get_object (id);

        (entry_dev_id as Gtk.Entry).set_text (id);
        (entry_dev_desc as Gtk.Entry).set_text ((device as Cld.Device).description);
        (entry_dev_file as Gtk.Entry).set_text ((device as Cld.Device).filename);
    }

    private void log_cursor_changed_cb () {
        string id;
        TreeModel tree_model;
        TreeIter iter;
        TreeSelection selection;
        Cld.Builder cld_builder = this.model.builder;
        Cld.Object log;

        selection = (log_treeview as Gtk.TreeView).get_selection ();
        selection.get_selected (out tree_model, out iter);
        tree_model.get (iter, LogTreeView.Columns.ID, out id);

        log = cld_builder.get_object (id);

        (entry_log_id as Gtk.Entry).set_text (id);
        (entry_log_title as Gtk.Entry).set_text ((log as Cld.Log).name);
        (entry_log_format as Gtk.Entry).set_text ((log as Cld.Log).date_format);
        (btn_log_rate as Gtk.SpinButton).set_value ((log as Cld.Log).rate);
        (entry_log_path as Gtk.Entry).set_text ((log as Cld.Log).path);
        (entry_log_file as Gtk.Entry).set_text ((log as Cld.Log).file);
    }

    private void scalable_channel_cursor_changed_cb () {
        Channel channel;

        channel = get_selected_channel ();
        update_channel_entry_text (channel);

        /* Populate coefficient list */
        var calibration = (channel as ScalableChannel).calibration;
        if (coefficient_treeview != null) {
            (scrolledwindow_channel_coefficients as Gtk.Container).remove (coefficient_treeview);
            coefficient_treeview = null;
        }
        coefficient_treeview = new CoefficientTreeView (calibration.coefficients);
        (coefficient_treeview as CoefficientTreeView).change_confirmed.connect (coefficient_treeview_change_confirmed_cb);
        (scrolledwindow_channel_coefficients as ScrolledWindow).add (coefficient_treeview);
        scrolledwindow_channel_coefficients.show_all ();
    }

    private void di_channel_cursor_changed_cb () {
        Channel channel;
        channel = get_selected_channel ();
        update_channel_entry_text (channel);
    }

    private void do_channel_cursor_changed_cb () {
        Channel channel;
        channel = get_selected_channel ();
        update_channel_entry_text (channel);
    }

    private void coefficient_treeview_change_confirmed_cb (string coefficient_id, double value) {
        Channel channel;

        channel = get_selected_channel ();
//        Cld.debug ("Coefficient %s will change to %f for channel %s\n", coefficient_id, value, channel.id);
        var coefficients = (coefficient_treeview as CoefficientTreeView).coefficients;
        foreach (var coefficient in coefficients.values) {
            if ((coefficient as Coefficient).id == coefficient_id) {
                (coefficient as Coefficient).value = value;
//                    Cld.debug ("%s %.3f\n", (coefficient as Coefficient).id, (coefficient as Coefficient).value);
            }
        }
    }

    private Channel? get_selected_channel () {
        string id;
        string text;
        int column = -1;
        Gtk.Widget current_page;
        TreeView view = new TreeView ();
        TreeModel tree_model;
        TreeIter iter;
        TreeSelection selection;
        Cld.Object channel;

        /* Find out which channel needs to be updated */
        current_page = (channel_settings_notebook as Notebook).get_nth_page (channel_settings_notebook_page_num);
        channel_settings_notebook_page_text = (channel_settings_notebook as Notebook).get_tab_label_text (current_page);
        Cld.debug ("get_selected_channel (): %s page: channel_settings_notebook_page_num: %d\n",
                   channel_settings_notebook_page_text,
                   channel_settings_notebook_page_num);

        switch (channel_settings_notebook_page_text) {
            case "Analog Input":
                if (model.ai_channels.size == 0) {
                    return null;
                }
                view = (aichannel_treeview as TreeView);
                column = AIChannelTreeView.Columns.ID;
                break;
            case "Analog Output":
                if (model.ao_channels.size == 0) {
                    return null;
                }
                view = (aochannel_treeview as TreeView);
                column = AOChannelTreeView.Columns.ID;
                break;
            case "Digital Input":
                if (model.di_channels.size == 0) {
                    return null;
                }
                view = (dichannel_treeview as TreeView);
                column = DIChannelTreeView.Columns.ID;
                break;
            case "Digital Output":
                if (model.do_channels.size == 0) {
                    return null;
                }
                view = (dochannel_treeview as TreeView);
                column = DOChannelTreeView.Columns.ID;
                break;
            case "Virtual":
                if (model.vchannels.size == 0) {
                    return null;
                }
                view = (vchannel_treeview as TreeView);
                column = VChannelTreeView.Columns.ID;
                break;
            default:
                break;
        }

        selection = (view as Gtk.TreeView).get_selection ();
        if (selection == null ) GLib.message ("selection is null");
        selection.get_selected (out tree_model, out iter);
        tree_model.get (iter, column, out id);

        channel = cld_builder.get_object (id);
        Cld.debug ("    channel.id: %s\n", channel.id);

        return channel as Channel;
    }

    private void update_channel_entry_text (Channel channel) {
        (entry_channel_id as Gtk.Entry).set_text (channel.id);
        (entry_channel_devref as Gtk.Entry).set_text ((channel as Cld.Channel).devref);
        (entry_channel_tag as Gtk.Entry).set_text ((channel as Cld.Channel).tag);
        (entry_channel_desc as Gtk.Entry).set_text ((channel as Cld.Channel).desc);
        (entry_channel_num as Gtk.Entry).set_text ("%d".printf ((channel as Cld.Channel).num));
    }

    private void module_cursor_changed_cb () {
        string id;
        TreeModel tree_model;
        TreeIter iter;
        TreeSelection selection;
        Cld.Builder cld_builder = this.model.builder;
        Cld.Object module;
        string type;

        selection = (module_treeview as Gtk.TreeView).get_selection ();
        selection.get_selected (out tree_model, out iter);
        tree_model.get (iter, ModuleTreeView.Columns.ID, out id);

        module = cld_builder.get_object (id);
        type = (module as GLib.Object).get_type ().name ();
        Cld.debug ("Module TreeView Selection :: Module ID: %s Module Type: %s\n", module.id, type);
        /* Empty display area */
        foreach (var child in (scrolledwindow_module_view1 as Gtk.Container).get_children ()) {
            (scrolledwindow_module_view1 as Gtk.Container).remove (child as Widget);
        }
        foreach (var child in (scrolledwindow_module_view2 as Gtk.Container).get_children ()) {
            (scrolledwindow_module_view2 as Gtk.Container).remove (child as Widget);
        }

        switch (type) {
            case ("CldLicorModule"):
                add_serial_port_settings (module as Module);
                break;
            case ("CldVelmexModule"):
                add_serial_port_settings (module as Module);
                VelmexSettingsBox velmex_settings_box = new VelmexSettingsBox (module as Module);
                (scrolledwindow_module_view2 as Gtk.ScrolledWindow).add_with_viewport (velmex_settings_box);
                break;
            case ("CldParkerModule"):
                add_serial_port_settings (module as Module);
                ParkerSettingsBox parker_settings_box = new ParkerSettingsBox (module as Module);
                (scrolledwindow_module_view2 as Gtk.ScrolledWindow).add_with_viewport (parker_settings_box);
                break;
            case ("CldHeidolphModule"):
                add_serial_port_settings (module as Module);
                break;
            case ("CldHeidolphModule"):
                add_serial_port_settings (module as Module);
                break;
            default:
                break;
        }
    }

    private void add_serial_port_settings (Module module) {
        SerialPort port;
        SerialPortSettingsBox serial_port_settings_box;
        port = (module as Module).port as SerialPort;
        serial_port_settings_box = new SerialPortSettingsBox (port);
        (btn_apply as Button).clicked.connect (serial_port_settings_box.update);
        (btn_ok as Button).clicked.connect (serial_port_settings_box.update);
        (scrolledwindow_module_view1 as Gtk.ScrolledWindow).add_with_viewport (serial_port_settings_box);
    }

    private void update_config () {
        /* Doing this as multiple separate functions because it might simplify
         * the per-panel update I have in mind */

        update_application_config ();
        update_log_config ();
        update_channel_config ();
        //update_traverse_config ();
    }

    private void update_application_config () {
    }

    private void update_log_config () {
        Cld.Builder cld_builder = this.model.builder;

        var log = cld_builder.get_object ((entry_log_id as Gtk.Entry).text);
        (log as Cld.Log).name = (entry_log_title as Gtk.Entry).text;
        (log as Cld.Log).date_format = (entry_log_format as Gtk.Entry).text;
        (log as Cld.Log).rate = (btn_log_rate as Gtk.SpinButton).get_value ();
        Cld.debug ("log_rate: %.3f  get_value: %.3f\n", (log as Cld.Log).rate, (btn_log_rate as Gtk.SpinButton).get_value ());

        (log as Cld.Log).path = (entry_log_path as Gtk.Entry).text;
        (log as Cld.Log).file = (entry_log_file as Gtk.Entry).text;
    }

    private void update_channel_config () {
        Channel channel;
        channel = get_selected_channel ();
        if (channel is AIChannel)
            update_aichannel_config ();
        if (channel is AOChannel)
            update_aochannel_config ();
        if (channel is DIChannel)
            update_dichannel_config ();
        if (channel is DOChannel)
            update_dochannel_config ();
        if (channel is VChannel)
            update_vchannel_config ();
    }

    private void update_aichannel_config () {
        Channel channel;
        TreePath aitreepath = new TreePath ();
        TreePath cftreepath = new TreePath ();

        (aichannel_treeview as TreeView).get_cursor (out aitreepath, null);
        channel = get_selected_channel ();
        (channel as Cld.Channel).devref = (entry_channel_devref as Gtk.Entry).text;
        (channel as Cld.Channel).tag = (entry_channel_tag as Gtk.Entry).text;
        (channel as Cld.Channel).desc = (entry_channel_desc as Gtk.Entry).text;
        (channel as Cld.Channel).num = int.parse ((entry_channel_num as Gtk.Entry).text);

        foreach (var coefficient in ((coefficient_treeview as CoefficientTreeView).coefficients.values)) {
            Cld.debug ("channel.id: %s calibration.id: %s coefficient.id %s\n", channel.id,
                (channel as ScalableChannel).calibration.id, (coefficient as Coefficient).id);
            (channel as ScalableChannel).calibration.set_coefficient (
                        (coefficient as Coefficient).id, (coefficient as Coefficient));
        }

        /* Regenerate treeview */
        (scrolledwindow_aichannel as ScrolledWindow).remove (aichannel_treeview);
        aichannel_treeview = new AIChannelTreeView (this.model.ai_channels);
        (scrolledwindow_aichannel as ScrolledWindow).add (aichannel_treeview);
        (aichannel_treeview as TreeView).cursor_changed.connect (scalable_channel_cursor_changed_cb);
        (aichannel_treeview as TreeView).set_cursor (aitreepath, null, false);
        (scrolledwindow_aichannel as Widget).show_all ();

    }

    private void update_aochannel_config () {
        Channel channel;
        TreePath aotreepath = new TreePath ();
        TreePath cftreepath = new TreePath ();


        (aochannel_treeview as TreeView).get_cursor (out aotreepath, null);
        channel = get_selected_channel ();
        (channel as Cld.Channel).devref = (entry_channel_devref as Gtk.Entry).text;
        (channel as Cld.Channel).tag = (entry_channel_tag as Gtk.Entry).text;
        (channel as Cld.Channel).desc = (entry_channel_desc as Gtk.Entry).text;
        (channel as Cld.Channel).num = int.parse ((entry_channel_num as Gtk.Entry).text);
        //Cld.debug ("Selected chan is: %s\n", channel.id);

        /* Apply new calibration. */
        foreach (var coefficient in ((coefficient_treeview as CoefficientTreeView).coefficients.values)) {
            Cld.debug ("channel.id: %s calibration.id: %s coefficient.id %s %.3f\n",
                            channel.id,
                            (channel as ScalableChannel).calibration.id,
                            (coefficient as Coefficient).id,
                            (coefficient as Coefficient).value);
            (channel as ScalableChannel).calibration.set_coefficient (
                            (coefficient as Coefficient).id, (coefficient as Coefficient));
        }

        /* Regenerate treeview */
        (scrolledwindow_aochannel as ScrolledWindow).remove (aochannel_treeview);
        aochannel_treeview = new AOChannelTreeView (this.model.ao_channels);
        (scrolledwindow_aochannel as ScrolledWindow).add (aochannel_treeview);
        (aochannel_treeview as TreeView).cursor_changed.connect (scalable_channel_cursor_changed_cb);
        (aochannel_treeview as TreeView).set_cursor (aotreepath, null, false);
        (scrolledwindow_aochannel as Widget).show_all ();
    }

    private void update_vchannel_config () {
        Channel channel;
        TreePath vtreepath = new TreePath ();
        TreePath cftreepath = new TreePath ();


        (vchannel_treeview as TreeView).get_cursor (out vtreepath, null);
        channel = get_selected_channel ();
        (channel as Cld.Channel).devref = (entry_channel_devref as Gtk.Entry).text;
        (channel as Cld.Channel).tag = (entry_channel_tag as Gtk.Entry).text;
        (channel as Cld.Channel).desc = (entry_channel_desc as Gtk.Entry).text;
        (channel as Cld.Channel).num = int.parse ((entry_channel_num as Gtk.Entry).text);
        //Cld.debug ("Selected chan is: %s\n", channel.id);

        /* Apply new calibration. */
        foreach (var coefficient in ((coefficient_treeview as CoefficientTreeView).coefficients.values)) {
            Cld.debug ("channel.id: %s calibration.id: %s coefficient.id %s %.3f\n",
                            channel.id,
                            (channel as ScalableChannel).calibration.id,
                            (coefficient as Coefficient).id,
                            (coefficient as Coefficient).value);
            (channel as ScalableChannel).calibration.set_coefficient (
                            (coefficient as Coefficient).id, (coefficient as Coefficient));
        }

        /* Regenerate treeview */
        (scrolledwindow_aochannel as ScrolledWindow).remove (vchannel_treeview);
        vchannel_treeview = new VChannelTreeView (this.model.vchannels);
        (scrolledwindow_vchannel as ScrolledWindow).add (vchannel_treeview);
        (vchannel_treeview as TreeView).cursor_changed.connect (scalable_channel_cursor_changed_cb);
        (vchannel_treeview as TreeView).set_cursor (vtreepath, null, false);
        (scrolledwindow_vchannel as Widget).show_all ();
    }

    private void update_dichannel_config () {
        Channel channel;

        channel = get_selected_channel ();
        (channel as Cld.Channel).devref = (entry_channel_devref as Gtk.Entry).text;
        (channel as Cld.Channel).tag = (entry_channel_tag as Gtk.Entry).text;
        (channel as Cld.Channel).desc = (entry_channel_desc as Gtk.Entry).text;
        (channel as Cld.Channel).num = int.parse ((entry_channel_num as Gtk.Entry).text);

        (scrolledwindow_dichannel as ScrolledWindow).remove (dichannel_treeview);
        dichannel_treeview = new DIChannelTreeView (this.model.di_channels);
        (scrolledwindow_dichannel as ScrolledWindow).add (dichannel_treeview);
        (scrolledwindow_dichannel as Widget).show_all ();

    }

    private void update_dochannel_config () {
        Channel channel;

        channel = get_selected_channel ();
        (channel as Cld.Channel).devref = (entry_channel_devref as Gtk.Entry).text;
        (channel as Cld.Channel).tag = (entry_channel_tag as Gtk.Entry).text;
        (channel as Cld.Channel).desc = (entry_channel_desc as Gtk.Entry).text;
        (channel as Cld.Channel).num = int.parse ((entry_channel_num as Gtk.Entry).text);

        (scrolledwindow_dochannel as ScrolledWindow).remove (dochannel_treeview);
        dochannel_treeview = new DOChannelTreeView (this.model.do_channels);
        (scrolledwindow_dochannel as ScrolledWindow).add (dochannel_treeview);
        (scrolledwindow_dochannel as Widget).show_all ();

    }
}
