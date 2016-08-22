public enum Dactl.UI.WindowState {
    WINDOWED,
    FULLSCREEN
}

[GtkTemplate (ui = "/org/coanda/libdactl/ui/window.ui")]
public class Dactl.UI.Window : Dactl.UI.WindowBase {

    private string _xml = """
    """;

    private string _xsd = """
    """;

    public int index { get; set; default = 0; }

    //public string title { get; set; default = "Window"; }

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
    private Gee.Map<string, Dactl.Object> _objects;
    public override Gee.Map<string, Dactl.Object> objects {
        get { return _objects; }
        set { update_objects (value); }
    }

    private string[] pages = { };

    [GtkChild]
    private Gtk.Stack layout;

    /**
     * Common object construction.
     */
    construct {
        id = "win0";
        name = id;
        objects = new Gee.TreeMap<string, Dactl.Object> ();

        set_default_size (1280, 720);
        /*
         *load_style ();
         */
    }

    /**
     * Default construction.
     */
    public Window () {
        GLib.Object (title: "Data Acquisition and Control - Child Window",
                     window_position: Gtk.WindowPosition.CENTER);
    }

    /**
     * Construction using an XML node.
     */
    public Window.from_xml_node (Xml.Node *node) {
        GLib.Object (title: "Data Acquisition and Control - Child Window",
                     window_position: Gtk.WindowPosition.CENTER);

        build_from_xml_node (node);
    }

    /**
     * {@inheritDoc}
     */
    public override void build_from_xml_node (Xml.Node *node) {
        string? value;
        string type;

        if (node->type == Xml.ElementType.ELEMENT_NODE &&
            node->type != Xml.ElementType.COMMENT_NODE) {
            name = id = node->get_prop ("id");

            /* Iterate through node children */
            for (Xml.Node *iter = node->children; iter != null; iter = iter->next) {
                if (iter->name == "property") {
                    switch (iter->get_prop ("name")) {
                        case "index":
                            value = iter->get_content ();
                            index = int.parse (value);
                            break;
                        case "title":
                            title = iter->get_content ();
                            break;
                        default:
                            break;
                    }
                } else if (iter->name == "object") {
                    Dactl.Object? object = null;
                    type = iter->get_prop ("type");
                    /**
                     * XXX will need to add checks for pnid and plugin types
                     *     when they get implemented
                     */
                    switch (type) {
                        case "page":
                            object = new Dactl.Page.from_xml_node (iter);
                            break;
                    }

                    /* no point adding an object type that isn't recognized */
                    if (object != null) {
                        message ("Loading object of type `%s' with id `%s'", type, object.id);
                        add_child (object);
                    }
                }
            }
        }
    }

    /**
     * Load the application styling from CSS.
     */
    /*
     *private void load_style () {
     *    [> Apply stylings from CSS resource <]
     *    var provider = Dactl.load_css ("theme/shared.css");
     *    Gtk.StyleContext.add_provider_for_screen (Gdk.Screen.get_default (),
     *                                              provider,
     *                                              600);
     *}
     */

    public void add_actions () {
        var fullscreen_action = new SimpleAction ("fullscreen", null);
        fullscreen_action.activate.connect (fullscreen_action_activated_cb);
        this.add_action (fullscreen_action);
    }

    public void add_page (Dactl.Page page) {
        debug ("Adding page `%s' with title `%s'", page.id, page.title);
        layout.add_titled (page, page.id, page.title);
        pages += page.id;

        // XXX not sure what to do here, needs to do it otherwise won't be configurable
        //model.add_child (page);
    }

    public void add_child (Dactl.Object object) {
        (base as Dactl.Container).add_child (object);
        debug ("Attempting to add widget `%s' to window `%s'", object.id, id);
        if (object is Dactl.Page) {
            add_page (object as Dactl.Page);
        } else {
            warning ("Windows can only add pages for now");
        }
    }

    /**
     * {@inheritDoc}
     */
    public override void update_objects (Gee.Map<string, Dactl.Object> val) {
        _objects = val;
    }

    /**
     * {@inheritDoc}
     */
    /*
     *protected void update_node () { }
     */

    /**
     * Action callback to set fullscreen window mode.
     */
    private void fullscreen_action_activated_cb (SimpleAction action, Variant? parameter) {
        if (state == Dactl.UI.WindowState.WINDOWED) {
            (this as Gtk.Window).fullscreen ();
            state = Dactl.UI.WindowState.FULLSCREEN;
            fullscreen = true;
        } else {
            (this as Gtk.Window).unfullscreen ();
            state = Dactl.UI.WindowState.WINDOWED;
            fullscreen = false;
        }
    }

    [GtkCallback]
    private bool configure_event_cb () {
        return false;
    }

    [GtkCallback]
    private bool delete_event_cb () {
        return false;
    }

    [GtkCallback]
    private bool key_press_event_cb () {
        return false;
    }

    [GtkCallback]
    private bool window_state_event_cb (Gdk.EventWindowState event) {
        if (Dactl.UI.WindowState.FULLSCREEN in event.changed_mask)
            this.notify_property ("fullscreen");

        if (state == Dactl.UI.WindowState.FULLSCREEN)
            return false;

        return false;
    }
}
