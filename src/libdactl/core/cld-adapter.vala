/**
 * Interface to define how Dactl classes attach to Cld objects.
 */
public interface Dactl.CldAdapter : GLib.Object {

    /**
     * Flag to determine whether or not the Cld requirements of the class have
     * been fulfilled.
     */
    protected abstract bool satisfied { get; set; }

    /**
     * Used to request an object by ID from whoever is listening.
     *
     * @param id the ID of the Cld.Object being requested
     */
    public signal void request_object (string id);

    /**
     * A generic setter for the requested data, without knowing how the
     * implementing class intends to structure itself.
     *
     * @param object the object that was requested
     */
    public abstract void offer_cld_object (Cld.Object object);

    /**
     * Non-blocking sleep thread used by implementing classes that request their
     * data at a timed interval.
     *
     * @param interval delay in ms
     * @param priority the thread priority to use
     */
    public virtual async void nap (uint interval, int priority = GLib.Priority.DEFAULT) {
        GLib.Timeout.add (interval, () => {
            nap.callback ();
            return false;
        }, priority);
        yield;
    }

    /**
     * All implementing classes need to request the data themselves.
     */
    protected abstract async void request_data ();
}
