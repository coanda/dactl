using Cld;
using Gtk;
using Gee;

public class DOBox : Gtk.Box {
    private ApplicationModel model;
    private Cld.DOChannel channel;
    private string chan_id;
    private Gtk.ToggleButton button;

    public DOBox (string chan_id, ApplicationModel model) {
        GLib.Object (orientation: Orientation.HORIZONTAL);
        spacing = 10;
        this.chan_id = chan_id;
        this.model = model;
        channel = model.ctx.get_object (this.chan_id) as Cld.DOChannel;
        create_widgets ();
        connect_signals ();
    }

    private void create_widgets () {
        /* Create and setup widgets */
        button = new Gtk.ToggleButton.with_label ("LOW");

        /* Layout widgets */
        var r1hbox = new Box (Orientation.HORIZONTAL, 5);
        var desc = new Label (channel.desc);
        desc.justify = Justification.LEFT;
        r1hbox.pack_start (desc, false, false, 0);
        r1hbox.pack_start (button, true, true, 0);

        var vbox = new Box (Orientation.VERTICAL, 10);
        vbox.pack_start (r1hbox, false, false, 0);
        pack_start (vbox, true, true, 0);

        show_all ();
    }

    private void connect_signals () {
        (button as Gtk.ToggleButton).toggled.connect (() => {
            if ((button as Gtk.ToggleButton).active) {
                (button as Gtk.Button).set_label ("HIGH");
                (channel as DOChannel).state = true;
            } else {
                (button as Gtk.Button).set_label ("LOW");
                (channel as DOChannel).state = false;
            }
        });
    }
}




