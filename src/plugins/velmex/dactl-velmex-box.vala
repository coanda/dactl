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
        builder = new Gtk.Builder ();
        try {
            builder.add_from_resource ("/org/coanda/dactl/plugins/velmex/velmex_control.ui");
            velmex_control_box = builder.get_object ("velmex_control_box") as Gtk.Widget;
        } catch (GLib.Error e) {
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
                        GLib.message ("Failed to load the Velmex module.");
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

        var btn_jog_plus = builder.get_object ("btn_jog_plus");
        (btn_jog_plus as Gtk.Button).clicked.connect (() => {
            (module as VelmexModule).jog (1);
        });

        var btn_jog_minus = builder.get_object ("btn_jog_minus");
        (btn_jog_minus as Gtk.Button).clicked.connect (() => {
            (module as VelmexModule).jog (-1);
        });

        var btn_step = builder.get_object ("btn_step");
        var btn_spinstep = builder.get_object ("btn_spinstep");
        var btn_fwd = builder.get_object ("btn_fwd");
        (btn_step as Gtk.Button).clicked.connect (() => {
            int step_size;
            int direction;
            step_size = (int)(btn_spinstep as Gtk.SpinButton).value;
            if ((btn_fwd as Gtk.ToggleButton).active)
                direction = 1;
            else
                direction = -1;
            (module as VelmexModule).jog (step_size * direction);
        });
    }
}
