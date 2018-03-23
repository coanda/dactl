[DBus (name = "org.coanda.Dactl.Extension")]
interface Dactl.UI.DOMMessenger : GLib.Object {
    public signal void div_clicked (string num);
    public abstract void add_div (string color) throws IOError;
}

[GtkTemplate (ui = "/org/coanda/libdactl/ui/rich-content.ui")]
public class Dactl.UI.RichContent : Dactl.CompositeWidget, Dactl.CldAdapter {

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

    private string _uri = null;

    /**
     * URI to be loaded into the WebKit WebView
     */
    public string uri {
        get { return _uri; }
        set {
            _uri = value;
            view.load_uri (_uri);
        }
    }

    public signal void div_clicked (string number);

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

    private Dactl.UI.DOMMessenger messenger = null;

    construct {
        id = "rc-ctl0";

        view = new WebKit.WebView ();
        pack_start (view, true, true);

        // XXX enabling inspect crashes the view because of some libGL error
        var settings = view.get_settings ();
        settings.set ("enable-webgl", true);
        settings.set ("enable-developer-extras", true);

        objects = new Gee.TreeMap<string, Dactl.Object> ();

        Bus.watch_name (BusType.SESSION, "org.coanda.Dactl.Extension",
                        BusNameWatcherFlags.NONE,
                        (connection, name, owner) => {
                            extension_appeared_cb (connection, name, owner);
                        }, null);
    }

    public RichContent () {
        view.load_bytes (new GLib.Bytes (HTML.data), "text/html", "UTF8", "");

        // Request CLD data
        request_data.begin ();
    }

    public RichContent.from_xml_node (Xml.Node *node) {
        build_from_xml_node (node);

        if (uri != null) {
            view.load_uri (uri);
        } else {
            view.load_bytes (new GLib.Bytes (HTML.data), "text/html", "UTF8", "");
        }

        // Request CLD data
        request_data.begin ();
    }

    public void add_div (string color) {
        if (messenger != null) {
            try {
                messenger.add_div (color);
            } catch (Error error) {
                warning ("WebKit error adding div: %s", error.message);
            }
        }
    }

    private void extension_appeared_cb (DBusConnection connection, string name, string owner) {
        try {
            messenger = connection.get_proxy_sync ("org.coanda.Dactl.Extension",
                "/org/coanda/dactl/extension", DBusProxyFlags.NONE, null);
            messenger.div_clicked.connect ((num) => { div_clicked (num); });
        } catch (IOError error) {
            warning ("Problem connecting to WebKit extension: %s", error.message);
        }
    }

    /**
     * {@inheritDoc}
     */
    public override void build_from_xml_node (Xml.Node *node) {
        if (node->type == Xml.ElementType.ELEMENT_NODE &&
            node->type != Xml.ElementType.COMMENT_NODE) {
            id = node->get_prop ("id");
            uri = (node->get_prop ("uri") != null) ? node->get_prop ("uri") : uri;
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
    }

    /**
     * {@inheritDoc}
     */
    public override void update_objects (Gee.Map<string, Dactl.Object> val) {
        _objects = val;
    }
}
