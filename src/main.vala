using Gtk;
using Config;

public class Application : Object {

    private static MainLoop loop;
    private static ApplicationData data;

    private static bool admin = false;
    private static bool gui = false;
    private static bool test = false;
    private static bool verbose = false;
    private static bool version = false;
    private static string cfgfile = null;

    private const GLib.OptionEntry[] options = {{
        "admin", 'a', 0, OptionArg.NONE, ref admin,
        "Allow administrative functionality.", null
    },{
        "config", 'c', 0, OptionArg.STRING, ref cfgfile,
        "Use the given configuration file.", null
    },{
        "gui", 'g', 0, OptionArg.NONE, ref gui,
        "Start the application with a user interface", null
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

                if (cfgfile == null) {
                    cfgfile = Path.build_filename (DATADIR, "dactl.xml");
                }

                data = new ApplicationData.with_xml_file (cfgfile);
                data.admin = admin;

                if (gui) {
                    Gdk.threads_init ();
                    Gdk.threads_enter ();
                    Gtk.init (ref args);

                    string css_path = GLib.Path.build_filename (Config.DATADIR,
                                                                "style.css");
                    CssProvider provider = new CssProvider ();
                    provider.load_from_path (css_path);
                    Gdk.Display display = Gdk.Display.get_default ();
                    Gdk.Screen screen = display.get_default_screen ();
                    Gtk.StyleContext.add_provider_for_screen (screen,
                        provider as Gtk.StyleProvider,
                        Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);
                    provider.unref ();

                    data.ui_enabled = true;
                    //data.closed.connect (() = { Gtk.main_quit (); });

                    Gtk.main ();
                    Gdk.threads_leave ();
                } else {
                    loop = new MainLoop ();

                    data.cli_enabled = true;
                    var cli = data.cli;
                    cli.run ();
                    cli.closed.connect (() => { loop.quit (); });

                    loop.run ();
                }
            }
        }

        return 0;
    }
}
