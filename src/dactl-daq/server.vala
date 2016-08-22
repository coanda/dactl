public class Dactl.DAQ.Server : Dactl.CLI.Application {

    private static Once<Dactl.DAQ.Server> _instance;

    private GLib.MainLoop loop;

    public Dactl.DAQ.RestService rest_service;

    public Dactl.DAQ.ZmqService zmq_service;

    public static unowned Dactl.DAQ.Server get_default () {
        return _instance.once (() => {
            return new Dactl.DAQ.Server ();
        });
    }

    internal Server () {
        GLib.Object (application_id: "org.coanda.dactl.daq");

        loop = new GLib.MainLoop ();

        rest_service = new Dactl.DAQ.RestService ();
        zmq_service = new Dactl.DAQ.ZmqService.with_conn_info (
            Dactl.Net.ZmqTransport.TCP, "*", 5588);
    }

    protected override void activate () {
        base.activate ();

        debug (_("Activating DAQ Server"));
    }

    protected override void startup () {
        base.startup ();

        debug (_("Starting DAQ server > ZMQ Service"));
        zmq_service.run ();

        debug (_("Starting DAQ server > Main"));
        loop.run ();
    }

    protected override void shutdown () {
        debug (_("Shuting down DAQ Server"));
        loop.quit ();

        base.shutdown ();
    }

    public virtual int launch (string[] args) {
        return (this as GLib.Application).run (args);
    }

    static bool opt_help;
    static const OptionEntry[] options = {{
        "help", 'h', 0, OptionArg.NONE, ref opt_help, null, null
    },{
        null
    }};

    public override int command_line (GLib.ApplicationCommandLine cmdline) {
        opt_help = false;

        var opt_context = new OptionContext (Config.PACKAGE_NAME);
        opt_context.add_main_entries (options, null);
        opt_context.set_help_enabled (false);

        try {
            string[] args1 = cmdline.get_arguments ();
            unowned string[] args2 = args1;
            opt_context.parse (ref args2);
        } catch (OptionError e) {
            cmdline.printerr ("error: %s\n", e.message);
            cmdline.printerr (opt_context.get_help (true, null));
            return 1;
        }

        if (opt_help) {
            cmdline.printerr (opt_context.get_help (true, null));
        }

        return 0;
    }
}
