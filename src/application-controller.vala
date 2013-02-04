using Cld;

/**
 * XXX hmmm, not sure if I should do it this way or stick with data only. Will
 * revisit the concept later.
 */
public class ApplicationController : GLib.Object {

    /**
     * Referenced application data to use.
     */
    public weak ApplicationData data { get; set; }

    public ApplicationController () {
    }

    public ApplicationController.with_data (ApplicationData data) {
        this.data = data;
    }

    /* Alternatively to using a thread pool could use a GeeHashMap and require
     * that this method be called with the key of the thread to execute. */
    public void run_ai_thread_pool () {
        if (!Thread.supported ()) {
            stderr.printf ("Cannot run acquisition without thread support.\n");
            //task.active = false;
            return;
        }
    }
}
