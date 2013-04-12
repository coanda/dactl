using Cld;
using Gee;
using Gtk;

public class VelmexModuleBox : Gtk.Box {

    /* XXX want to try using signals and allow the handler to deal with changes
     *     instead of trying to bring it all into these sub-objects */
    //private ApplicationData data;
    private Gtk.Builder builder;
    private Gtk.Widget velmex_control_box;
    private Cld.Module module;

    construct {
        string path = GLib.Path.build_filename (Config.DATADIR,
                                                "velmex_control.ui");
        builder = new Gtk.Builder ();
        debug ("Loaded interface file: %s", path);

        try {
            builder.add_from_file (path);
            velmex_control_box = builder.get_object ("velmex_control_box") as Gtk.Widget;
        } catch (Error e) {
            var msg = new MessageDialog (null, DialogFlags.MODAL,
                                         MessageType.ERROR,
                                         ButtonsType.CANCEL,
                                         "Failed to load UI\n%s",
                                         e.message);
            msg.run ();
        }
    }

    public VelmexModuleBox (Cld.Module module) {
        this.module = module;
        connect_signals ();
        pack_start (velmex_control_box);
        show_all ();
    }

    private void connect_signals () {
        var btn_connect = builder.get_object ("btn_connect");
        (btn_connect as Gtk.ToggleButton).toggled.connect (() => {
            if ((btn_connect as Gtk.ToggleButton).active) {
                if (!module.loaded) {
                    var res = module.load ();
                    if (!res) {
                        message ("Failed to load the Velmex module.");
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

        var btn_run_prog = builder.get_object ("btn_run_prog");
        (btn_run_prog as Gtk.Button).clicked.connect (() => {
            (module as VelmexModule).run_stored_program ();
        });
    }
}
