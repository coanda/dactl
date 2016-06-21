
public class Dactl.CLI.Application : GLib.Application, Dactl.Application {

    private static Once<Dactl.CLI.Application> _instance;

    public bool _admin = false;
    /**
     * Allow administrative functionality
     */
    public bool admin {
        get { return _admin; }
        set {
            _admin = value;
        }
    }

    /**
     * {@inheritDoc}
     */
    public virtual Dactl.ApplicationModel model { get; set; }

    /**
     * {@inheritDoc}
     */
    public virtual Dactl.ApplicationView view { get; set; }

    /**
     * {@inheritDoc}
     */
    public virtual Dactl.ApplicationController controller { get; set; }

    /**
     * {@inheritDoc}
     */
    public virtual Gee.ArrayList<Dactl.Plugin> plugins { get; set; }

    /**
     * Used when the user requests a configuration save.
     */
    public signal void save_requested ();

    /**
     * Instantiate a new command line application.
     *
     * @return Instance of the application.
     */
    public static unowned Dactl.CLI.Application get_default () {
        return _instance.once (() => { return new Dactl.CLI.Application (); });
    }

    internal Application () {
        debug ("CLI application construction");

        GLib.Object (application_id: "org.coanda.dactl.cli",
                     flags: ApplicationFlags.HANDLES_COMMAND_LINE |
                            ApplicationFlags.HANDLES_OPEN);

        plugins = new Gee.ArrayList<Dactl.Plugin> ();
    }

    /**
     * {@inheritDoc}
     */
    public void register_plugin (Dactl.Plugin plugin) {
        //if (plugin.has_factory) { }
    }

    /**
     * {@inheritDoc}
     */
    public virtual int launch (string[] args) {
        return (this as GLib.Application).run (args);
    }
}
