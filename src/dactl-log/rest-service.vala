internal class Dactl.Recorder.RestService : Dactl.Net.RestService {

    private const string bad_request = "jsonp('XXX': {'status': 400})";

    public RestService () {
        init ();
    }

    public RestService.with_port (int port) {
        GLib.Object (port: port);
        init ();
    }

    private void init () {
        debug (_("Starting Recorder REST service on port %d"), port);
        listen_all (port, 0);

        add_handler (null,    route_default);
        add_handler ("/log",  route_log);
        add_handler ("/logs", route_logs);
    }

    /* API routes */

    /**
     * Default route serves static index page.
     */
    private void route_default (Soup.Server server,
                                Soup.Message msg,
                                string path,
                                GLib.HashTable? query,
                                Soup.ClientContext client) {

        unowned Dactl.Recorder.RestService self = server as Dactl.Recorder.RestService;

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

    /**
     * Log routes to display all or work with CRUD.
     */
    private void route_log (Soup.Server server,
                            Soup.Message msg,
                            string path,
                            GLib.HashTable? query,
                            Soup.ClientContext client) {

        // Leaving in leading / results in empty 0th token
        string[] tokens = path.substring (1).split ("/");

        // CRUD for log requests
        switch (msg.method.up ()) {
            case "PUT":
                debug (_("PUT log: not implemented"));
                break;
            case "GET":
                debug (_("GET log: not implemented"));
                break;
            case "POST":
                debug (_("POST log: not implemented"));
                break;
            case "DELETE":
                debug (_("DELETE log: not implemented"));
                break;
            default:
                msg.status_code = Soup.Status.BAD_REQUEST;
                msg.response_headers.append ("Access-Control-Allow-Origin", "*");
                msg.set_response ("application/json",
                                  Soup.MemoryUse.COPY,
                                  bad_request.replace ("XXX", "log").data);
                break;
        }
    }

    private void route_logs (Soup.Server server,
                             Soup.Message msg,
                             string path,
                             GLib.HashTable? query,
                             Soup.ClientContext client) {

        var response = "jsonp('logs': { 'response': 'test' })";
        debug ("GET logs: %s", response);

        msg.status_code = Soup.Status.OK;
        msg.response_headers.append ("Access-Control-Allow-Origin", "*");
        msg.set_response ("application/json",
                          Soup.MemoryUse.COPY,
                          response.data);
    }
}
