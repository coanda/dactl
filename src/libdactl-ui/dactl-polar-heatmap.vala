public class Dactl.PolarHeatMap : GLib.Object, Dactl.Object, Dactl.Container,
                                               Dactl.Buildable, Dactl.Drawable {

    private Gee.Map<string, Dactl.Object> _objects;
    private Xml.Node* _node;

    private double _zoom;
    public double zoom {
        get { return _zoom; }
        set {
            _zoom = value;
        }
    }

    /**
     * The interpolation method used for color gradient
     */
    private Dactl.ColorGradientType _gradient;
    public Dactl.ColorGradientType gradient {
        get { return _gradient; }
        set {
            _gradient = value;
        }
    }

    /**
     * {@inheritDoc}
     */
    public string id { get; set; default = "heatmap0"; }
    /* compute grid */

    private string _xml = """
        <ui:object id=\"surf1-0\" type=\"surface\" ttype=\"heatmap\">
            <ui:property name=\"min-color\">rgb(256,0,0)</ui:property>
            <ui:property name=\"max-color\">rgb(0,0,256)</ui:property>
            <ui:property name=\"magnitude-min\">-10</ui:property>
            <ui:property name=\"magnitude-max\">10</ui:property>
            <ui:property name=\"angle-min\">-10</ui:property>
            <ui:property name=\"angle-max\">10</ui:property>
            <ui:property name=\"zmin\">-10</ui:property>
            <ui:property name=\"zmax\">10</ui:property>
            <ui:property name=\"interpolation-type\">none</ui:property>
            <ui:property name=\"rings\">4</ui:property>
            <ui:property name=\"sectors\">4</ui:property>

            <ui:object id=\"hmap-0\" type=\"heatmap\">
                <ui:property name=\"min-color\">rgba(256,0,0,1)</ui:property>
                <ui:property name=\"max-color\">rgba(0,0,256,1)</ui:property>
                <ui:property name=\"min\">-10</ui:property>
                <ui:property name=\"max\">10</ui:property>
                <ui:property name=\"interpolation-type\">none</ui:property>
                <ui:property name=\"grid-rings\">4</ui:property>
                <ui:property name=\"grid-sectors\">4</ui:property>
                <ui:object id=\"ary-0" type="channel-matrix\">

                    <ui:object id=\"pg1chart0tr0ary0p00\" type=\"channel-matrix-element\">
                        <ui:property name=\"x\">0.900</ui:property>
                        <ui:property name=\"y\">1.00</ui:property>
                        <ui:property name=\"chref\">/daqctl0/dev0/ai00</ui:property>
                    </ui:object>

                    <ui:object id=\"pg1chart0tr0ary0p01\" type=\"channel-matrix-element\">
                        <ui:property name=\"x\">1.00</ui:property>
                        <ui:property name=\"y\">2.00</ui:property>
                        <ui:property name=\"chref\">/daqctl0/dev0/ai01</ui:property>
                    </ui:object>
                </ui:object>
            </ui:object>
        </ui:object>
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
    public Gee.Map<string, Dactl.Object> objects {
        get { return _objects; }
        set { update_objects (value); }
    }

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
    public unowned Cairo.ImageSurface image_surface { get; set; }

    /* defines the boundary of the map */
    private double magnitude_min;
    private double magnitude_max;
    private double angle_min;
    private double angle_max;

    /* XXX Make a color map with arbitrary break points instead of max and min */
    /* The minimum value to be mapped to a color */
    private double _zmin;
    public double zmin {
        get { return _zmin; }
        set { _zmin = value; }
    }

    /* The maximum value to be mapped to a color */
    private double _zmax;
    public double zmax {
        get { return _zmax; }
        set { _zmax = value; }
    }

    /* The color that min is mapped to */
    protected string min_color_spec { get; set; default = "black"; }

    protected Gdk.RGBA _min_color;

    public Gdk.RGBA min_color  {
        get { return _min_color; }
        set {
            _min_color = value;
            min_color_spec = min_color.to_string ();
        }
    }

    /* The color that max is mapped to */
    protected string max_color_spec { get; set; default = "white"; }

    protected Gdk.RGBA _max_color;

    public Gdk.RGBA max_color  {
        get { return _max_color; }
        set {
            _max_color = value;
            max_color_spec = max_color.to_string ();
        }
    }

    /* Specifies the method used for interpolation */
    protected string interpolation_type { get; set; default = "none"; }

    private Dactl.PolarHeatMap.Data data;

    private Dactl.ChannelMatrix channel_matrix = null;

    /**
     * Defines vertices of an annulus sector
     */
    public struct AnnulusSector {
        public double x;         // the horizontal pixel value of the inner vertex
        public double y;         // the vertical pixel value of the inner vertex
        public double xc;        // the horizontal pixel value of the origin point
        public double yc;        // the vertical pixel value of the origin point
        public double theta;
        public double width;     // the radial width of the sector
        public double sweep;     // the angular span of the sector
    }

    /* Defines the coordinates and color of an  annulus sector on the heat map */
    private struct Cell {
        public int ring;                     // the polar equivalent to row
        public int sector;                   // the polar equivalent to column
        public Dactl.TriplePoint point;      // the 2D coordinates and magnitude
        public Gdk.RGBA color;               // the color mapped magnitude
        public AnnulusSector annulus_sector; // data for drawing this
        public string chref;                 // a channel reference
    }

    /* Data representation of the grid of annulus sectors */
    private class Data : Gee.LinkedList<Dactl.PolarHeatMap.Cell?> {

        private double _cell_width;
        public double cell_width { get { return _cell_width; } set { _cell_width = value; }}

        private double _cell_sweep;
        public double cell_sweep { get { return _cell_sweep; } set { _cell_sweep = value; }}

        private int _rings;
        public int rings { get { return _rings; } set { _rings = value; }}

        private int _sectors;
        public int sectors { get { return _sectors; } set { _sectors = value; }}

        private Dactl.TriplePoint [,] _points;
        public Dactl.TriplePoint [,] points {
            get {
                _points = new Dactl.TriplePoint[rings, sectors];
                foreach (var cell in this) {
                    _points[cell.ring, cell.sector] = cell.point;
                }

                return _points;
            }
            set {
                if ((value.length[0] == rings) &&(value.length[1] == sectors)) {
                    foreach (var cell in this) {
                        cell.point = value[cell.ring, cell.sector];
                    }
                } else  {
                    error ("Invalid array dimensions");
                }
            }
        }


        private AnnulusSector[,] _annulus_sectors;
        public AnnulusSector[,] annulus_sectors {
            get {
                _annulus_sectors = new AnnulusSector[rings, sectors];
                foreach (var cell in this) {
                    _annulus_sectors[cell.ring, cell.sector] = cell.annulus_sector;
                }

                return _annulus_sectors;
            }
            set {
                if ((value.length[0] == rings) && (value.length[1] == sectors)) {
                    foreach (var cell in this) {
                        cell.annulus_sector = value[cell.ring, cell.sector];
                    }
                } else  {
                    error ("Invalid array dimensions");
                }
            }
        }

        private Gdk.RGBA [,] _colors;
        public Gdk.RGBA[,] colors {
            get {
                _colors = new Gdk.RGBA[rings, sectors];
                foreach (var cell in this) {
                    _colors[cell.ring, cell.sector] = cell.color;
                }

                return _colors;
            }
            set {
                if ((value.length[0] == rings) &&(value.length[1] == sectors)) {
                    foreach (var cell in this) {
                        cell.color = value[cell.ring, cell.sector];
                    }
                } else  {
                    error ("Invalid array dimensions");
                }
            }
        }

        /* Fill with initial data */
        public void init () {
            for (int i = 0; i < rings; i++) {
                for (int j = 0; j < sectors; j++) {
                    add ({ i, j,
                           Dactl.TriplePoint () { a = 0, b = 0, c = 0 },
                           Gdk.RGBA (),
                           AnnulusSector (),
                           ""});
                }
            }
        }
    }

    construct {
        objects = new Gee.TreeMap<string, Dactl.Object> ();
        data = new Dactl.PolarHeatMap.Data ();
    }

    /**
     * Construction using an XML node.
     */
    public PolarHeatMap.from_xml_node (Xml.Node *node) {
        build_from_xml_node (node);
    }

    /**
     * {@inheritDoc}
     */
    internal void build_from_xml_node (Xml.Node *node) {
        if (node->type == Xml.ElementType.ELEMENT_NODE &&
            node->type != Xml.ElementType.COMMENT_NODE) {
            id = node->get_prop ("id");
            this.node = node;

            /* Iterate through node children */
            for (Xml.Node *iter = node->children; iter != null; iter = iter->next) {
                if (iter->name == "property") {
                    switch (iter->get_prop ("name")) {
                        case "magnitude-min":
                            magnitude_min = double.parse (iter->get_content ());
                            break;
                        case "magnitude-max":
                            magnitude_max = double.parse (iter->get_content ());
                            break;
                        case "angle-min":
                            angle_min = double.parse (iter->get_content ());
                            break;
                        case "angle-max":
                            angle_max = double.parse (iter->get_content ());
                            break;
                        case "interpolation-type":
                            interpolation_type = iter->get_content ();
                            break;
                        case "rings":
                            data.rings = int.parse (iter->get_content ());
                            break;
                        case "sectors":
                            data.sectors = int.parse (iter->get_content ());
                            break;
                        default:
                            break;
                    }
                } else if (iter->name == "object") {
                    var type = iter->get_prop ("type");
                    if (type == "channel-matrix") {
                        channel_matrix = new Dactl.ChannelMatrix.from_xml_node (iter);
                        add_child (channel_matrix);
                    }
                }
            }
        }
        init ();
        connect_notify_signals ();
    }

    /**
     * {@inheritDoc}
     */
    protected void update_node () {
        if (node->type == Xml.ElementType.ELEMENT_NODE &&
            node->type != Xml.ElementType.COMMENT_NODE) {
            /* iterate through node children */
            for (Xml.Node *iter = node->children;
                 iter != null;
                 iter = iter->next) {
                if (iter->name == "property") {
                    switch (iter->get_prop ("name")) {
                        case "magnitude_min":
                            iter->set_content (magnitude_min.to_string ());
                            break;
                        case "magnitude_max":
                            iter->set_content (magnitude_max.to_string ());
                            break;
                        case "angle_min":
                            iter->set_content (angle_min.to_string ());
                            break;
                        case "angle_max":
                            iter->set_content (angle_max.to_string ());
                            break;
                        default:
                            break;
                    }
                }
            }
        }
    }

    private void init () {
        data.init ();
        data.cell_width = (this.magnitude_max - this.magnitude_min) / (double)data.rings;
        data.cell_sweep = (this.angle_max - this.angle_min) / (double)data.sectors;
        message ("Polar Heatmap Cell Coordinates");
        message ("rmin rmax tmin tmax %.3f, %.3f, %.3f, %.3f", magnitude_min, magnitude_max, angle_min, angle_max);
        var step_angle = (angle_max - angle_min) /(double)data.sectors;
        for (int i = 0; i < data.size; i++) {
            var cell = data.get (i);
            var a = magnitude_min + (magnitude_max - magnitude_min) *
                                             cell.ring / (double)data.rings;
            var b = angle_min + step_angle * cell.sector;
            cell.point = { a, b, 0 };
            data.set (i, cell);
            message ("  r s a b %d %d %.3f %.3f", cell.ring, cell.sector, a, b);
        }

        quantize.begin ();
    }

    /* map a data channel source to a cell */
    private async void quantize () {
        while ((channel_matrix != null) &&
                (!(channel_matrix.data.size == channel_matrix.objects.size)) &&
                !(channel_matrix.get_satisfied ())) {
            yield nap (1000);
        }

        for (int i = 0; i < data.size; i++) {
            var cell = data.get (i);
            foreach (var key in channel_matrix.data.keys) {
                var point = channel_matrix.data.get (key);

                if ((point.a < (cell.point.a + data.cell_width)) &&
                       (point.a >= cell.point.a) &&
                       (point.b < (cell.point.b + data.cell_sweep)) &&
                       (point.b >= cell.point.b)) {
                    cell.chref = key;
                    data.set (i, cell);
                }

                /*message ("cell (%d, %d) chref: %s", cell.ring, cell.sector, cell.chref);*/
            }
        }
    }

    private  async void nap (uint interval, int priority = GLib.Priority.DEFAULT) {
        GLib.Timeout.add (interval, () => {
            nap.callback ();
            return false;
        }, priority);
        yield;
    }

    /**
     * Connect all notify signals to update node
     */
    protected void connect_notify_signals () {
        Type type = get_type ();
        ObjectClass ocl = (ObjectClass)type.class_ref ();

        foreach (ParamSpec spec in ocl.list_properties ()) {
            notify[spec.get_name ()].connect ((s, p) => {
            debug ("type: %s spec: %s", type.name (), spec.get_name ());
                update_node ();
            });
        }
    }

    /**
     * {@inheritDoc}
     */
    private void update () {
        for (int i = 0; i < data.size; i++) {
            var cell = data.get (i);
            var point = cell.point;
            /* scale the value */
            var value = point.c;
            if (value > zmax)
                value = zmax;
            if (value < zmin)
                value = zmin;
            value = (value - zmin) / (zmax - zmin);

            switch (gradient) {
                case Dactl.ColorGradientType.RGB:
                    cell.color =  Dactl.UI.rgb_lerp (value,
                                                    min_color, 0, max_color, 1);
                    break;
                case Dactl.ColorGradientType.HSV:
                    cell.color =  Dactl.UI.hsv_lerp (value,
                                                    min_color, 0, max_color, 1);
                    break;
                default:
                    break;
            }

            data.set (i, cell);
        }
    }

    /**
     * Update the raw data
     */
    public void refresh () {
        for (int i = 0; i < data.size; i++) {
            var cell = data.get (i);
            var point = cell.point;
            if (channel_matrix.data.has_key (cell.chref)) {
                point.c = channel_matrix.data.get (cell.chref).c;
            }
            cell.point = point;
            data.set (i, cell);
        }
    }

    /* Set a color for cells that have no channel reference (ie. raw data) */
    private void interpolate () {
        /* XXX TBD */
    }

    /**
     * {@inheritDoc}
     */
    public void generate (int w, int h,
                           double x_min, double x_max,
                           double y_min, double y_max) {
        /* scale the reference plane from magnitude units to pixels */
        var scale_x = (double)w / (x_max - x_min);
        var scale_y = (double)h / (y_max - y_min);
        var scale = scale_x < scale_y ? scale_x : scale_y;
        scale = scale * zoom;
        var d = w < h ? w : h;
        /* calculate the offset from the center of the window */
        var dx = (w - scale * (x_max - x_min)) / 2;
        var dy = (h - scale * (y_max - y_min)) / 2;
/*
 *        message ("scaled: x_max, x_min, y_max, y_min %.3f %.3f %.3f %.3f",
 *                            x_max/scale, x_min/scale, y_max/scale, y_min/scale);
 *
 */
        var xc = -1 * scale * x_min + dx;
        var yc = scale * y_max + dy;
        /*
         *message ("w: %d h: %d", w, h);
         *message ("xc: %.3f yc: %.3f width: %.3f sweep: %.3f", xc, yc, data.cell_width, data.cell_sweep);
         */
        for (int i = 0; i < data.size; i++) {
            var cell = data.get (i);
            var sweep = Dactl.UI.degrees_to_radians (data.cell_sweep);
            /*message ("cell.point.a: %.3f cell.point.b: %.3f", cell.point.a, cell.point.b);*/

            var t = GLib.Math.PI * cell.point.b / 180.0;
            var x = scale * (cell.point.a * GLib.Math.cos (t) - x_min) + dx;
            var y = scale * (cell.point.a * GLib.Math.sin (t) - y_min) + dy;

            cell.annulus_sector = { x, y, xc, yc, t,
                                               scale * data.cell_width, sweep };
            data.set (i, cell);
            /*
             *message ("      x: %.3f y: %.3f",
             *                        data.get (i).annulus_sector.x,
             *                        data.get (i).annulus_sector.y);
             */
        }
        /*message ("");*/

        update();
    }

    /**
     * {@inheritDoc}
     */
    public void draw (Cairo.Context cr) {
        var stencil = new Dactl.PolarHeatMapView (image_surface);
        stencil.draw (data.colors, data.annulus_sectors);
        cr.set_operator (Cairo.Operator.OVER);
        cr.set_source_surface (stencil.get_target (), 0, 0);
        cr.paint ();
    }

    /**
     * {@inheritDoc}
     */
    public void update_objects (Gee.Map<string, Dactl.Object> val) {
        _objects = val;
    }
}
