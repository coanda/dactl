using Cld;
using Gee;
using Gtk;

public class ParkerSettingsBox : Gtk.Box {

    private Gtk.Builder builder;
    private Gtk.Widget parker_settings_box;
    private GLib.Object btn_zero_record;
    private Cld.Module module;

    construct {
        builder = new Gtk.Builder ();
        try {
            builder.add_from_resource ("/org/coanda/dactl/plugins/parker/parker_settings.ui");
            parker_settings_box = builder.get_object ("parker_settings_box") as Gtk.Widget;
        } catch (GLib.Error e) {
            var msg = new MessageDialog (null, DialogFlags.MODAL,
                                         MessageType.ERROR,
                                         ButtonsType.CANCEL,
                                         "Failed to load UI\n%s",
                                         e.message);
            msg.run ();
        }
    }

    public ParkerSettingsBox (Cld.Module module) {
        this.module = module;
        btn_zero_record = builder.get_object ("btn_zero_record");
        connect_signals ();
        pack_start (parker_settings_box);
        show_all ();
    }

    private void connect_signals () {
        /* TODO Make this an admin only feature */
        var btn_zero_record = builder.get_object ("btn_zero_record");
        (btn_zero_record as Gtk.Button).clicked.connect (() => {
            (module as ParkerModule).zero_record.begin ();
        });

        var btn_position = builder.get_object ("btn_position");
        var lbl_local_position = builder.get_object ("lbl_local_position");
        var lbl_actual_position = builder.get_object ("lbl_actual_position");

        (module as ParkerModule).new_actual_position.connect ((actual_position) => {
            (lbl_actual_position as Gtk.Label).set_text (
                    "%.3f".printf ((module as ParkerModule).actual_position));
        });

        (module as ParkerModule).new_position.connect ((position) => {
            (lbl_local_position as Gtk.Label).set_text (
                    "%.3f".printf ((module as ParkerModule).position));
        });

        (btn_position as Gtk.Button).clicked.connect (() => {
            (module as ParkerModule).fetch_actual_position.begin ();
        });

        var btn_home = builder.get_object ("btn_home");
        (btn_home as Gtk.Button).clicked.connect (() => {
            (module as ParkerModule).home.begin ();
        });

        var btn_jog_plus = builder.get_object ("btn_jog_plus");
        (btn_jog_plus as Gtk.Widget).button_press_event.connect ((event) => {
            if (event.type == Gdk.EventType.BUTTON_PRESS) {
                (module as ParkerModule).jog_plus.begin ();
            }

            return true;
        });

        (btn_jog_plus as Gtk.Widget).button_release_event.connect ((event) => {
            if (event.type == Gdk.EventType.BUTTON_RELEASE) {
                (module as ParkerModule).jog_stop.begin ();
            }

            return true;
        });

        var btn_jog_minus = builder.get_object ("btn_jog_minus");
        (btn_jog_minus as Gtk.Widget).button_press_event.connect ((event) => {
            if (event.type == Gdk.EventType.BUTTON_PRESS) {
                (module as ParkerModule).jog_minus.begin ();
            }

            return true;
        });

        (btn_jog_minus as Gtk.Widget).button_release_event.connect ((event) => {
            if (event.type == Gdk.EventType.BUTTON_RELEASE) {
                (module as ParkerModule).jog_stop.begin ();
            }

            return true;
        });

        var btn_step = builder.get_object ("btn_step");
        var btn_spinstep = builder.get_object ("btn_spinstep");
        var btn_fwd = builder.get_object ("btn_fwd");
        (btn_step as Gtk.Button).clicked.connect (() => {
            double step_size;
            int direction;
            step_size = (double)(btn_spinstep as Gtk.SpinButton).value;

            if ((btn_fwd as Gtk.ToggleButton).active)
                direction = 1;
            else
                direction = -1;
            (module as ParkerModule).step.begin (step_size, direction);
        });

        var btn_torque = builder.get_object ("btn_torque");
        (btn_torque as Gtk.Button).clicked.connect (() => {
            (module as ParkerModule).fetch_actual_torque.begin ();
        });

        var lbl_actual_torque = builder.get_object ("lbl_actual_torque");

        (module as ParkerModule).new_actual_torque.connect ((actual_torque) => {
            (lbl_actual_torque as Gtk.Label).set_text (
                    "%.3f".printf((module as ParkerModule).actual_torque));
        });

        var btn_ack_error = builder.get_object ("btn_ack_error");

        (btn_ack_error as Gtk.Button).clicked.connect (() => {
            (module as ParkerModule).ack_error ();
        });

        var lbl_error = builder.get_object ("lbl_error");
        var lbl_error_previous = builder.get_object ("lbl_error_previous");
        (module as ParkerModule).error.connect ((n, message) => {
            if (n == 0) {
                (lbl_error as Gtk.Label).set_text (message);
            } else if (n == 1) {
                (lbl_error_previous as Gtk.Label).set_text (message);
            }
        });
    }
}


