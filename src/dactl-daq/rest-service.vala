internal class Dactl.DAQ.RestService : Dactl.Net.RestService {

    /*
     *private const Dactl.Net.RouteEntry[] routes = {
     *    { "/",                 Dactl.Net.RouteArg.CALLBACK, (void*) route_default,  null },
     *    { "/channel/<int:id>", Dactl.Net.RouteArg.CALLBACK, (void*) route_channel,  null },
     *    { "/channels",         Dactl.Net.RouteArg.CALLBACK, (void*) route_channels, null },
     *    { null }
     *};
     */

    public RestService () {
        init ();
    }

    public RestService.with_port (int port) {
        GLib.Object (port: port);
        init ();
    }

    private void init () {
        debug (_("Starting DAQ REST service on port %d"), port);
        listen_all (port, 0);

        add_handler (null,        route_default);
        add_handler ("/channel",  route_channel);
        add_handler ("/channels", route_channels);
        //add_handler ("/device",   route_device);
        //add_handler ("/devices",  route_devices);
        //add_handler ("/task",     route_task);
        //add_handler ("/tasks",    route_tasks);

        /*
         *add_routes (routes);
         */
    }

    /* API routes */

    private void route_default (Soup.Server server,
                                Soup.Message msg,
                                string path,
                                GLib.HashTable? query,
                                Soup.ClientContext client) {

        unowned Dactl.DAQ.RestService self = server as Dactl.DAQ.RestService;

        // XXX async example that simulates load, should change
        Timeout.add_seconds (0, () => {
			string html_head = "<head><title>Index</title></head>";
			string html_body = "<body><h1>Index:</h1></body>";
			msg.set_response ("text/html", Soup.MemoryUse.COPY,
							  "<html>%s%s</html>".printf (html_head,
                                                          html_body).data);

			// Resumes HTTP I/O on msg:
			self.unpause_message (msg);
			debug ("REST default handler end");
			return false;
        }, Priority.DEFAULT);

        self.pause_message (msg);
    }

    private void route_channel (Soup.Server server,
                                Soup.Message msg,
                                string path,
                                GLib.HashTable? query,
                                Soup.ClientContext client) {

        // Leaving in leading / results in empty 0th token
        string[] tokens = path.substring (1).split ("/");

        var bad_request = "jsonp('channel': {'status': %d})".printf (
                                Soup.Status.BAD_REQUEST);

        // CRUD for channel requests
        switch (msg.method.up ()) {
            case "PUT":
                debug ("PUT channel: not implemented");
                break;
            case "GET":
                if (tokens.length >= 2) {
                    debug ("GET channel: (id %s)", tokens[1]);
                } else {
                    msg.status_code = Soup.Status.BAD_REQUEST;
                    msg.response_headers.append ("Access-Control-Allow-Origin", "*");
                    msg.set_response ("application/json",
                                      Soup.MemoryUse.COPY,
                                      bad_request.data);
                }
                break;
            case "POST":
                debug ("POST channel: not implemented");
                break;
            case "DELETE":
                debug ("DELETE channel: not implemented");
                break;
            default:
                msg.response_headers.append ("Access-Control-Allow-Origin", "*");
                msg.set_response ("application/json",
                                  Soup.MemoryUse.COPY,
                                  bad_request.data);
                break;
        }
    }

    private void route_channels (Soup.Server server,
                                 Soup.Message msg,
                                 string path,
                                 GLib.HashTable? query,
                                 Soup.ClientContext client) {

        var builder = new Json.Builder ();
        builder.begin_object ();
        builder.set_member_name ("data");
        builder.add_double_value (1.0);
        builder.end_object ();

        var generator = new Json.Generator ();
        generator.set_root (builder.get_root ());

        var response = "jsonp(%s)".printf (generator.to_data (null));
        debug ("REST response: %s", response);

        msg.status_code = Soup.Status.OK;
        msg.response_headers.append ("Access-Control-Allow-Origin", "*");
        msg.set_response ("application/json",
                          Soup.MemoryUse.COPY,
                          response.data);
    }
}
