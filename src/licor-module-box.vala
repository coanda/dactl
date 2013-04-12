using Cld;
using Gee;
using Gtk;

public class LicorModuleBox : Gtk.Box {

    /* XXX want to try using signals and allow the handler to deal with changes
     *     instead of trying to bring it all into these sub-objects */
    //private ApplicationData data;
    private Gtk.Builder builder;
    private Gtk.Widget licor_control_box;
    private Cld.Module module;

    construct {
        string path = GLib.Path.build_filename (Config.DATADIR,
                                                "licor_control.ui");
        builder = new Gtk.Builder ();
        debug ("Loaded interface file: %s", path);

        try {
            builder.add_from_file (path);
            licor_control_box = builder.get_object ("licor_control_box") as Gtk.Widget;
        } catch (Error e) {
            var msg = new MessageDialog (null, DialogFlags.MODAL,
                                         MessageType.ERROR,
                                         ButtonsType.CANCEL,
                                         "Failed to load UI\n%s",
                                         e.message);
            msg.run ();
        }
    }

    public LicorModuleBox (Cld.Module module) {
        this.module = module;
        connect_signals ();
        pack_start (licor_control_box);
        show_all ();
    }

    private void connect_signals () {

        var btn_connect = builder.get_object ("btn_connect");
        (btn_connect as Gtk.ToggleButton).toggled.connect (() => {
            if ((btn_connect as Gtk.ToggleButton).active) {
                if (!module.loaded) {
                    var res = module.load ();
                    if (!res) {
                        message ("Failed to load the Licor module.");
                        (btn_connect as Gtk.ToggleButton).set_active (false);
                    } else {
                        var img_status = builder.get_object ("img_status");
                        (img_status as Gtk.Image).icon_name = "connect_creating";
                        var lbl_status = builder.get_object ("lbl_status");
                        (lbl_status as Gtk.Label).label = "Disconnect";
                    }
                }
            } else {
                if (module.loaded) {
                    module.unload ();
                    var img_status = builder.get_object ("img_status");
                    (img_status as Gtk.Image).icon_name = "connect_established";
                    var lbl_status = builder.get_object ("lbl_status");
                    (lbl_status as Gtk.Label).label = "Connect";
                }
            }
        });

        (module as LicorModule).diagnostic_event.connect (() => {
            var img_diag = builder.get_object ("img_diag");
            (img_diag as Gtk.Image).icon_name = "package-broken";
        });

        (module as LicorModule).diagnostic_reset.connect (() => {
            var img_diag = builder.get_object ("img_diag");
            (img_diag as Gtk.Image).icon_name = "package-installed-updated";
        });
    }
}
