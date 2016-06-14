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
    public bool admin { get; set; default = false; }

    /**
     * Default construction.
     */
    public ApplicationController (Dactl.ApplicationModel model,
                                  Dactl.ApplicationView view) {
        this.model = model;
        this.view = view;

        connect_signals ();
    }

    /**
     * Recursively goes through the object map and connects signals from
     * classes that will be requesting data from a higher level.
     */
    private void connect_signals () {
        debug ("Connecting signals in the controller");

        var adapters = model.get_object_map (typeof (Dactl.CldAdapter));
        foreach (var adapter in adapters.values) {
            debug ("Configuring object `%s'", (adapter as Dactl.Object).id);
            (adapter as Dactl.CldAdapter).request_object.connect ((uri) => {
                var object = model.ctx.get_object_from_uri (uri);
                debug ("Offering object `%s' to `%s'", object.id, adapter.id);
                (adapter as Dactl.CldAdapter).offer_cld_object (object);
            });
        }
    }

    /**
     * Callbacks common to all view types.
     * XXX the intention is to use a common interface later on
     */
    protected void save_requested_cb () {
        debug ("Saving the configuration.");
        try {
            model.config.set_xml_node ("//dactl/cld:objects",
                                       model.xml.get_node ("//cld/cld:objects"));
            model.config.save ();
        } catch (GLib.Error e) {
            critical (e.message);
        }
    }
}
