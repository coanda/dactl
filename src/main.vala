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

    private const GLib.OptionEntry[] options = {{
        "admin", 'a', 0, OptionArg.NONE, ref admin,
        "Allow administrative functionality.", null
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

        /* XXX allow options to select the config file? */
        string path = Path.build_filename (DATADIR, "cld.xml");

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
            return 0;
        } else {
            data = new ApplicationData.with_xml_file (path);
            data.admin = admin;

            /* start data acquisition */
            data.run_acquisition ();
            //data.run_device_output ();

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

                //var ui = new UserInterfaceData (data);
                data.ui_enabled = true;

                Gtk.main ();
                Gdk.threads_leave ();
            } else if (test) {
                debug ("Moo!");
            }

            /* stop data acquisition */
            //data.stop_device_output ();
            data.stop_acquisition ();
        }

        return 0;
    }

    private static void * cli_thread () {
        string? cmd = "dummy";
        var builder = data.builder;
        var log = builder.get_object ("log0");

        do {
            stdout.printf (">>> ");
            cmd = stdin.read_line ();
            if (cmd != null) {
                if (cmd == "start-log") {
                    if (!(log as Cld.Log).is_open) {
                        stdout.printf ("starting logging...\n");
                        stdout.printf ("temporarily disabled\n");
                        //(log as Cld.Log).file_open ();
                        //(log as Cld.Log).run ();
                    }
                } else if (cmd == "stop-log") {
                    if ((log as Cld.Log).is_open) {
                        stdout.printf ("stopping logging...\n");
                        //(log as Cld.Log).stop ();
                        //(log as Cld.Log).file_mv_and_date (false);
                    }
                }
            }
        } while (cmd != "quit");

        loop.quit ();

        return null;
    }
}
