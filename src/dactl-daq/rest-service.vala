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
        assert (this != null);

        debug (_("Starting DAQ REST service"));

        listen_all (port, 0);

        add_handler (null, route_default);
        add_handler ("/channels", route_channels);

        /*
         *add_routes (routes);
         */
    }

    /* API routes */

    private void route_default (Soup.Server server, Soup.Message msg,
                                string path, GLib.HashTable? query,
                                Soup.ClientContext client) {
        unowned Dactl.DAQ.RestService self = server as Dactl.DAQ.RestService;

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

    private void route_channel (Soup.Server server, Soup.Message msg,
                                string path, GLib.HashTable? query,
                                Soup.ClientContext client) {
    }

    private void route_channels (Soup.Server server, Soup.Message msg,
                                 string path, GLib.HashTable? query,
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

        msg.status_code = 200;
        msg.response_headers.append ("Access-Control-Allow-Origin", "*");
        msg.set_response ("application/json", Soup.MemoryUse.COPY, response.data);
    }
}
