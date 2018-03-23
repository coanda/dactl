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
     * Emitted whenever the data acquisition state is changed.
     */
    public signal void acquisition_state_changed (bool state);

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
     * Destruction occurs when object goes out of scope.
     *
     * @deprecated since CLD task addition
     */
    ~ApplicationController () {
        /* Stop hardware threads. */
        stop_acquisition ();
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

    /**
     * Start the thread that handles data acquisition.
     */
    public void start_acquisition () {

        var multiplexers = model.ctx.get_object_map (typeof (Cld.Multiplexer));
        bool using_mux = (multiplexers.size > 0);

        /* Manually open all of the devices */
        var devices = model.ctx.get_object_map (typeof (Cld.Device));
        foreach (var device in devices.values) {

            if (!(device as Cld.ComediDevice).is_open) {
                message ("  Opening Comedi Device: `%s'", device.id);
                (device as Cld.ComediDevice).open ();
                if (!(device as Cld.ComediDevice).is_open)
                    error ("Failed to open Comedi device: `%s'", device.id);
            }

            if (!using_mux) {
                message ("Starting tasks for: `%s'", device.id);
                var tasks = (device as Cld.Container).get_object_map (typeof (Cld.Task));
                foreach (var task in tasks.values) {
                    //if ((task as Cld.ComediTask).direction == "read") {
                        message ("  Starting task: `%s'", task.id);
                        (task as Cld.ComediTask).run ();
                    //}
                }
            }
        }

        if (using_mux) {
            var acq_ctls = model.ctx.get_object_map (typeof (Cld.AcquisitionController));
            foreach (var acq_ctl in acq_ctls.values) {
                (acq_ctl as Cld.AcquisitionController).run ();
            }
        }

        /* XXX should check that the task started properly */
        acquisition_state_changed (true);
    }

    /**
     * Stops the thread that handles data acquisition.
     */
    public void stop_acquisition () {

        var multiplexers = model.ctx.get_object_map (typeof (Cld.Multiplexer));
        bool using_mux = (multiplexers.size > 0);

        /* Manually close all of the devices */
        var devices = model.ctx.get_object_map (typeof (Cld.Device));
        foreach (var device in devices.values) {

            if (!using_mux) {
                message ("Stopping tasks for: `%s'", device.id);
                var tasks = (device as Cld.Container).get_object_map (typeof (Cld.Task));
                foreach (var task in tasks.values) {
                    if (task is Cld.ComediTask) {
                        //if ((task as Cld.ComediTask).direction == "read") {
                            message ("  Stopping task: `%s` ", task.id);
                            (task as Cld.ComediTask).stop ();
                        //}
                    }
                }
            }

            if ((device as Cld.ComediDevice).is_open) {
                message ("Closing Comedi Device: %s", device.id);
                (device as Cld.ComediDevice).close ();
                if ((device as Cld.ComediDevice).is_open)
                    error ("Failed to close Comedi device: %s", device.id);
            }
        }

        /* XXX should check that the task stopped properly */
        acquisition_state_changed (false);
    }

    /**
     * Starts the thread that handles output channels.
     */
    public void start_device_output () {
        var devices = model.ctx.get_object_map (typeof (Cld.Device));
        foreach (var device in devices.values) {
            if (!(device as Cld.ComediDevice).is_open) {
                message ("Opening Comedi Device: %s", device.id);
                (device as Cld.ComediDevice).open ();
            }

            if (!(device as Cld.ComediDevice).is_open)
                error ("Failed to open Comedi device: %s", device.id);

            foreach (var task in (device as Cld.Container).get_objects ().values) {
                if (task is Cld.ComediTask) {
                    if ((task as Cld.ComediTask).direction == "write")
                        (task as Cld.ComediTask).run ();
                }
            }
        }
    }

    /**
     * Stops the thread that handles output channels.
     */
    public void stop_device_output () {
        var devices = model.ctx.get_object_map (typeof (Cld.Device));
        foreach (var device in devices.values) {
            message ("Stopping tasks for: %s", device.id);
            foreach (var task in (device as Cld.Container).get_objects ().values) {
                if (task is Cld.ComediTask) {
                    if ((task as Cld.ComediTask).direction == "write") {
                        message ("  Stopping task: %s", task.id);
                        (task as Cld.ComediTask).stop ();
                    }
                }
            }
        }
    }
}
