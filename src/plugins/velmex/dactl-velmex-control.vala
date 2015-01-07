[GtkTemplate (ui = "/org/coanda/dactl/plugins/velmex/velmex-control.ui")]
public class Dactl.Velmex.Control : Dactl.SimpleWidget, Dactl.PluginControl, Dactl.CldAdapter {

    private string _xml = """
        <object id=\"velmex-ctl0\" type=\"velmex-plugin\" ref=\"cld://velmex0\"/>
    """;

    private string _xsd = """
        <xs:element name="object">
          <xs:attribute name="id" type="xs:string" use="required"/>
          <xs:attribute name="type" type="xs:string" use="required"/>
          <xs:attribute name="ref" type="xs:string" use="required"/>
          <xs:attribute name="parent" type="xs:string" use="required"/>
        </xs:element>
    """;

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

    [GtkChild]
    private Gtk.Revealer revealer;

    private int step_direction = 0;

    public string mod_ref { get; set; }

    private weak Cld.Module _module;

    public Cld.Module module {
        get { return _module; }
        set {
            if ((value as Cld.Object).uri == mod_ref) {
                _module = value;
                module_isset = true;
            }
        }
    }

    private bool module_isset { get; private set; default = false; }

    /**
     * {@inheritDoc}
     */
    protected override string xml {
        get { return _xml; }
    }

    /**
     * {@inheritDoc}
     */
    protected override string xsd {
        get { return _xsd; }
    }

    public virtual string parent_ref { get; set; }

    /**
     * {@inheritDoc}
     */
    protected bool satisfied { get; set; default = false; }

    public signal void cld_object_added ();

    construct {
        id = "velmex-ctl0";

        revealer.set_reveal_child (false);
        revealer.transition_type = Gtk.RevealerTransitionType.SLIDE_DOWN;
        revealer.transition_duration = 400;
    }

    public Control.from_xml_node (Xml.Node *node) {
        step_direction = (btn_fwd.active) ? 1 : -1;
        build_from_xml_node (node);

        /* Request the CLD Velmex module */
        request_data.begin ();
    }

    /**
     * {@inheritDoc}
     */
    public override void build_from_xml_node (Xml.Node *node) {

        if (node->type == Xml.ElementType.ELEMENT_NODE &&
            node->type != Xml.ElementType.COMMENT_NODE) {
            id = node->get_prop ("id");
            mod_ref = node->get_prop ("ref");
            parent_ref = node->get_prop ("parent");
            message ("Building `%s' with parent `%s' that references `%s'",
                     id, parent_ref, mod_ref);
        }
    }

    /**
     * {@inheritDoc}
     */
    public void offer_cld_object (Cld.Object object) {
        if (object.uri == mod_ref) {
            module = (object as Cld.Module);
            satisfied = true;
        }
    }

    /**
     * {@inheritDoc}
     */
    protected async void request_data () {
        while (!satisfied) {
            request_object (mod_ref);
            // Try again in a second
            yield nap (1000);
        }
        cld_object_added ();
    }

    /**
     * {@inheritDoc}
     *
     * FIXME: currently has no configurable property nodes or attributes
     */
    protected override void update_node () {
        /*
         *for (Xml.Node *iter = node->children; iter != null; iter = iter->next) {
         *    if (iter->name == "property") {
         *        switch (iter->get_prop ("name")) {
         *            case "---":
         *                iter->set_content (---);
         *                break;
         *            default:
         *                break;
         *        }
         *    }
         *}
         */
    }

    [GtkCallback]
    public void btn_connect_toggled_cb () {
        if ((btn_connect as Gtk.ToggleButton).active) {
            if (!module.loaded) {
                var res = module.load ();
                if (!res) {
                    critical ("Failed to load the Velmex module.");
                    btn_connect.set_active (false);
                } else {
                    btn_connect.label = "Disconnect";
                    btn_connect.image = img_disconnect;
                    revealer.reveal_child = true;
                }
            }
        } else {
            if (module.loaded) {
                module.unload ();
                btn_connect.label = "Connect";
                btn_connect.image = img_connect;
                revealer.reveal_child = false;
            }
        }
    }

    [GtkCallback]
    public void btn_run_prog_clicked_cb () {
        (module as Cld.VelmexModule).run_stored_program ();
    }

    [GtkCallback]
    public void btn_jog_plus_clicked_cb () {
        (module as Cld.VelmexModule).jog (1);
    }

    [GtkCallback]
    public void btn_jog_minus_clicked_cb () {
        (module as Cld.VelmexModule).jog (-1);
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
        (module as Cld.VelmexModule).jog (step_size * step_direction);
    }

    [GtkCallback]
    public void btn_configure_clicked_cb () {
        var settings = new Dactl.Velmex.Settings (module as Cld.VelmexModule);

        settings.delete_event.connect ((settings as Gtk.Widget).hide_on_delete);

        settings.title = "Velmex Plugin Settings";
        settings.set_default_size (320, 240);
        settings.modal = true;
        settings.transient_for = (this as Gtk.Widget).get_toplevel () as Gtk.Window;
        settings.type_hint = Gdk.WindowTypeHint.DIALOG;

        settings.show_all ();
    }
}
