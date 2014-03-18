using Cld;

/**
 * The application controller in a MVC design is responsible for responding to
 * events from the view and updating the model.
 */
public class Dactl.ApplicationController : GLib.Object {

    /**
     * Application model to use.
     */
    private Dactl.ApplicationModel model;

    /**
     * Application view to use.
     */
    private Dactl.ApplicationView view;

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
                (view as Dactl.UI.Application).admin = _admin;
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
                (view as Dactl.UI.Application).save_requested.connect (save_requested_cb);
                (view as Dactl.UI.Application).closed.connect (() => {
                    (view as GLib.Application).quit ();
                });
                connect_signals ();
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
    public ApplicationController.with_data (ApplicationModel model, Dactl.ApplicationView view) {
        this.model = model;
        this.view = view;
        this.ui_enabled = true;
    }

    /**
     * Recursively goes through the object map and connects signals from
     * classes that will be requesting data from a higher level.
     */
    private void connect_signals () {
        /* XXX doing it this way wasn't exactly as intended */

        GLib.message ("Connecting signals in the controller");

        var trees = model.app_builder.get_object_map (typeof (Dactl.ChannelTree));
        foreach (var tree in trees.values) {
            GLib.message ("Configuring tree `%s'", tree.id);
            var tree_model = (tree as Dactl.ChannelTree).model;
            tree_model.channel_request.connect ((id) => {
                var channel = model.ctx.get_object (id);
                GLib.message ("Adding channel `%s' to `%s'", channel.id, tree_model.id);
                tree_model.channels.set (channel.id, channel);
            });
            tree_model.add_channels ();
        }

        var pnids = model.app_builder.get_object_map (typeof (Dactl.Pnid));
        foreach (var pnid in pnids.values) {
            GLib.message ("Configuring PNID `%s'", pnid.id);
            var pnid_model = (pnid as Dactl.Pnid).model;
            pnid_model.channel_request.connect ((id) => {
                var channel = model.ctx.get_object (id);
                GLib.message ("Adding channel `%s' to `%s'", channel.id, pnid_model.id);
                pnid_model.channels.set (channel.id, channel);
            });
            pnid_model.add_channels ();
        }
    }

    /**
     * Dactl.UI.Application callbacks.
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
