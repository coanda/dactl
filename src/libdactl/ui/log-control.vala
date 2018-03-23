[GtkTemplate (ui = "/org/coanda/libdactl/ui/log-control.ui")]
public class Dactl.LogControl : Dactl.CompositeWidget, Dactl.CldAdapter {

    private string _xml = """
        <object id=\"ai-ctl0\" type=\"ai\" ref=\"cld://ai0\"/>
    """;

    private string _xsd = """
        <xs:element name="object">
          <xs:attribute name="id" type="xs:string" use="required"/>
          <xs:attribute name="type" type="xs:string" use="required"/>
          <xs:attribute name="ref" type="xs:string" use="required"/>
        </xs:element>
    """;

    [GtkChild]
    private Gtk.Stack content;

    [GtkChild]
    private Gtk.Box box_primary;

    [GtkChild]
    private Gtk.Box box_secondary;

    [GtkChild]
    private Gtk.Button btn_start;

    [GtkChild]
    private Gtk.Button btn_stop;

    [GtkChild]
    private Gtk.Label lbl_id;

    [GtkChild]
    private Gtk.Label lbl_path;

    [GtkChild]
    private Gtk.Label lbl_logging_path;

    [GtkChild]
    private Gtk.Image img_start;

    [GtkChild]
    private Gtk.Image img_stop;

    public string log_ref { get; set; }

    private weak Cld.Log _log;

    public Cld.Log log {
        get { return _log; }
        set {
            if ((value as Cld.Object).uri == log_ref) {
                _log = value;
                log_isset = true;
            }
        }
    }

    private bool log_isset { get; private set; default = false; }

    private Gee.Map<string, Dactl.Object> _objects;

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

    /**
     * {@inheritDoc}
     */
    public override Gee.Map<string, Dactl.Object> objects {
        get { return _objects; }
        set { update_objects (value); }
    }

    /**
     * {@inheritDoc}
     */
    protected bool satisfied { get; set; default = false; }

    construct {
        id = "log-ctl0";
        // FIXME: doesn't work from .ui file
        content.transition_type = Gtk.StackTransitionType.SLIDE_LEFT_RIGHT;
        content.transition_duration = 400;

        objects = new Gee.TreeMap<string, Dactl.Object> ();
    }

    //public LogControl (string log_ref) {}

    public LogControl.from_xml_node (Xml.Node *node) {
        build_from_xml_node (node);

        // Request CLD data
        request_data.begin ();
    }

    /**
     * {@inheritDoc}
     */
    public override void build_from_xml_node (Xml.Node *node) {
        if (node->type == Xml.ElementType.ELEMENT_NODE &&
            node->type != Xml.ElementType.COMMENT_NODE) {
            id = node->get_prop ("id");
            log_ref = node->get_prop ("ref");
        }
    }

    /**
     * {@inheritDoc}
     */
    public void offer_cld_object (Cld.Object object) {
        if (object.uri == log_ref) {
            log = (object as Cld.Log);
            satisfied = true;
            lbl_id.label = log.id;
            update_label ();
            log.notify["gfile"].connect ((s, p) => {
                update_label ();
            });
        }
    }

    private void update_label () {
        lbl_path.label = "%s".printf (log.gfile.get_path ());
        lbl_logging_path.label = "%s".printf (log.gfile.get_path ());
    }

    /**
     * {@inheritDoc}
     */
    protected async void request_data () {
        while (!satisfied) {
            request_object (log_ref);
            // Try again in a second
            yield nap (1000);
        }
    }

    [GtkCallback]
    private void btn_start_clicked_cb () {
        int mode = Posix.R_OK | Posix.W_OK;

        debug (log.to_string ());

        var window = get_toplevel ();
        if (!window.is_toplevel ()) {
            warning ("Couldn't get top level window");
        }

        /* Test for a valid path */
        debug ("Testing log path: %s", (log as Cld.Log).gfile.get_parent ().get_path ());
        if (Posix.access ((log as Cld.Log).gfile.get_parent ().get_path (), mode) != 0) {
            warning ("Log `%s' path %s is invalid", log.id, (log as Cld.Log).gfile.get_parent ().get_path ());
            var dialog = new Gtk.MessageDialog ((Gtk.Window)window,
                                                Gtk.DialogFlags.MODAL,
                                                Gtk.MessageType.WARNING,
                                                Gtk.ButtonsType.CLOSE,
                                                "Log path %s is invalid\nlogging will not start",
                                                (log as Cld.Log).gfile.get_parent ().get_path ());
            dialog.response.connect ((response_id) => {
                switch (response_id) {
                    case Gtk.ResponseType.CLOSE:
                        debug ("Log warning for `%s' confirmed", log.id);
                        break;
                }
                dialog.destroy ();
            });

            dialog.show ();

            return;
        }

        /* Start the log file */
        if (!(log as Cld.Log).active) {
            (log as Cld.Log).start ();
            debug ("Start log `%s'", log.id);
        }

        /* If the start failed notify the user */
        if (!(log as Cld.Log).active) {
            warning ("Failed to start log `%s'", log.id);
            var dialog = new Gtk.MessageDialog ((Gtk.Window)window,
                                                Gtk.DialogFlags.MODAL,
                                                Gtk.MessageType.ERROR,
                                                Gtk.ButtonsType.CLOSE,
                                                "Failed to start log `%s'",
                                                log.id);
            dialog.response.connect ((response_id) => {
                switch (response_id) {
                    case Gtk.ResponseType.CLOSE:
                        debug ("Log error for `%s' confirmed", log.id);
                        break;
                }
                dialog.destroy ();
            });

            dialog.show ();

            return;
        }

        content.visible_child = box_secondary;
    }

    [GtkCallback]
    private void btn_stop_clicked_cb () {
        if ((log as Cld.Log).active) {
            (log as Cld.Log).stop ();
            if (log is Cld.CsvLog) {
                (log as Cld.CsvLog).file_mv_and_date (false);
            }
            debug ("Stopped log `%s'", log.id);
        }

        content.visible_child = box_primary;
    }

    /**
     * {@inheritDoc}
     */
    public override void update_objects (Gee.Map<string, Dactl.Object> val) {
        _objects = val;
    }
}
