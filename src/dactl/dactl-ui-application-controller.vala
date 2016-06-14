public class Dactl.UI.ApplicationController : Dactl.ApplicationController {

    public ApplicationController (Dactl.UI.ApplicationModel model,
                                  Dactl.UI.ApplicationView view) {
        base (model, view);

        var app = Dactl.UI.Application.get_default ();
        app.save_requested.connect (save_requested_cb);
        app.closed.connect (() => {
            (app as GLib.Application).quit ();
        });
    }
}
