using Cld;
using Gee;
using Gtk;

public class AOBox : Gtk.Box {

    private ApplicationModel model;
    private Cld.AOChannel channel;
    public string chan_id { get; set; }

    private Adjustment manual_adjustment;
    private Scale manual_scale;
    private SpinButton manual_spin_button;


    public AOBox (string chan_id, ApplicationModel model) {
        GLib.Object (orientation: Orientation.HORIZONTAL);
        spacing = 10;
        this.chan_id = chan_id;
        this.model = model;
        channel = model.ctx.get_object (this.chan_id) as Cld.AOChannel;
        create_widgets ();
        connect_signals ();
    }

    private void create_widgets () {
        /* Create and setup widgets */
        manual_adjustment = new Adjustment (0.0, 0.0, 100.0, 0.5, 0.5, 0.0);
        manual_scale = new Scale (Orientation.HORIZONTAL, manual_adjustment);
        manual_scale.draw_value = false;
        manual_spin_button = new SpinButton (manual_adjustment, 1.0, 2);

        /* Layout widgets */
        var r1hbox = new Box (Orientation.HORIZONTAL, 5);
        var desc = new Label (channel.desc);
        desc.justify = Justification.LEFT;
        r1hbox.pack_start (desc, false, false, 0);
        r1hbox.pack_start (manual_scale, true, true, 0);

        var r2hbox = new Box (Orientation.HORIZONTAL, 10);
        r2hbox.pack_start (new Gtk.Label ("Output\n[% of max.]"), false, false, 0);
        r2hbox.pack_start (manual_spin_button, false, false, 0);

        var vbox = new Box (Orientation.VERTICAL, 10);
        vbox.pack_start (r1hbox, false, false, 0);
        vbox.pack_start (r2hbox, false, false, 0);
        pack_start (vbox, true, true, 0);

        show_all ();
    }

    private void connect_signals () {
        manual_scale.sensitive = true;
        manual_spin_button.sensitive = true;
        /* for now the manual adjustment on the control is from 0 - 100 %,
         * hence the divide by 10 */
        manual_adjustment.value_changed.connect (() => {
            (channel as AOChannel).raw_value = manual_adjustment.value;
        });
    }
}

