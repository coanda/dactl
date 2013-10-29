using Cld;

/**
 * The application controller in a MVC design is responsible for responding to
 * events from the view and updating the model.
 */
public class ApplicationController : GLib.Object {

    /**
     * Application model to use.
     */
    private ApplicationModel model;

    /**
     * Application view to use.
     */
    private GLib.Application view;

    /* Control administrative functionality */
    private bool _admin = false;
    public bool admin {
        get { return _admin; }
        set {
            /* XXX Ideally this would allow for both views simultaneously but
             *     for now assuming that just one is active is fine */
            _admin = value;
            model.admin = _admin;
            if (ui_enabled)
                (view as GraphicalView).admin = _admin;
            else if (cli_enabled)
                (view as CommandLineView).admin = _admin;
        }
    }

    /* Flag to set if user requested a command line interface. */
    private bool _cli_enabled = false;
    public bool cli_enabled {
        get { return _cli_enabled; }
        set {
            _cli_enabled = value;
            if (_cli_enabled) {
                (view as CommandLineView).cld_request.connect (cli_cld_request_cb);
                (view as CommandLineView).config_event.connect (cli_config_event_cb);
                (view as CommandLineView).control_event.connect (cli_control_event_cb);
                (view as CommandLineView).log_event.connect (cli_log_event_cb);
                (view as CommandLineView).read_channel.connect (cli_read_channel_cb);
                (view as CommandLineView).read_channels.connect (cli_read_channels_cb);
                (view as CommandLineView).write_channel.connect (cli_write_channel_cb);
                (view as CommandLineView).write_channels.connect (cli_write_channels_cb);
                (view as CommandLineView).closed.connect (() => { view.quit (); });
            } else {
                /* XXX not sure, might need to disconnect in future if this is
                 *     meant to keep the view open */
                view.quit ();
            }
        }
    }

    /* Flag to set if user requested a graphical interface. */
    private bool _ui_enabled = false;
    public bool ui_enabled {
        get { return _ui_enabled; }
        set {
            _ui_enabled = value;
            if (_ui_enabled) {
                /*
                 *_ui.admin = admin;
                 *_ui.closed.connect ();
                 */
                (view as GraphicalView).save_requested.connect (save_requested_cb);
                (view as CommandLineView).closed.connect (() => { view.quit (); });
            } else {
                /* XXX should perform a clean shutdown of the interface - fix */
                //_ui = null;
            }
        }
    }

    /**
     * Default construction.
     */
    public ApplicationController () {
        /* Nothing for now but could imagine creating blank model and view if
         * dactl is extended to construct application configurations as well. */
    }

    /**
     * Alternative construction with model and view as parameters.
     */
    public ApplicationController.with_data (ApplicationModel model, GLib.Application view) {
        this.model = model;
        this.view = view;

        if (view is CommandLineView)
            cli_enabled = true;
        else if (view is GraphicalView)
            ui_enabled = true;
    }

    /**
     * CommandLineView callbacks.
     */
    public void cli_cld_request_cb (string request) {
    }

    public void cli_config_event_cb (string event) {
    }

    public void cli_control_event_cb (string event, string id) {
    }

    public void cli_log_event_cb (string event, string id) {
        var log = model.builder.get_object (id);
        if (event == "start") {
            if (!(log as Cld.Log).active) {
                (log as Cld.Log).file_open ();
                (log as Cld.Log).run ();
            }
        } else if (event == "stop") {
            if ((log as Cld.Log).active) {
                (log as Cld.Log).stop ();
                (log as Cld.Log).file_close ();
            }
        }
    }

    public void cli_read_channel_cb (string id) {
        var channel = model.builder.get_object (id);
        (view as CommandLineView).queue_result ("%s: %f".printf (id,
            (channel as Cld.ScalableChannel).scaled_value));
    }

    public void cli_read_channels_cb (string[] ids) {
        var channels = new Gee.TreeMap<string, Cld.Object> ();

        foreach (var id in ids) {
            var channel = model.builder.get_object (id);
            channels.set (channel.id, channel);
        }

        foreach (var channel in model.channels.values) {
            (view as CommandLineView).queue_result ("%s: %f".printf (channel.id,
                (channel as Cld.ScalableChannel).scaled_value));
        }
    }

    public void cli_write_channel_cb (string id, double value) { }

    public void cli_write_channels_cb (string[] ids, double[] values) { }

    /**
     * GraphicalView callbacks.
     */

    /**
     * Callbacks common to all view types.
     * XXX the intention is to use a common interface later on
     */
    public void save_requested_cb () {
        stdout.printf ("Saving the configuration.\n");
        update_ai_channel_config ();
        update_ao_channel_config ();
        update_di_channel_config ();
        update_do_channel_config ();
        update_v_channel_config ();
        update_calibration_config ();
        update_control_config ();
        update_module_config ();
        update_log_config ();
        model.config.set_xml_node ("//dactl/cld:objects",
                                   model.xml.get_node ("//cld/cld:objects"));
        model.config.save ();
    }

    /**
     * Private methods to update the XML configuration with what's in memory.
     * XXX possibly move these into CLD
     */
    private void update_ai_channel_config () {
        /**
         * Edit the following properties:
         * - desc
         */
        foreach (var channel in model.ai_channels.values) {
            GLib.message ("Changing %s description to %s",
                          channel.id, (channel as Cld.Channel).desc);

            /* update the AI channel values of the XML data in memory */
            var xpath_base = "//cld/cld:objects/cld:object";
            var xpath = "%s[@type=\"channel\" and @id=\"%s\"]/cld:property[@name=\"desc\"]".printf (xpath_base, channel.id);
            model.xml.edit_node_content (xpath, (channel as Cld.Channel).desc);
        }
    }

    private void update_ao_channel_config () {
        /**
         * Edit the following properties:
         * - desc
         */
        foreach (var channel in model.ao_channels.values) {
            GLib.message ("Changing %s description to %s",
                          channel.id, (channel as Cld.Channel).desc);

            /* update the AI channel values of the XML data in memory */
            var xpath_base = "//cld/cld:objects/cld:object";
            var xpath = "%s[@type=\"channel\" and @id=\"%s\"]/cld:property[@name=\"desc\"]".printf (xpath_base, channel.id);
            model.xml.edit_node_content (xpath, (channel as Cld.Channel).desc);
        }
    }

    private void update_di_channel_config () {
        /* TODO fill me in */
    }

    private void update_do_channel_config () {
        /* TODO fill me in */
    }

    private void update_v_channel_config () {
        /* TODO fill me in */
    }

    private void update_coefficient_config (string calibration_id, Gee.Map<string, Cld.Object> coefficients) {
        /**
         * Edit the following properties:
         * - value
         */
        foreach (var coefficient in coefficients.values) {
            var value = "%.4f".printf ((coefficient as Cld.Coefficient).value);
            GLib.message ("Changing %s value to %s", coefficient.id, value);

            /* update the AI channel values of the XML data in memory */
            var xpath_base = "//cld/cld:objects/cld:object";
            var xpath = "%s[@type=\"calibration\" and @id=\"%s\"]/cld:object[@type=\"coefficient\" and @id=\"%s\"]/cld:property[@name=\"desc\"]".printf (xpath_base, calibration_id, coefficient.id);
            model.xml.edit_node_content (xpath, value);
        }
    }

    private void update_calibration_config () {
        /**
         * Edit the following properties:
         * - Map<Coefficient>
         * - units
         */
        foreach (var calibration in model.calibrations.values) {
            GLib.message ("Changing %s units to %s",
                          calibration.id, (calibration as Cld.Calibration).units);

            /* update the calibration settings of the xml data in memory */
            var xpath_base = "//cld/cld:objects/cld:object";
            var xpath = "%s[@type=\"calibration\" and @id=\"%s\"]/cld:property[@name=\"units\"]".printf (xpath_base, calibration.id);
            model.xml.edit_node_content (xpath, (calibration as Cld.Calibration).units);
            var coefficients = (calibration as Cld.Calibration).coefficients;
            update_coefficient_config (calibration.id, coefficients);
        }
    }

    private void update_control_config () {
        /**
         * Edit the following properties:
         * - kp
         * - ki
         * - kd
         * - dt
         * - pv_id
         * - mv_id
         */
        foreach (var control in model.control_loops.values) {
            if (control is Cld.Pid) {
                var process_values = (control as Cld.Pid).process_values;
                var pv = process_values.get ("pv0");
                var mv = process_values.get ("pv1");
                GLib.message ("Control - %s: (PV: %s) & (MV: %s)", control.id, pv.id, mv.id);

                /* update the PID values of the XML data in memory */
                var xpath_base = "//cld/cld:objects/cld:object[@type=\"control\"]/cld:object[@id=\"%s\"]".printf (control.id);
                var xpath = "%s/cld:property[@name=\"kp\"]".printf (xpath_base);
                var value = "%.6f".printf ((control as Cld.Pid).kp);
                model.xml.edit_node_content (xpath, value);
                xpath = "%s/cld:property[@name=\"ki\"]".printf (xpath_base);
                value = "%.6f".printf ((control as Cld.Pid).ki);
                model.xml.edit_node_content (xpath, value);
                xpath = "%s/cld:property[@name=\"kd\"]".printf (xpath_base);
                value = "%.6f".printf ((control as Cld.Pid).kd);
                model.xml.edit_node_content (xpath, value);
                xpath = "%s/cld:property[@name=\"dt\"]".printf (xpath_base);
                value = "%.6f".printf ((control as Cld.Pid).dt);
                model.xml.edit_node_content (xpath, value);
                /* update the channel ID references for the process values */
                xpath = "%s/cld:object[@id=\"%s\"]".printf (xpath_base, pv.id);
                model.xml.edit_node_attribute (xpath, "chref", (pv as Cld.ProcessValue).chref);
                xpath = "%s/cld:object[@id=\"%s\"]".printf (xpath_base, mv.id);
                model.xml.edit_node_attribute (xpath, "chref", (mv as Cld.ProcessValue).chref);
            }
        }
    }

    private void update_module_config () {
        /**
         * Edit the following properties:
         * - program
         */
        foreach (var module in model.modules.values) {
            /* update the module content of the XML data in memory */
            var xpath_base = "//cld/cld:objects/cld:object";
            if (module is Cld.VelmexModule) {
                GLib.message ("Changing VelmexModule %s program", module.id);
                var xpath = "%s[@type=\"module\" and @id=\"%s\"]/cld:property[@name=\"program\"]".printf (xpath_base, module.id);
                model.xml.edit_node_content (xpath, (module as Cld.VelmexModule).program);
            }
        }
    }

    private void update_log_config () {
        /**
         * Edit the following properties:
         * - name
         * - path
         * - file
         * - date format
         * - rate
         */
        foreach (var log in model.logs.values) {
            /* XXX add better debugging */
            GLib.message ("Changing log file %s", log.id);

            /* update the AI channel values of the XML data in memory */
            var xpath_base = "//cld/cld:objects/cld:object[@type=\"log\" and @id=\"%s\"]".printf (log.id);
            var xpath = "%s/cld:property[@name=\"title\"]".printf (xpath_base);
            model.xml.edit_node_content (xpath, (log as Cld.Log).name);
            xpath = "%s/cld:property[@name=\"path\"]".printf (xpath_base);
            model.xml.edit_node_content (xpath, (log as Cld.Log).path);
            xpath = "%s/cld:property[@name=\"file\"]".printf (xpath_base);
            model.xml.edit_node_content (xpath, (log as Cld.Log).file);
            xpath = "%s/cld:property[@name=\"format\"]".printf (xpath_base);
            model.xml.edit_node_content (xpath, (log as Cld.Log).date_format);
            xpath = "%s/cld:property[@name=\"rate\"]".printf (xpath_base);
            var value = "%.3f".printf ((log as Cld.Log).rate);
            model.xml.edit_node_content (xpath, value);
        }
    }
}
