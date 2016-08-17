/**
 * Orientation options for the axis.
 */
public enum Dactl.Orientation {
    HORIZONTAL,
    VERTICAL;

    public Gtk.Orientation to_gtk () {
        switch (this) {
            case HORIZONTAL: return Gtk.Orientation.HORIZONTAL;
            case VERTICAL:   return Gtk.Orientation.VERTICAL;
            default:         assert_not_reached ();
        }
    }

    public string to_string () {
        switch (this) {
            case HORIZONTAL: return "horizontal";
            case VERTICAL:   return "vertical";
            default:         assert_not_reached ();
        }
    }

    public static Orientation[] all () {
        return {
            HORIZONTAL,
            VERTICAL
        };
    }

    public static Orientation parse (string value) {
        try {
            var regex_horiz = new Regex ("horizontal", RegexCompileFlags.CASELESS);
            var regex_vert = new Regex ("vertical", RegexCompileFlags.CASELESS);
            if (regex_horiz.match (value)) {
                return HORIZONTAL;
            } else if (regex_vert.match (value)) {
                return VERTICAL;
            }
        } catch (RegexError e) {
            message ("Orientation regex error: %s", e.message);
        }

        return HORIZONTAL;
    }
}

/**
 * PositionType options for the axis.
 */
public enum Dactl.PositionType {
    LEFT,
    RIGHT,
    TOP,
    BOTTOM;

    public Gtk.PositionType to_gtk () {
        switch (this) {
            case LEFT:   return Gtk.PositionType.LEFT;
            case RIGHT:  return Gtk.PositionType.RIGHT;
            case TOP:    return Gtk.PositionType.TOP;
            case BOTTOM: return Gtk.PositionType.BOTTOM;
            default:     assert_not_reached ();
        }
    }

    public string to_string () {
        switch (this) {
            case LEFT:   return "left";
            case RIGHT:  return "right";
            case TOP:    return "top";
            case BOTTOM: return "bottom";
            default:     assert_not_reached ();
        }
    }

    public static PositionType[] all () {
        return {
            LEFT,
            RIGHT,
            TOP,
            BOTTOM
        };
    }

    public static PositionType parse (string value) {
        try {
            var regex_left = new Regex ("left", RegexCompileFlags.CASELESS);
            var regex_right = new Regex ("right", RegexCompileFlags.CASELESS);
            var regex_top = new Regex ("top", RegexCompileFlags.CASELESS);
            var regex_bottom = new Regex ("bottom", RegexCompileFlags.CASELESS);
            if (regex_left.match (value)) {
                return LEFT;
            } else if (regex_right.match (value)) {
                return RIGHT;
            } else if (regex_top.match (value)) {
                return TOP;
            } else if (regex_bottom.match (value)) {
                return BOTTOM;
            }
        } catch (RegexError e) {
            message ("PositionType regex error: %s", e.message);
        }

        return LEFT;
    }
}

public enum Dactl.PolarAxisType {
    MAGNITUDE,
    ANGLE;

    public string to_string () {
        switch (this) {
            case MAGNITUDE: return "magnitude";
            case ANGLE:     return "angle";
            default:        assert_not_reached ();
        }
    }

    public static PolarAxisType[] all () {
        return {
            MAGNITUDE,
            ANGLE
        };
    }

    public static PolarAxisType parse (string value) {
        try {
            var regex_magnitude = new Regex ("magnitude", RegexCompileFlags.CASELESS);
            var regex_angle = new Regex ("angle", RegexCompileFlags.CASELESS);
            if (regex_magnitude.match (value)) {
                return MAGNITUDE;
            } else if (regex_angle.match (value)) {
                return ANGLE;
            }
        } catch (RegexError e) {
            message ("PolarAxisType regex error: %s", e.message);
        }

        return MAGNITUDE;
    }
}

public enum Dactl.ColorGradientType {
    RGB,
    HSV;

    public string to_string () {
        switch (this) {
            case RGB: return "rgb";
            case HSV: return "hsv";
            default:  assert_not_reached ();
        }
    }

    public static ColorGradientType[] all () {
        return {
            RGB,
            HSV
        };
    }

    public static ColorGradientType parse (string value) {
        try {
            var regex_rgb = new Regex ("rgb", RegexCompileFlags.CASELESS);
            var regex_hsv = new Regex ("hsv", RegexCompileFlags.CASELESS);
            if (regex_rgb.match (value)) {
                return RGB;
            } else if (regex_hsv.match (value)) {
                return HSV;
            }
        } catch (RegexError e) {
            message ("ColorGradientType regex error: %s", e.message);
        }

        return RGB;
    }
}

/**
 * Interface for all widgets.
 *
 * XXX Not all Dactl widgets are Gtk widgets so this is a lazy way of
 * enforcing classes that implement this to contain any properties
 * that are important.
 */
public interface Dactl.Widget : GLib.Object {

    //public abstract bool expand { get; set; }

    public abstract bool fill { get; set; }
}

/**
 * Simple canvas class to use for packable widgets.
 */
public abstract class Dactl.Canvas : Gtk.DrawingArea, Dactl.Object {

    private Xml.Node* _node;

    /**
     * {@inheritDoc}
     */
    public virtual string id { get; set; }
}

/**
 * Window base class to use with buildable child windows.
 *
 * XXX Probably unnecessary as there will probably only ever be a single class
 * that derives this.
 */
public abstract class Dactl.UI.WindowBase : Gtk.ApplicationWindow, Dactl.Container, Dactl.Buildable, Dactl.Object {

    private Xml.Node* _node;

    /**
     * {@inheritDoc}
     */
    public virtual string id { get; set; }

    /**
     * {@inheritDoc}
     */
    protected abstract string xml { get; }

    /**
     * {@inheritDoc}
     */
    protected abstract string xsd { get; }

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

    public bool fullscreen { get; set; default = false; }

    /**
     * Current window state
     */
    public Dactl.UI.WindowState state { get; set; default = Dactl.UI.WindowState.WINDOWED; }

    /**
     * {@inheritDoc}
     */
    public abstract Gee.Map<string, Dactl.Object> objects { get; set; }

    /**
     * {@inheritDoc}
     */
    public abstract void build_from_xml_node (Xml.Node *node);

    /**
     * {@inheritDoc}
     */
    public abstract void update_objects (Gee.Map<string, Dactl.Object> val);
}

/**
 *
 */
public abstract class Dactl.SimpleWidget : Gtk.Box, Dactl.Widget, Dactl.Buildable, Dactl.Object {

    private Xml.Node* _node;

    /**
     * {@inheritDoc}
     */
    public virtual string id { get; set; }

    /**
     * {@inheritDoc}
     */
    protected abstract string xml { get; }

    /**
     * {@inheritDoc}
     */
    protected abstract string xsd { get; }

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

    public bool fill { get; set; default = true; }

    /**
     * {@inheritDoc}
     */
    public abstract void build_from_xml_node (Xml.Node *node);

    /**
     * {@inheritDoc}
     */
    protected abstract void update_node ();
}

/**
 *
 */
public abstract class Dactl.CustomWidget : Gtk.DrawingArea, Dactl.Widget, Dactl.Buildable, Dactl.Object {

    private Xml.Node* _node;

    /**
     * {@inheritDoc}
     */
    public virtual string id { get; set; }

    /**
     * {@inheritDoc}
     */
    protected abstract string xml { get; }

    /**
     * {@inheritDoc}
     */
    protected abstract string xsd { get; }

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

    public bool fill { get; set; default = true; }

    /**
     * {@inheritDoc}
     */
    public abstract void build_from_xml_node (Xml.Node *node);

    /**
     * {@inheritDoc}
     */
    protected abstract void update_node ();
}

/**
 *
 */
public abstract class Dactl.CompositeWidget : Gtk.Box, Dactl.Widget, Dactl.Container, Dactl.Buildable, Dactl.Object {

    private Xml.Node* _node;

    /**
     * {@inheritDoc}
     */
    public virtual string id { get; set; }

    public bool fill { get; set; default = true; }

    /**
     * {@inheritDoc}
     */
    protected abstract string xml { get; }

    /**
     * {@inheritDoc}
     */
    protected abstract string xsd { get; }

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
    public abstract Gee.Map<string, Dactl.Object> objects { get; set; }

    /**
     * {@inheritDoc}
     */
    public abstract void build_from_xml_node (Xml.Node *node);

    /**
     * {@inheritDoc}
     */
    public abstract void update_objects (Gee.Map<string, Dactl.Object> val);
}
