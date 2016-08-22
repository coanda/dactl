internal class Dactl.Main : GLib.Object {

    private struct Options {

        public static bool cli = false;
        public static  bool version = false;

        public static const GLib.OptionEntry[] entries = {{
            "cli", 'c', 0, OptionArg.NONE, ref cli,
            "Start the application with a command line interface", null
        },{
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
    private Dactl.ApplicationFactory factory;
    private Dactl.PluginLoader plugin_loader;
    private Dactl.SysLog log;

    /* XXX testing Peas plugin manager */
    private Dactl.UI.PluginManager plugin_manager;

    private int exit_code;

    public bool need_restart;

    private Main () throws GLib.Error {
        log = Dactl.SysLog.get_default ();
        log.init (true, null);

        factory = Dactl.ApplicationFactory.get_default ();
        plugin_loader = new Dactl.PluginLoader ();

        exit_code = 0;

        app = Dactl.UI.Application.get_default ();

        /* TODO transition to new Peas plugin manager */
        (app as Dactl.UI.Application).view_constructed.connect (() => {
            plugin_manager = new Dactl.UI.PluginManager (app.view);
        });

        plugin_loader.plugin_available.connect (on_plugin_loaded);

        Unix.signal_add (Posix.SIGHUP,  () => { restart (); return true; });
        Unix.signal_add (Posix.SIGINT,  () => { exit (0);   return true; });
        Unix.signal_add (Posix.SIGTERM, () => { exit (0);   return true; });
    }

    /**
     * XXX should implement a state dump to capture errors and configuration
     *     when this happens
     */
    public void exit (int exit_code) {
        this.exit_code = exit_code;
        Dactl.SysLog.shutdown ();
        (app as Dactl.UI.Application).shutdown ();
    }

    public void restart () {
        need_restart = true;
        exit (0);
    }

    private int run (string[] args) {
        debug (_("Dactl v%s starting..."), Config.PACKAGE_VERSION);
        app.launch (args);

        return exit_code;
    }

    internal void dbus_available () {
        plugin_loader.load_modules ();

        var timeout = PLUGIN_TIMEOUT;
        //try {
            /*
             *var config = MetaConfig.get_default ();
             *timeout = config.get_int ("plugin",
             *                          "TIMEOUT",
             *                          PLUGIN_TIMEOUT,
             *                          int.MAX);
             */
        //} catch (GLib.Error e) {};

        Timeout.add_seconds (timeout, () => {
            if (plugin_loader.list_plugins ().size == 0) {
                warning (ngettext ("No plugins found in %d second; giving up...",
                                   "No plugins found in %d seconds; giving up...",
                                   PLUGIN_TIMEOUT),
                         PLUGIN_TIMEOUT);

                // FIXME: this causes the application to close the device connections
                //this.exit (-82);
            } else {
                debug ("Plugin timeout is complete, assuming all are loaded");
            }

            return false;
        });
    }

    private void on_plugin_loaded (PluginLoader plugin_loader,
                                   Plugin       plugin) {
        if (plugin.has_factory) {
            Dactl.ApplicationFactory.register_factory (plugin.factory);
        }

        app.plugins.add (plugin);
        app.register_plugin (plugin);
        if (app.plugins.size > 0) {
            debug ("Added `%s', there are now %d plugins loaded",
                     plugin.name, app.plugins.size);
        }

        /*
         *var iterator = this.factories.iterator ();
         *while (iterator.next ()) {
         *    this.create_device.begin (plugin, iterator.get ());
         *}
         */
    }

    private static void register_default_factories () {
        var ui_factory = Dactl.UI.Factory.get_default ();
        Dactl.ApplicationFactory.register_factory (ui_factory);
    }

    private static int main (string[] args) {

        Dactl.Main main = null;
        Dactl.DBusService service = null;

        var original_args = args;

        Intl.setlocale (LocaleCategory.ALL, "");
        Intl.bindtextdomain (Config.GETTEXT_PACKAGE, Config.LOCALEDIR);
        Intl.bind_textdomain_codeset (Config.GETTEXT_PACKAGE, "UTF-8");
        Intl.textdomain (Config.GETTEXT_PACKAGE);

        GLib.Environment.set_prgname (_(Config.PACKAGE_NAME));
        GLib.Environment.set_application_name (_(Config.PACKAGE_NAME));

        try {
            parse_local_args (ref args);

            Dactl.Main.register_default_factories ();

            main = new Dactl.Main ();
            service = new Dactl.DBusService (main);
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
