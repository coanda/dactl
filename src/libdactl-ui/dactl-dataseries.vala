/**
 * A buffer that stores data from a Cld.Channel
 *
 * XXX TBD Consider a way to clock out the data at a even pace to prevent th
 */
public class Dactl.DataSeries : GLib.Object, Dactl.Object, Dactl.Buildable, Dactl.CldAdapter {

    private Xml.Node* _node;
    private int _buffer_size;
    private Gee.List<Dactl.Point> data_primary;
    private Gee.List<Dactl.Point> data_secondary;
    private weak Cld.Channel _channel;
    private int64 then;
    private int delay_count = 500;
    private int64 sum = 0;
    private int delay_time_us;

    public string ch_ref { get; set; }

    public Cld.Channel channel {
        get { return _channel; }
        set {
            if ((value as Cld.Object).uri == ch_ref) {
                _channel = value;
                satisfied = true;
                (_channel as Cld.ScalableChannel).new_value.connect (new_value_cb);
                /*transfer_data.begin ();*/
            }
        }
    }

    public int buffer_size {
        get { return _buffer_size; }
        set {
            lock (data_primary) {
                data_primary.clear ();
            }
            _buffer_size = value;
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
        data_primary = new Gee.LinkedList<Dactl.Point> ();
        data_secondary = new Gee.LinkedList<Dactl.Point> ();
    }

    public DataSeries.from_xml_node (Xml.Node *node) {
        build_from_xml_node (node);
    }

    /**
     * {@inheritDoc}
     */
    public void build_from_xml_node (Xml.Node *node) {
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
            channel = (object as Cld.Channel);
            then = GLib.get_monotonic_time ();
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

    /**
     * XXX TBD Something like this could be used in a digital phase locked loop
     * for retiming the output.
     */
/*
 *    private async void transfer_data () {
 *        GLib.SourceFunc callback = transfer_data.callback;
 *        bool first_pass = true;
 *        int j = 0;
 *
 *        GLib.Thread<int> thread = new GLib.Thread<int>.try ("bg_device_watch",  () => {
 *
 *            while (satisfied) {
 *                if ((data_primary.size <= (2 * buffer_size)) && first_pass) {
 *                    [> Copy an entry from primary to secondary <]
 *                    (data_secondary as Gee.Deque<Dactl.Point>).offer_tail (
 *                        (data_primary as Gee.Deque<Dactl.Point>).peek_head ());
 *
 *                } else if ((data_primary.size >= (2 * buffer_size)) && first_pass) {
 *                    [> Trim the queue. First pass is done <]
 *                    for (int i  =  0; i < (data_primary.size - buffer_size); i++) {
 *                        (data_primary as Gee.Deque<Dactl.Point>).poll_head ();
 *                        first_pass = false;
 *                    }
 *                } else if ((data_primary.size > buffer_size) && !first_pass) {
 *                    message ("2 %d %d %d", data_primary.size, data_secondary.size, delay_time_us);
 *                    [> Transfer an entry from the primary to the secondary queue <]
 *                    (data_secondary as Gee.Deque<Dactl.Point>).offer_tail (
 *                            (data_primary as Gee.Deque<Dactl.Point>).poll_head ());
 *                }
 *
 *                if (data_secondary.size > buffer_size) {
 *                    (data_primary as Gee.Deque<Dactl.Point>).poll_head ();
 *                }
 *
 *                [>GLib.Thread.usleep (delay_time_us);<]
 *            }
 *
 *            Idle.add ((owned) callback);
 *            return 0;
 *        });
 *    }
 */

/*
 *    private void transfer_data () {
 *        bool first_pass = true;
 *
 *        if (satisfied) {
 *            if ((data_primary.size <= (2 * buffer_size)) && first_pass) {
 *                [> Copy an entry from primary to secondary <]
 *                (data_secondary as Gee.Deque<Dactl.Point>).offer_tail (
 *                    (data_primary as Gee.Deque<Dactl.Point>).peek_head ());
 *
 *            } else if ((data_primary.size >= (2 * buffer_size)) && first_pass) {
 *                [> Trim the queue. First pass is done <]
 *                for (int i  =  0; i < (data_primary.size - buffer_size); i++) {
 *                    (data_primary as Gee.Deque<Dactl.Point>).poll_head ();
 *                    first_pass = false;
 *                }
 *            } else if ((data_primary.size > buffer_size) && !first_pass) {
 *                message ("2 %d %d %d", data_primary.size, data_secondary.size, delay_time_us);
 *                [> Transfer an entry from the primary to the secondary queue <]
 *                (data_secondary as Gee.Deque<Dactl.Point>).offer_tail (
 *                        (data_primary as Gee.Deque<Dactl.Point>).poll_head ());
 *            }
 *
 *            if (data_secondary.size > buffer_size) {
 *                (data_primary as Gee.Deque<Dactl.Point>).poll_head ();
 *            }
 *        }
 *    }
 */

    private void new_value_cb (string id, double value) {
        var now = GLib.get_monotonic_time ();

        var dt = now - then;
        sum += dt;
        then = now;
        var point = new Dactl.Point (dt, value);
        debug ("id: %10s  x: %10.3f   y: %10.3f    sum: %10lld", id, point.x, point.y, sum);
        lock (data_primary) {
            (data_primary as Gee.Deque<Dactl.Point>).offer_head (point);
            /* Trim the queue. */
            if (data_primary.size == (buffer_size + 1))
                (data_primary as Gee.Deque<Dactl.Point>).poll_tail ();
            else if (data_primary.size > buffer_size) {
                /* Buffer size must have changed. Trim multiple entries */
                for (int i = 0; i < (data_primary.size - buffer_size); i++) {
                    (data_primary as Gee.Deque<Dactl.Point>).poll_tail ();
                }
            }
        }
        /*delay_time_us = (int)sum / delay_count;*/
        /*transfer_data ();*/
    }

    public Dactl.Point[] to_array () {
        Dactl.Point[] array;
        lock (data_primary) {
            array = data_primary.to_array ();
        }

        return array;
    }
}
