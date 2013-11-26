using Cld;
using Gtk;
using Gee;
using Posix;

public class DIOViewer : Gtk.Window {

    private Gtk.Builder builder;
    private Gtk.Widget dio_viewer;
    private Gtk.Widget box_inputs;
    private Gtk.Widget box_outputs;
    private Gtk.Widget btn;
    private ApplicationModel model;
    private Gee.Map <string, Gtk.Widget> di_buttons = new Gee.TreeMap<string, Gtk.Widget> ();
    private Gee.Map <string, Gtk.Widget> do_buttons = new Gee.TreeMap<string, Gtk.Widget> ();
    private Gee.Map <string, Cld.Object> di_channels = new Gee.TreeMap<string, Cld.Object> ();
    private Gee.Map <string, Cld.Object> do_channels = new Gee.TreeMap<string, Cld.Object> ();
    private Gtk.Widget tog;
    private const int WIDTH = 16;
    private string label;
    private string[] labelary = new string [1];


    construct {
        string path = GLib.Path.build_filename (Config.UI_DIR,
                                                "view_dio.ui");
        builder = new Gtk.Builder ();
        Cld.debug ("Loaded interface file: %s\n", path);

        try {
            builder.add_from_file (path);
            dio_viewer = builder.get_object ("dio_viewer") as Gtk.Widget;
            box_inputs = builder.get_object ("box_inputs") as Gtk.Widget;
            box_outputs = builder.get_object ("box_outputs") as Gtk.Widget;
        } catch (GLib.Error e) {
            var msg = new MessageDialog (null, DialogFlags.MODAL,
                                        MessageType.ERROR,
                                        ButtonsType.CANCEL,
                                        "Failed to load UI\n%s",
                                        e.message);
            msg.run ();
        }
    }

    public DIOViewer (ApplicationModel model) {
        this.model = model;
      /* Create seperate input and output channel lists. */
        foreach (var channel in model.channels.values) {
            if (channel is DIChannel) {
                di_channels.set (channel.id, channel);
            } else if (channel is DOChannel)
                do_channels.set (channel.id, channel);
        }

        populate ();
        dio_viewer.set_size_request (300, 200);
        dio_viewer.show_all ();
    }

    /**
     * Create button boxes as rows to display the DIO values in a grid.
     */
    public void populate () {
        int i, j;
        int count = 0;
        int ninrows = (int)Math.ceil ((double) di_channels.size / WIDTH);
        int noutrows = (int)Math.ceil ((double) do_channels.size / WIDTH);
        string key;

        /* Generate buttons for the digital inputs. */
        for (i = 0; i < ninrows; i++) {
            /* Get a new row of buttons. */
            var inbox = new Gtk.ButtonBox (Orientation.HORIZONTAL);
            inbox.layout_style = ButtonBoxStyle.START;

            for (j = 0; j < WIDTH; j++) {
                btn = new ToggleButton ();
                key = ("btn_" + count.to_string ());
                di_buttons.set (key, btn);
                /* TODO: Set the button properties */

                (inbox as Gtk.Container).add_with_properties (btn);

                count++;
                if (count >= di_channels.size)
                    break;

            }

            (box_inputs as Box).pack_start ((inbox as Widget), false, false, 0);
        }

        /* Generate buttons for the digital outputs. */
        count = 0;
        for (i = 0; i < noutrows; i++) {
            /* Get a new row of buttons. */
            var outbox = new Gtk.ButtonBox (Orientation.HORIZONTAL);
            outbox.layout_style = ButtonBoxStyle.START;

            for (j = 0; j < WIDTH; j++) {
                btn = new ToggleButton ();
                key = ("btn_" + count.to_string ());
                do_buttons.set (key, btn);
                /* TODO: Set the button properties */
        }
        stdout.printf ("\n");
        foreach (var channel in data.channels.values) {
            if (channel is DOChannel) {
                Cld.debug ("%s ", channel.id);
                count++;

                if (count > do_channels.size)
                    break;

                (outbox as Gtk.Container).add_with_properties (btn);

                count++;
                if (count >= do_channels.size)
                    break;
            }

            (box_outputs as Box).pack_start ((outbox as Widget), false, false, 0);
        }

        /* Add labels to buttons and connect signals */
        count = 0;
        foreach (var channel in di_channels.values) {
            btn = di_buttons.get ("btn_" + count.to_string ());
            label = (channel as Channel).id + "\n" +
                    ((channel as Channel).num).to_string () + "\n" +
                    (channel as Channel).tag;
            (btn as Button).set_label (label);

            (channel as Cld.DChannel).new_value.connect ((id, value) => {
                var chan = di_channels.get (id);
                int num = (chan as DChannel).num;
                GLib.message ("id: %s num: %d", id,  num);
                var button = di_buttons.get ("btn_" + num.to_string ());
                (button as Gtk.ToggleButton).set_active (value);
            });

            count++;
        }

        count = 0;
        foreach (var channel in do_channels.values) {
            btn = do_buttons.get ("btn_" + count.to_string ());
            label = (channel as Channel).id + "\n" +
                    ((channel as Channel).num).to_string () + "\n" +
                    (channel as Channel).tag;
            (btn as Button).set_label (label);
            label = (btn as Button).get_label ();
            labelary = label.split ("\n", 3);
            label = labelary [0];
            //GLib.message ("btn_%s label: %s", count.to_string (), label);

            (channel as Cld.DChannel).new_value.connect ((id, value) => {
                var chan = do_channels.get (id);
                int num = (chan as DChannel).num;
                //GLib.message ("id: %s num: %d", id,  num);
                var button = do_buttons.get ("btn_" + num.to_string ());
            });

            (btn as ToggleButton).toggled.connect (() => {
                foreach (var button in do_buttons.values) {
                    label = (button as Button).label;
                    labelary = label.split ("\n", 3);
                    //GLib.message ("%s", labelary [0]);
                    var chan = do_channels.get (labelary [0]);
                    if ((button as ToggleButton).get_active ()) {
                        (chan as DOChannel).state = false;
                    } else
                        (chan as DOChannel).state = true;
                }
            });

            count++;
        }

        (tog as Gtk.ToggleButton).toggled.connect (() => {
            message ("tog Toggled!");
        });

        foreach (var button in do_buttons.values) {
            if (button is Gtk.ToggleButton) message ("Yup, it is!");
            (button as Gtk.ToggleButton).set_active (true);
            (button as Gtk.ToggleButton).set_active (false);
            (button as Gtk.ToggleButton).set_active (true);
            (button as Gtk.ToggleButton).set_active (false);

            (button as Gtk.ToggleButton).toggled.connect (() => {
                message ("Toggled");
            });
        }
>>>>>>> d4b4c30... Button responds to a signal from channel but still not working.
    }
}

