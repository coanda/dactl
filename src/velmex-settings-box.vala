using Cld;
using Gee;
using Gtk;

public class VelmexSettingsBox : Gtk.Box {

    private Gtk.Builder builder;
    private Gtk.Widget velmex_settings_box;
    private GLib.Object textbuffer_traverse;
    private Cld.Module module;

    construct {
        string path = GLib.Path.build_filename (Config.DATADIR,
                                                "velmex_settings_box.ui");
        builder = new Gtk.Builder ();
        GLib.debug ("Loaded interface file: %s", path);

        try {
            builder.add_from_file (path);
            velmex_settings_box = builder.get_object ("velmex_settings_box") as Gtk.Widget;
        } catch (GLib.Error e) {
            var msg = new MessageDialog (null, DialogFlags.MODAL,
                                         MessageType.ERROR,
                                         ButtonsType.CANCEL,
                                         "Failed to load UI\n%s",
                                         e.message);
            msg.run ();
        }
    }

    public VelmexSettingsBox (Cld.Module module) {
        this.module = module;
        textbuffer_traverse = builder.get_object ("textbuffer_traverse");
        (textbuffer_traverse as Gtk.TextBuffer).text = (this.module as Cld.VelmexModule).program.strip ();
        connect_signals ();
        pack_start (velmex_settings_box);
        show_all ();
    }

    private void connect_signals () {
        var btn_store_prog = builder.get_object ("btn_store_prog");
        (btn_store_prog as Gtk.Button).clicked.connect (() => {
            //var textbuffer = builder.get_object ("textbuffer_traverse");
            TextIter start, end;
            (textbuffer_traverse  as Gtk.TextBuffer).get_bounds (out start, out end);
            var program = (textbuffer_traverse as Gtk.TextBuffer).get_text (start, end, false).strip ();
            program += "\r";
            (module as VelmexModule).program = program;
            (module as VelmexModule).store_program ();
        });

    }
}
