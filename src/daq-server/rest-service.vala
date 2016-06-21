internal class Dactl.DaqServer.RestService : Soup.Server {

    private int _port = 8088;
    /**
     * The TCP port to listen to. Setting should restart gracefully.
     */
    public int port {
        get { return _port; }
        set {
            _port = value;
            //reset ();
        }
    }

    public RestService () {
        assert (this != null);

        debug (_("Starting DAQ REST service"));

        listen_all (port, 0);

        add_handler (null, route_default);
        add_handler ("/channels", route_channels);
    }

/*
 *    public void reset () {
 *        rest_server.disconnect ();
 *        rest_server = null;
 *
 *        try {
 *            rest_server = new Soup.Server (Soup.SERVER_PORT, port);
 *            //rest_server.listen_all (port, 0);
 *        } catch (GLib.Error e) {
 *            warning ("Error creating REST service: %s", e.message);
 *        }
 *    }
 */

    /* API routes */

    private void route_default (Soup.Server server, Soup.Message msg,
                                string path, GLib.HashTable? query,
                                Soup.ClientContext client) {
        unowned RestService self = server as Dactl.DaqServer.RestService;

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
