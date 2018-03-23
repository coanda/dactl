[GtkTemplate (ui = "/org/coanda/libdactl/ui/exec-control.ui")]
public class Dactl.ExecControl : Dactl.CompositeWidget {

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
    private Gtk.Entry entry_command;

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

    construct {
        id = "exec-ctl0";

        objects = new Gee.TreeMap<string, Dactl.Object> ();
    }

    //public ExecControl (string command) {}

    public ExecControl.from_xml_node (Xml.Node *node) {
        build_from_xml_node (node);
    }

    /**
     * {@inheritDoc}
     */
    public override void build_from_xml_node (Xml.Node *node) {
        if (node->type == Xml.ElementType.ELEMENT_NODE &&
            node->type != Xml.ElementType.COMMENT_NODE) {
            id = node->get_prop ("id");
        }
    }

    [GtkCallback]
    private void btn_exec_clicked_cb () {
        string[] args = {};
        bool executable = GLib.FileUtils.test (entry_command.text, GLib.FileTest.IS_EXECUTABLE);
        if (executable) {
            var pid = Posix.fork ();
            if (pid == 0) {
                /* child */
                Posix.execvp (entry_command.text, args);
            } else {
                /* parent - do nothing */
            }
        } else {
            warning ("The command `%s' is not executable", entry_command.text);
        }
    }

    /**
     * {@inheritDoc}
     */
    public override void update_objects (Gee.Map<string, Dactl.Object> val) {
        _objects = val;
    }
}
