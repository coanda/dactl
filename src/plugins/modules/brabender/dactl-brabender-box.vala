using Cld;
using Gee;
using Gtk;

public class BrabenderModuleBox : Gtk.Box {

    /* XXX want to try using signals and allow the handler to deal with changes
     *     instead of trying to bring it all into these sub-objects */
    //private ApplicationData data;
    private Gtk.Builder builder;
    private Gtk.Widget brabender_control_box;
    private Cld.Module module;

    construct {
        builder = new Gtk.Builder ();
        try {
            builder.add_from_resource ("/org/coanda/dactl/plugins/brabender/brabender_control.ui");
            brabender_control_box = builder.get_object ("brabender_control_box") as Gtk.Widget;
        } catch (GLib.Error e) {
            var msg = new MessageDialog (null, DialogFlags.MODAL,
                                         MessageType.ERROR,
                                         ButtonsType.CANCEL,
                                         "Failed to load UI\n%s",
                                         e.message);
            msg.run ();
        }
    }

    public BrabenderModuleBox (Cld.Module module) {
        this.module = module;
        connect_signals ();
        pack_start (brabender_control_box);
        show_all ();
    }

    private void connect_signals () {
        var btn_connect = builder.get_object ("btn_connect");
        var btn_run = builder.get_object ("btn_run");
        var btn_flow_control = builder.get_object ("btn_flow_control");
        var btn_speed_control = builder.get_object ("btn_speed_control");
        var btn_flow_set = builder.get_object ("btn_flow_set");
        var btn_speed_set = builder.get_object ("btn_speed_set");
        var adj_flow = (btn_flow_set as Gtk.SpinButton).adjustment;
        var adj_speed = (btn_speed_set as Gtk.SpinButton).adjustment;
        var entry_ip_address = builder.get_object ("entry_ip_address");
        /* Get the ip address and set entry text value. */
        (entry_ip_address as Gtk.Entry).set_text
                (((module.port) as ModbusPort).ip_address);
        (btn_flow_control as Gtk.RadioButton).get_group ();
        (btn_speed_control as Gtk.RadioButton).join_group (btn_flow_control as Gtk.RadioButton);
        (btn_flow_control as Gtk.RadioButton).set_active (true);

        (btn_connect as Gtk.ToggleButton).toggled.connect (() => {
            if ((btn_connect as Gtk.ToggleButton).active) {
                if (!module.loaded) {
                    var res = module.load ();
                    if (!res) {
                        GLib.message ("Failed to load the Brabender module.");
                        (entry_ip_address as Gtk.Entry).set_text ("Invalid IP Address");
                        (btn_connect as Gtk.ToggleButton).set_active (false);
                    } else {
                        var img_status = builder.get_object ("img_status");
                        (img_status as Gtk.Image).icon_name = "connect_creating";
                        var lbl_status = builder.get_object ("lbl_status");
                        (lbl_status as Gtk.Label).label = "Disconnect";
                    }
                }
            }
            else {
                if (module.loaded) {
                    module.unload ();
                    var img_status = builder.get_object ("img_status");
                    (img_status as Gtk.Image).icon_name = "connect_established";
                    var lbl_status = builder.get_object ("lbl_status");
                    (lbl_status as Gtk.Label).label = "Connect";
                }
            }
        });

        (btn_run as Gtk.ToggleButton).toggled.connect (() => {
            if ((btn_run as Gtk.ToggleButton).active) {
                if (!(module as BrabenderModule).running) {
                    var res = (module as BrabenderModule).run ();
                    if (!res) {
                        GLib.debug ("Failed to run the Brabender module.\n");
                        (btn_run as Gtk.ToggleButton).set_active (false);
                    } else {
                        var img_run = builder.get_object ("img_run");
                        (img_run as Gtk.Image).icon_name = "media-playback-stop";
                        var lbl_run = builder.get_object ("lbl_run");
                        (lbl_run as Gtk.Label).label = "Stop";
                    }
                }
            }
            else {
                if ((module as BrabenderModule).running) {
                    (module as BrabenderModule).stop ();
                    var img_status = builder.get_object ("img_run");
                    (img_status as Gtk.Image).icon_name = "media-playback-start";
                    var lbl_status = builder.get_object ("lbl_run");
                    (lbl_status as Gtk.Label).label = "Run";
                }
            }
        });

        (btn_flow_control as Gtk.RadioButton).toggled.connect (() => {
            if ((btn_flow_control as Gtk.RadioButton).active) {
                GLib.debug ("Gravimetric feed control selected\n");
                if (!(module as BrabenderModule).set_mode("GF")) {
                    critical ("Unable to set Brabender operating mode GF.");
                }
            }
        });

        (btn_speed_control as Gtk.RadioButton).toggled.connect (() => {
            if ((btn_speed_control as Gtk.RadioButton).active) {
                GLib.debug ("Discharge (speed) control selected\n");
                if (!(module as BrabenderModule).set_mode("DI")) {
                    critical ("Unable to set Brabender operating mode DI");
                }
            }
        });

        (adj_flow as Gtk.Adjustment).value_changed.connect (() => {
            var flow = (adj_flow as Gtk.Adjustment).get_value ();
            GLib.debug ("flow value: %.3f\n", flow);
            (module as BrabenderModule).set_mass_flow (flow);
            });

        (adj_speed as Gtk.Adjustment).value_changed.connect (() => {
            var speed = (adj_speed as Gtk.Adjustment).get_value ();
            GLib.debug ("speed value: %.3f\n", speed);
            (module as BrabenderModule).set_discharge (speed);
        });

        (entry_ip_address as Gtk.Entry).activate.connect (() => {
            ((module.port) as ModbusPort).ip_address
                = (entry_ip_address as Gtk.Entry).text;
        });
    }
}
