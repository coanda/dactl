using Cld;
using Gee;
using Gtk;

public class ParkerModuleBox : Gtk.Box {

    private Gtk.Builder builder;
    private Gtk.Widget parker_control_box;
    private Cld.Module module;
    private GLib.Object btn_inj_speed;
    private GLib.Object btn_inj;
    private GLib.Object lbl_inj_status;

    double volume_ml = 0;


    construct {
        builder = new Gtk.Builder ();
        try {
            builder.add_from_resource ("/org/coanda/dactl/plugins/parker/parker_control.ui");
            parker_control_box = builder.get_object ("parker_control_box") as Gtk.Widget;
        } catch (GLib.Error e) {
            var msg = new MessageDialog (null, DialogFlags.MODAL,
                                         MessageType.ERROR,
                                         ButtonsType.CANCEL,
                                         "Failed to load UI\n%s",
                                         e.message);
            msg.run ();
        }
    }

    public ParkerModuleBox (Cld.Module module) {
        this.module = module;
        connect_signals ();
        pack_start (parker_control_box);
        show_all ();
    }

    private void connect_signals () {
        var btn_connect = builder.get_object ("btn_connect");
        (btn_connect as Gtk.ToggleButton).toggled.connect (() => {
            if ((btn_connect as Gtk.ToggleButton).active) {
                if (!module.loaded) {
                    var res = module.load ();
                    if (!res) {
                        GLib.message ("Failed to load the Parker module.");
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

        var lbl_pos = builder.get_object ("lbl_pos");
        (module as ParkerModule).new_position.connect ((position) => {
            (lbl_pos as Gtk.Label).set_text ("%.3f".printf (
                                    (module as ParkerModule).position));
        });

        var btn_home_and_zero = builder.get_object ("btn_home_and_zero");
        (btn_home_and_zero as Gtk.Button).clicked.connect (() => {
            (btn_home_and_zero as Gtk.Widget).sensitive = false;
            (module as ParkerModule).home_and_zero.begin (() => {
                (btn_home_and_zero as Gtk.Widget).sensitive = true;
                });
        });

        var btn_wd_volume = builder.get_object ("btn_wd_volume");
        var btn_wd_speed = builder.get_object ("btn_wd_speed");
        var btn_withdraw = builder.get_object ("btn_withdraw");
        lbl_inj_status  = builder.get_object ("lbl_inj_status");
        (btn_withdraw as Gtk.Button).clicked.connect (() => {
            volume_ml = double.parse ((btn_wd_volume as Gtk.Entry).get_text ());
            double speed_mlps = double.parse ((btn_wd_speed as Gtk.Entry).get_text ());
            double length_mm = convert (volume_ml);
            double speed_mmps = convert (speed_mlps);
            (module as ParkerModule).withdraw.begin (length_mm, speed_mmps, (obj, res) => {
                (module as ParkerModule).withdraw.end (res);
            });
            (lbl_inj_status as Gtk.Label).set_text ("Ready");
        });

        btn_inj_speed = builder.get_object ("btn_inj_speed");
        btn_inj = builder.get_object ("btn_inject");
        (btn_inj as Gtk.Button).clicked.connect (inject_cb);
    }

    private async void inject_cb () {
        double inject_time_actual = 0;
        double inject_time_expected, speed_mlps;
        bool pass = true;
        speed_mlps = double.parse ((btn_inj_speed as Gtk.Entry).get_text ());
        inject_time_expected = volume_ml / speed_mlps;
        yield (module as ParkerModule).inject (convert (speed_mlps), out inject_time_actual);
        GLib.debug ("inject_time_expected: %.3f inject_time_actual: %.3f\n", inject_time_expected, inject_time_actual);
        if (inject_time_actual > (1.05 * inject_time_expected)) {
            pass = false;
        }
        if ((module as ParkerModule).position < -1.0) {
            pass = false;
            GLib.debug ("Fail: position < -1.0 mm: %.3f\n", (module as ParkerModule).position);
        } else {
            GLib.debug("Pass: position > -1.0 mm: %.3f\n", (module as ParkerModule).position);
        }
        if (pass) {
            (lbl_inj_status as Gtk.Label).set_text ("PASS");
        } else {
            (lbl_inj_status as Gtk.Label).set_text ("FAIL");
        }
    }

    /**
     * Method to convert a calculate the length in [mm] of a particular cylinder given
     * its volume in [mL].
     */
    private double convert (double volume_ml) {
        //double radius_mm = 20.6;
        double length_mm;
        //length_mm = 1000 * ((volume_ml / 1e6) / (GLib.Math.PI * GLib.Math.pow ((radius_mm / 1000), 2)));
        length_mm = volume_ml * (127.2 / 200); // Syringe moves 127.2 mm for 200 mL volume displacement.

        return length_mm;
    }
}

