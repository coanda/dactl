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
    private Gee.Map<string, Cld.Object> vchannels;

    construct {
        builder = new Gtk.Builder ();
        try {
            builder.add_from_resource ("/org/coanda/dactl/plugins/licor/licor_control.ui");
            licor_control_box = builder.get_object ("licor_control_box") as Gtk.Widget;
        } catch (GLib.Error e) {
            var msg = new MessageDialog (null, DialogFlags.MODAL,
                                         MessageType.ERROR,
                                         ButtonsType.CANCEL,
                                         "Failed to load UI\n%s",
                                         e.message);
            msg.run ();
        }
    }

    public LicorModuleBox (Cld.Module module,  Gee.Map<string, Cld.Object> vchannels) {
        this.module = module;
        this.vchannels = vchannels;
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
                        GLib.debug ("Failed to load the Licor module.\n");
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

       var btn_normalize = builder.get_object ("btn_normalize");
       (btn_normalize as Gtk.Button).clicked.connect (() => {
               GLib.debug ("vchannels has %d items\n", vchannels.size);
               foreach (var vchannel in vchannels.values){
                   switch (vchannel.id){
                       case "lc0":
                       GLib.debug ("normalizing id:%s raw value:%.3f\n",
                       vchannel.id, (vchannel as Cld.VChannel).raw_value);
                       var calibration = (vchannel as Cld.VChannel).calibration;
                       var c0 = (calibration as Cld.Calibration).get_coefficient(0);
                       GLib.debug ("value of c[0]: %.3f\n", c0.value);
                       c0.value = -1 *  (vchannel as Cld.VChannel).raw_value;
                       GLib.debug ("new value of c[0]: %.3f\n", c0.value);
                       break;

                       case "lc1":
                       GLib.debug ("normalizing id:%s scaled value:%.3f\n",
                       vchannel.id, (vchannel as Cld.VChannel).raw_value);
                       var calibration = (vchannel as Cld.VChannel).calibration;
                       var c0 = (calibration as Cld.Calibration).get_coefficient(0);
                       GLib.debug ("value of c[0]: %.3f\n", c0.value);
                       c0.value = -1 *  (vchannel as Cld.VChannel).raw_value;
                       GLib.debug ("new value of c[0]: %.3f\n", c0.value);
                       break;

                       case "lc2":
                       GLib.debug ("normalizing id:%s scaled value:%.3f\n",
                       vchannel.id, (vchannel as Cld.VChannel).raw_value);
                       var calibration = (vchannel as Cld.VChannel).calibration;
                       var c0 = (calibration as Cld.Calibration).get_coefficient(0);
                       GLib.debug ("value of c[0]: %.3f\n", c0.value);
                       c0.value = -1 *  (vchannel as Cld.VChannel).raw_value;
                       GLib.debug ("new value of c[0]: %.3f\n", c0.value);
                       break;

                       case "lc3":
                       GLib.debug ("normalizing id:%s scaled value:%.3f\n",
                       vchannel.id, (vchannel as Cld.VChannel).raw_value);
                       var calibration = (vchannel as Cld.VChannel).calibration;
                       var c0 = (calibration as Cld.Calibration).get_coefficient(0);
                       GLib.debug ("value of c[0]: %.3f\n", c0.value);
                       c0.value = -1 *  (vchannel as Cld.VChannel).raw_value;
                       GLib.debug ("new value of c[0]: %.3f\n", c0.value);
                       break;
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
