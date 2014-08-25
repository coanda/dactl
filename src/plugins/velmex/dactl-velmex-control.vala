[GtkTemplate (ui = "/org/coanda/dactl/plugins/velmex/velmex.ui")]
public class Dactl.Velmex.Control : Dactl.Box {

    [GtkChild]
    private Gtk.ToggleButton btn_connect;

    [GtkChild]
    private Gtk.RadioButton btn_fwd;

    [GtkChild]
    private Gtk.Image img_connect;

    [GtkChild]
    private Gtk.Image img_disconnect;

    [GtkChild]
    private Gtk.Adjustment adj_step;

    private Dactl.Velmex.Plugin plugin;

    private int step_direction = 0;

    construct {
        id = "velmex-ctl0";
    }

    public Control (Dactl.Velmex.Plugin plugin) {
        this.plugin = plugin;
        step_direction = (btn_fwd.active) ? 1 : -1;
    }

    [GtkCallback]
    public void btn_connect_toggled_cb () {
        if ((btn_connect as Gtk.ToggleButton).active) {
            if (!plugin.module.loaded) {
                var res = plugin.module.load ();
                if (!res) {
                    critical ("Failed to load the Velmex module.");
                    btn_connect.set_active (false);
                } else {
                    btn_connect.label = "Disconnect";
                    btn_connect.image = img_disconnect;
                }
            }
        } else {
            if (plugin.module.loaded) {
                plugin.module.unload ();
                btn_connect.label = "Connect";
                btn_connect.image = img_connect;
            }
        }
    }

    [GtkCallback]
    public void btn_run_prog_clicked_cb () {
        (plugin.module as Cld.VelmexModule).run_stored_program ();
    }

    [GtkCallback]
    public void btn_jog_plus_clicked_cb () {
        (plugin.module as Cld.VelmexModule).jog (1);
    }

    [GtkCallback]
    public void btn_jog_minus_clicked_cb () {
        (plugin.module as Cld.VelmexModule).jog (-1);
    }

    [GtkCallback]
    public void btn_fwd_toggled_cb () {
        step_direction = 1;
    }

    [GtkCallback]
    public void btn_rev_toggled_cb () {
        step_direction = -1;
    }

    [GtkCallback]
    public void btn_step_clicked_cb () {
        int step_size = (int)adj_step.value;
        (plugin.module as Cld.VelmexModule).jog (step_size * step_direction);
    }
}
