using Config;

public class Application : Object {

    private static ApplicationModel model;
    private static GLib.Application view;               /* Seemed easiest */
    private static ApplicationController controller;

    private static bool admin = false;
    private static bool cli = false;
    private static bool test = false;
    private static bool verbose = false;
    private static bool version = false;
    private static string cfgfile = null;

    private const GLib.OptionEntry[] options = {{
        "admin", 'a', 0, OptionArg.NONE, ref admin,
        "Allow administrative functionality.", null
    },{
        "cli", 'c', 0, OptionArg.NONE, ref cli,
        "Start the application with a command line interface", null
    },{
        "config", 'f', 0, OptionArg.STRING, ref cfgfile,
        "Use the given configuration file.", null
    },{
        "test", 't', 0, OptionArg.NONE, ref test,
        "Perform a basic functionality test.", null
    },{
        "verbose", 'v', 0, OptionArg.NONE, ref verbose,
        "Provide verbose debugging output.", null
    },{
        "version", 'V', 0, OptionArg.NONE, ref version,
        "Display version number.", null
    },{
        null
    }};

    public static int main (string[] args) {

        int status = 0;

        try {
            var opt_context = new OptionContext (PACKAGE_NAME);
            opt_context.set_help_enabled (true);
            opt_context.add_main_entries (options, null);
            opt_context.parse (ref args);
        } catch (OptionError e) {
            stdout.printf ("error: %s\n", e.message);
            stdout.printf ("Run '%s --help' to see a full list of available command line options.\n", args[0]);
            return 0;
        }

        if (version) {
            stdout.printf ("%s\n", PACKAGE_VERSION);
        } else {
            if (test) {
                var title = """
    .___              __  .__
  __| _/____    _____/  |_|  |
 / __ |\__  \ _/ ___\   __\  |
/ /_/ | / __ \\  \___|  | |  |__
\____ |(____  /\___  >__| |____/
     \/     \/     \/
                """;
                stdout.printf ("%s\n%s - version %s\n", title, args[0], PACKAGE_VERSION);
            } else {
                Cld.init (args);

                /* Setup the application model */
                if (cfgfile == null) {
                    cfgfile = Path.build_filename (DATADIR, "dactl.xml");
                }

                model = new ApplicationModel.with_xml_file (cfgfile);
                model.verbose = verbose;

                /* Setup the application view */
                if (cli) {
                    view = new CommandLineView ();
                } else {
                    view = new GraphicalView (model);
                }

                /* Setup the controller */
                controller = new ApplicationController.with_data (model, view);
                controller.admin = admin;

                /* Launch the application */
                try {
                    status = view.run (args);
                } catch (GLib.Error e) {
                    stdout.printf ("Error: %s\n", e.message);
                    return 0;
                }
            }
        }

        return status;
    }
}
