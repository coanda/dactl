[GtkTemplate (ui = "/org/coanda/dactl/plugins/velmex/velmex-settings.ui")]
public class Dactl.Velmex.Settings : Gtk.Window {

    [GtkChild]
    private Gtk.TextBuffer textbuffer_traverse;

    private Cld.VelmexModule module;

    public Settings (Cld.VelmexModule module) {
        this.module = module;
        textbuffer_traverse.text = this.module.program.strip ();
    }

    [GtkCallback]
    private void btn_ok_clicked_cb () {
        /* Save program */
        Gtk.TextIter start, end;
        textbuffer_traverse.get_bounds (out start, out end);
        var program = textbuffer_traverse.get_text (start, end, false).strip ();
        program += "\r";
        module.program = program;
        module.store_program ();

        close ();
    }

    [GtkCallback]
    private void btn_cancel_clicked_cb () {
        close ();
    }
}
