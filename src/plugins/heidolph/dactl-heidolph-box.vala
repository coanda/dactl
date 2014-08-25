using Cld;
using Gee;
using Gtk;
using Posix;

public class HeidolphModuleBox : Gtk.Box {

    private Gtk.Builder builder;
    private Gtk.Widget heidolph_control_box;
    private Cld.Module module;
    private Cld.Object speed_channel;
    private Cld.Object torque_channel;
    private string received = "c";
    private int b = 0;

    construct {
        builder = new Gtk.Builder ();
        try {
            builder.add_from_resource ("/org/coanda/dactl/plugins/heidolph/heidolh_control.ui");
            heidolph_control_box = builder.get_object ("heidolph_control_box") as Gtk.Widget;
        } catch (GLib.Error e) {
            var msg = new MessageDialog (null, DialogFlags.MODAL,
                                         MessageType.ERROR,
                                         ButtonsType.CANCEL,
                                         "Failed to load UI\n%s",
                                         e.message);
            msg.run ();
        }
    }

    public HeidolphModuleBox (Cld.Module module) {
        this.module = module;
        connect_signals ();
        pack_start (heidolph_control_box);
        show_all ();
    }

    private void connect_signals () {
        speed_channel = (module as HeidolphModule).channels.get ("heidolph00");
        var lbl_speed = builder.get_object ("lbl_speed");
        (speed_channel as ScalableChannel).new_value.connect ((id, value) => {
            (lbl_speed as Label).set_text (value.to_string ());
        });

        var lbl_torque = builder.get_object ("lbl_torque");
        var lbl_error_status = builder.get_object ("lbl_error_status");
        torque_channel = (module as HeidolphModule).channels.get ("heidolph01");
        (torque_channel as ScalableChannel).new_value.connect ((id, value) => {
            (lbl_torque as Label).set_text (value.to_string ());
            (lbl_error_status as Label).set_text ((module as HeidolphModule).error_status);
        });

        var btn_connect = builder.get_object ("btn_connect");
        (btn_connect as Gtk.ToggleButton).toggled.connect (() => {
            if ((btn_connect as Gtk.ToggleButton).active) {
                if (!module.loaded) {
                    var res = module.load ();
                    if (!res) {
                        GLib.debug ("Failed to load the Heidolph module.\n");
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
            //GLib.debug ("btn_normalize clicked.\n");
            (module as HeidolphModule).normalize ();
        });

        var btn_speed_set = builder.get_object ("btn_speed_set");
        var btn_run = builder.get_object ("btn_run");
        (btn_run as Gtk.ToggleButton).toggled.connect (() => {
            if ((btn_run as Gtk.ToggleButton).active) {
                (module as HeidolphModule).speed_sp =
                                (btn_speed_set as Gtk.Entry).get_text ();
                var res = (module as HeidolphModule).run ();
                if (!res) {
                    GLib.debug ("Failed to run the Heidolph module.\n");
                    (btn_run as Gtk.ToggleButton).set_active (false);
                } else {
                    var img_run = builder.get_object ("img_run");
                    (img_run as Gtk.Image).icon_name = "media-playback-stop";
                    var lbl_run = builder.get_object ("lbl_run");
                    (lbl_run as Gtk.Label).label = "Stop";
                }
            }
            else {
                (module as HeidolphModule).stop ();
                var img_status = builder.get_object ("img_run");
                (img_status as Gtk.Image).icon_name = "media-playback-start";
                var lbl_status = builder.get_object ("lbl_run");
                (lbl_status as Gtk.Label).label = "Run";
            }
        });

        (btn_speed_set as Gtk.SpinButton).value_changed.connect (() => {
            (module as HeidolphModule).speed_sp = "%d".printf (
                        (btn_speed_set as Gtk.SpinButton).get_value_as_int ());
        });

        var btn_remote = builder.get_object ("btn_remote");
        (btn_remote as Gtk.Button).clicked.connect (() => {
            GLib.debug ("btn_remote clicked.\n");
            if ((btn_remote as Gtk.ToggleButton).get_active ()) {
                (btn_remote as Gtk.Button).set_label ("PC");
                (btn_run as Gtk.Widget).set_sensitive (false);
                (module as HeidolphModule).rheostat ();
                (btn_speed_set as Gtk.Widget).set_sensitive (false);
            } else {
                (btn_remote as Gtk.Button).set_label ("Rheostat");
                (btn_speed_set as Gtk.Entry).set_text ((module as HeidolphModule).speed);
                (module as HeidolphModule).speed_sp = ((module as HeidolphModule).speed);
                (module as HeidolphModule).run ();
                (btn_run as Gtk.Widget).set_sensitive (true);
                (btn_speed_set as Gtk.Widget).set_sensitive (true);
            }
        });
    }
}

