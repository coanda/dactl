public interface Dactl.Application : GLib.Object {

    /**
     * Model used to update the view.
     */
    public abstract Dactl.ApplicationModel model { get; set; }

    /**
     * View to provide the user access to the data in the model.
     */
    public abstract Dactl.ApplicationView view { get; set; }

    /**
     * Controller to update the model and perform any functionality requested
     * by the view.
     */
    public abstract Dactl.ApplicationController controller { get; set; }

    public abstract Gee.ArrayList<Dactl.Plugin> plugins { get; set; }

    /**
     * Emitted when the application has been stopped.
     */
    public abstract signal void closed ();

    public abstract int launch (string[] args);

    //public abstract void shutdown ();

    /**
     * The methods startup, activate, and command_line need to be overridden in
     * the application classes that derive this but it seemed pointless to force
     * it through this interface.
     */
/*
 *    protected abstract int _command_line (GLib.ApplicationCommandLine cmdline);
 *
 *    protected abstract void _startup ();
 *
 *    protected abstract void _activate ();
 */

    public abstract void register_plugin (Dactl.Plugin plugin);
}
