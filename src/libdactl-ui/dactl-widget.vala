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
            default: assert_not_reached ();
        }
    }

    public string to_string () {
        switch (this) {
            case HORIZONTAL: return "horizontal";
            case VERTICAL:   return "vertical";
            default: assert_not_reached ();
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

public interface Dactl.Widget : GLib.Object {

    //public abstract bool expand { get; set; }

    public abstract bool fill { get; set; }
}

public abstract class Dactl.CustomWidget : Gtk.DrawingArea, Dactl.Widget, Dactl.Buildable, Dactl.Object {

    /**
     * {@inheritDoc}
     */
    public virtual string id { get; set; }

    //public bool expand { get; set; default = true; }

    /**
     * {@inheritDoc}
     */
    protected abstract string xml { get; }

    /**
     * {@inheritDoc}
     */
    protected abstract string xsd { get; }

    public bool fill { get; set; default = true; }

    /**
     * {@inheritDoc}
     */
    public abstract void build_from_xml_node (Xml.Node *node);
}

public abstract class Dactl.CompositeWidget : Gtk.Box, Dactl.Widget, Dactl.Container, Dactl.Buildable, Dactl.Object {

    /**
     * {@inheritDoc}
     */
    public virtual string id { get; set; }

    //public bool expand { get; set; default = true; }

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
