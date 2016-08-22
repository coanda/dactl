internal class Dactl.DAQ.Main : GLib.Object {

    private struct Options {

        public static  bool version = false;

        public static const GLib.OptionEntry[] entries = {{
            "verbose", 'v', OptionFlags.NO_ARG, OptionArg.CALLBACK, (void *) verbose_cb,
            "Provide verbose debugging output.", null
        },{
            "version", 'V', 0, OptionArg.NONE, ref version,
            "Display version number.", null
        },{
            null
        }};
    }

    private bool verbose_cb () {
        Dactl.SysLog.increase_verbosity ();
        return true;
    }

    private static void parse_local_args (ref unowned string[] args) {
        var opt_context = new OptionContext (Dactl.Config.PACKAGE_NAME);
        opt_context.set_ignore_unknown_options (true);
        opt_context.set_help_enabled (false);
        opt_context.add_main_entries (Options.entries, null);

        try {
            opt_context.parse (ref args);
        } catch (OptionError e) {
        }

        if (Options.version) {
            stdout.printf ("%s - version %s\n", args[0], Dactl.Config.PACKAGE_VERSION);
            Posix.exit (0);
        }
    }

    private static int PLUGIN_TIMEOUT = 5;

    private Dactl.Application app;
    private Dactl.SysLog log;
    private Dactl.DAQ.DeviceManager device_manager;

    private int exit_code;

    public bool need_restart;

    private Main () throws GLib.Error {
        this.log = Dactl.SysLog.get_default ();
        log.init (true, null);

        this.exit_code = 0;

        app = Dactl.DAQ.Server.get_default ();

        device_manager = new Dactl.DAQ.DeviceManager ((app as Dactl.DAQ.Server).zmq_service);

        Unix.signal_add (Posix.SIGHUP,  () => { this.restart (); return true; });
        Unix.signal_add (Posix.SIGINT,  () => { this.exit (0);   return true; });
        Unix.signal_add (Posix.SIGTERM, () => { this.exit (0);   return true; });
    }

    /**
     * XXX should implement a state dump to capture errors and configuration
     *     when this happens
     */
    public void exit (int exit_code) {
        this.exit_code = exit_code;
        Dactl.SysLog.shutdown ();
        (app as Dactl.DAQ.Server).shutdown ();
    }

    public void restart () {
        this.need_restart = true;
        this.exit (0);
    }

    private int run (string[] args) {
        message (_("DAQ Server v%s starting..."), Config.PACKAGE_VERSION);
        app.launch (args);

        return this.exit_code;
    }

    internal void dbus_available () {
    }

    private static int main (string[] args) {

        Dactl.DAQ.Main main = null;
        Dactl.DAQ.DBusService service = null;

        var original_args = args;

        Intl.setlocale (LocaleCategory.ALL, "");
        Intl.bindtextdomain (Dactl.Config.GETTEXT_PACKAGE, Dactl.Config.LOCALEDIR);
        Intl.bind_textdomain_codeset (Dactl.Config.GETTEXT_PACKAGE, "UTF-8");
        Intl.textdomain (Dactl.Config.GETTEXT_PACKAGE);

        GLib.Environment.set_prgname (_(Dactl.Config.PACKAGE_NAME));
        GLib.Environment.set_application_name (_(Dactl.Config.PACKAGE_NAME));

        try {
            parse_local_args (ref args);

            main = new Dactl.DAQ.Main ();
            service = new Dactl.DAQ.DBusService (main);
            service.publish ();
        } catch (GLib.Error e) {
            error ("%s", e.message);
        }

        /* Launch the application */
        int exit_code = main.run (args);

        if (service != null) {
            service.unpublish ();
        }

        if (main.need_restart) {
            Posix.execvp (original_args[0], original_args);
        }

        return exit_code;
    }
}
