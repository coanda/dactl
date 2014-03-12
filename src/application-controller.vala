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
        var log = model.ctx.get_object (id);
        if (event == "start") {
            if (!(log as Cld.Log).active) {
//                (log as Cld.CsvLog).file_open ();
                (log as Cld.Log).start ();
            }
        } else if (event == "stop") {
            if ((log as Cld.Log).active) {
                (log as Cld.Log).stop ();
//                (log as Cld.CsvLog).file_close ();
            }
        }
    }

    public void cli_read_channel_cb (string id) {
        var channel = model.ctx.get_object (id);
        (view as CommandLineView).queue_result ("%s: %f".printf (id,
            (channel as Cld.ScalableChannel).scaled_value));
    }

    public void cli_read_channels_cb (string[] ids) {
        var channels = new Gee.TreeMap<string, Cld.Object> ();

        foreach (var id in ids) {
            var channel = model.ctx.get_object (id);
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
        model.xml.update_config (model.ctx.objects);
        model.config.set_xml_node ("//dactl/cld:objects",
                                   model.xml.get_node ("//cld/cld:objects"));
        model.config.save ();
    }
}
