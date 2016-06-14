[GtkTemplate (ui = "/org/coanda/libdactl/ui/webkit.ui")]
public class Dactl.WebKit : Dactl.CompositeWidget, Dactl.CldAdapter {

    private Gee.Map<string, Dactl.Object> _objects;

    private string _xml = """
        <object id=\"rc-ctl0\" type=\"rc\"/>
    """;

    private string _xsd = """
        <xs:element name="object">
          <xs:attribute name="id" type="xs:string" use="required"/>
          <xs:attribute name="type" type="xs:string" use="required"/>
          <xs:attribute name="ref" type="xs:string" use="required"/>
        </xs:element>
    """;

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

    private WebKit.WebView view;

    private string svg;

    public signal void div_clicked (string id);

    private const string HTML = """
    <html>
      <head xmlns:svg="http://www.w3.org/2000/svg">
        <style>
          div {
            position: absolute;
            width: 500px;
            height: 500px;
            border: 1px solid black;
            font-size: 80px;
            text-align: center;
          }
        </style>
      </head>
      <body>
      </body>
    </html>
    """;

    private const string SVG = """
    <svg:svg version="1.1" baseProfile="full" width="150" height="150">
      <svg:rect x="10" y="10" width="100" height="100" fill="red"/>
      <svg:circle cx="50" cy="50" r="30" fill="blue"/>
    </svg:svg>
    """;

    construct {
        id = "rc-ctl0";

        view = new WebKit.WebView ();
        pack_start (view, true, true);

        objects = new Gee.TreeMap<string, Dactl.Object> ();
    }

    public WebKit (string svg) {
        this.svg = svg;

        view.load_string (HTML, "text/html", "UTF8", "");
        add_svg (svg);

        // Request CLD data
        request_data.begin ();
    }

    public WebKit.from_xml_node (Xml.Node *node) {
        build_from_xml_node (node);

        //view.load_string (HTML, "text/html", "UTF8", "");
        view.load_uri ("http://www.google.ca");
        message ("from_xml_node");
        add_svg (svg);

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
            svg = node->get_prop ("svg");
        }
    }

    /**
     * {@inheritDoc}
     */
    public void offer_cld_object (Cld.Object object) {
/*
 *        if (object.uri == ch_ref) {
 *            channel = (object as Cld.Channel);
 *            satisfied = true;
 *
 *            Timeout.add (1000, update);
 *            lbl_tag.label = channel.tag;
 *        }
 */
    }

    /**
     * {@inheritDoc}
     */
    protected async void request_data () {
        // XXX remove
        satisfied = true;
        while (!satisfied) {
            //request_object (<something>);
            // Try again in a second
            yield nap (1000);
        }
        message ("request_data");
    }

    public void add_svg (string svg) {
        message ("add_svg");
        WebKit.DOM.Document doc = view.get_dom_document ();
        try {
            WebKit.DOM.Element el = doc.create_element ("div");
            WebKit.DOM.Element node = doc.create_element ("svg");
            node.set_text_content (SVG);
            el.append_child (node);
            ///
            /*
             *int x = 100, y = 100;
             *string color = "#f00";
             *el.append_child (doc.create_text_node(@"$id"));
             *el.set_attribute ("style", @"background: $color; left: $x; top: $y;");
             */
            ///
            el.set_attribute ("id", @"$id");
            ((WebKit.DOM.EventTarget) el).add_event_listener (
                "click", (Callback) on_div_clicked, false, this
            );
            doc.body.insert_before (el, null);
        } catch (GLib.Error error) {
            warning ("WebKit error: %s", error.message);
        }
    }

    /// XXX add any svg/div callbacks here

    private static void on_div_clicked (WebKit.DOM.Element element,
                                        WebKit.DOM.Event event,
                                        Dactl.WebKit view) {
        view.div_clicked (element.get_attribute ("id"));
    }

    /**
     * {@inheritDoc}
     */
    public override void update_objects (Gee.Map<string, Dactl.Object> val) {
        _objects = val;
    }
}
