/**
 * A buffer that stores data from a Cld.Channel
 *
 * XXX TBD Consider a way to clock out the data at a even pace to prevent th
 */
public class Dactl.DataSeries : GLib.Object, Dactl.Object, Dactl.Buildable, Dactl.CldAdapter {

    private Xml.Node* _node;
    private int _buffer_size;
    private int _stride = 1;
    private Dactl.SimplePoint [] data;
    private Dactl.SimplePoint [] array;
    private weak Cld.Channel _channel;
    private int64 then;
    private int start = 0;
    private int end = 1;

    public string ch_ref { get; set; }

    public Cld.Channel channel {
        get { return _channel; }
        set {
            if ((value as Cld.Object).uri == ch_ref) {
                _channel = value;
                satisfied = true;
                (_channel as Cld.ScalableChannel).new_value.connect (new_value_cb);
            }
        }
    }

    public int buffer_size {
        get { return _buffer_size; }
        private set {
            /* Extend buffer for end point interpolation */
            _buffer_size = value + 3;
        }
    }

    private string _xml = """
        <ui:object id=\"ds-0\" type=\"dataseries\"/>
          <ui:property name=\"buffer-size\">1000</ui:property>
    """;

    private string _xsd = """
        <xs:element name="object">
          <xs:attribute name="id" type="xs:string" use="required"/>
          <xs:attribute name="type" type="xs:string" use="required"/>
          <xs:attribute name="ref" type="xs:string" use="required"/>
        </xs:element>
    """;

    /**
     * The number of channel data samples between buffer entries
     */
    public int stride {
        get {return _stride; }
        private set { _stride = value; }
    }

    /**
     * {@inheritDoc}
     */
    public string id { get; set; default = "trace0"; }

    /**
     * {@inheritDoc}
     */
    protected string xml {
        get { return _xml; }
    }

    /**
     * {@inheritDoc}
     */
    protected string xsd {
        get { return _xsd; }
    }

    /**
     * {@inheritDoc}
     */
    protected virtual Xml.Node* node {
        get {
            return _node;
        }
        set {
            _node = value;
        }
    }

    /**
     * {@inheritDoc}
     */
    protected bool satisfied { get; set; default = false; }

    construct {
    }

    public DataSeries.from_xml_node (Xml.Node *node) {
        build_from_xml_node (node);
    }

    /**
     * {@inheritDoc}
     */
    internal void build_from_xml_node (Xml.Node *node) {
        if (node->type == Xml.ElementType.ELEMENT_NODE &&
            node->type != Xml.ElementType.COMMENT_NODE) {
            this.node = node;
            id = node->get_prop ("id");
            ch_ref = node->get_prop ("ref");

            /* Iterate through node children */
            for (Xml.Node *iter = node->children; iter != null; iter = iter->next) {
                if (iter->name == "property") {
                    switch (iter->get_prop ("name")) {
                        case "buffer-size":
                            buffer_size = int.parse (iter->get_content ());
                            /* create an empty slot */
                            var point = Dactl.SimplePoint () {
                                            x = double.NAN,
                                            y = double.NAN
                                        };
                            data += point;
                            break;
                        case "stride":
                            stride = int.parse (iter->get_content ());
                            break;
                        default:
                            break;
                    }
                }
            }
        }
        request_data.begin ();
    }

    /**
     * {@inheritDoc}
     */
    public void offer_cld_object (Cld.Object object) {
        if (ch_ref == object.uri) {
            then = GLib.get_monotonic_time ();
            channel = (object as Cld.Channel);
        }
    }

    /**
     * {@inheritDoc}
     */
    protected async void request_data () {
        while (!satisfied) {
            request_object (ch_ref);
            // Try again in a second
            yield nap (1000);
        }
    }

    int count = 0;
    private void new_value_cb (string id, double value) {
        /* XXX FIXME Consider using absolute rather than differential timing */
        count++;
        if (count == stride) {
            lock (data) {
                var now = GLib.get_monotonic_time ();
                var dt = now - then;
                then = now;
                var point = Dactl.SimplePoint () { x = dt, y = value };

                if (end == buffer_size)
                    end = 0;

                if (data.length < buffer_size) {
                    data += point;
                } else {
                    start ++;
                    if (start == buffer_size)
                        start = 0;
                    data [end] = point;
                }
            }
            end++;
            count = 0;
        }
    }

    public Dactl.SimplePoint[] to_array () {
        int j = 0;
        lock (data) {
            for (int i = 0; i < data.length - 1; i++) {
                j = (end - i - 1);

                if (j < 0) {
                    j = data.length + j;
                }

                if (array.length < data.length) {
                    array += data [j];
                    array [i] = data [j];
                } else {
                    array [i] = data [j];
                }

            }

            return array;
        }
    }
}
