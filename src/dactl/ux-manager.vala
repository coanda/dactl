[DBus (name = "org.coanda.Dactl.UI.ManagerError")]
public errordomain Dactl.UI.UxManagerError {
    INVALID_FORMAT,
    INVALID_PARENT,
    NONE
}

[DBus (name = "org.coanda.Dactl.UI.Manager")]
public class Dactl.UI.UxManager : GLib.Object {

    private Dactl.UI.ApplicationView view;

    public UxManager (Dactl.UI.ApplicationView view) {
        this.view = view;

        Bus.own_name (BusType.SESSION,
                      "org.coanda.Dactl.UI.Manager",
                      BusNameOwnerFlags.NONE,
                      bus_acquired_cb,
                      () => {},
                      () => { critical ("Could not acquire name"); });
    }

    [DBus (visible = false)]
    public void bus_acquired_cb (DBusConnection connection) {
        try {
            connection.register_object ("/org/coanda/dactl/ui/manager", this);
        } catch (IOError error) {
            warning ("Could not register service: %s", error.message);
        }
    }

    public void @set (string property) {
        // XXX not sure of whether to use a generic or variant???
    }

    public void @get (string property) {
    }

    /**
     * List all of the pages that are contained in the view.
     *
     * @return Array of strings with the page ID values
     */
    public string[] list_pages () {
        var page_map = view.model.get_object_map (typeof (Dactl.Page));
        string[] pages = {};

        foreach (var page in page_map.values) {
            pages += page.id;
        }

        return pages;
    }

    /**
     * Add a widget using the data provided.
     *
     * @param data JSON string representing the class to deserialize and add
     */
    public void add_widget (string data) throws Error {
        /**
         * eg:
         *  "{ 'type': 'DactlWindow', 'properties': { 'dest': '', 'id': 'win0' } }"
         *  "{ 'type': 'DactlPage', 'properties': { 'dest': '', 'id': 'pg1' } }"
         *  "{ 'type': 'DactlPage', 'properties': { 'dest': 'win0', 'id': 'pg1' } }"
         *  "{ 'type': 'DactlBox', 'properties': { 'dest': 'pg0', 'id': 'box0', 'orientation': 'horizontal' } }"
         *  "{ 'type': 'DactlBox', 'properties': { 'dest': 'box0', 'id': 'box0-0', 'orientation': 'vertical' } }"
         *  "{ 'type': 'DactlBox', 'properties': { 'dest': 'box0', 'id': 'box0-1', 'orientation': 'vertical' } }"
         *  "{ 'type': 'DactlUIRichContent', 'properties': { 'dest': 'box0-1', 'id': 'rc0', 'uri': 'http://10.0.2.2/~gjohn/dev/dcs/' } }"
         */

        string? name = null;
        string? parent = null;
        Dactl.Object object = null;

        try {
            Json.Parser parser = new Json.Parser ();
            parser.load_from_data (data);

            debug (data);

            Json.Node root = parser.get_root ();
            Json.Object root_obj = root.get_object ();

            Json.Node node = root_obj.get_member ("properties");
            if (node.get_node_type () != Json.NodeType.OBJECT) {
                throw new Dactl.UI.UxManagerError.INVALID_FORMAT ("Unexpected element type %s", node.type_name ());
            }
            Json.Object obj = node.get_object ();

            name = root_obj.get_string_member ("type");
            parent = obj.get_string_member ("dest");

            debug ("Add a %s to %s", name, parent);
            // XXX why is this needed? Type.from_name appears to work fine.
            Type type = Dactl.type_from_name (name);
            debug ("Received type: %s", type.name ());

            object = Json.gobject_deserialize (Type.from_name (name), node) as Dactl.Object;
            //object = Json.gobject_deserialize (type, node) as Dactl.Object;
        } catch (Error e) {
            warning ("Could not deserialize JSON data");
        }

        if (parent == "" || parent == "root" || parent == null) {
            if (object is Dactl.Page) {
                view.layout_add_page (object as Dactl.Page);
            } else if (object is Dactl.UI.Window) {
                view.add_window (object as Dactl.UI.Window);
            }
        } else {
            var container = view.model.get_object (parent);
            if (container is Dactl.Container) {
                if (container is Dactl.UI.Window) {
                    (container as Dactl.UI.Window).add_child (object);
                } else if (container is Dactl.Page) {
                    (container as Dactl.Page).add_child (object);
                } else if (container is Dactl.Box) {
                    (container as Dactl.Box).add_child (object);
                }
                (container as Gtk.Widget).show_all ();
            } else {
                throw new Dactl.UI.UxManagerError.INVALID_PARENT ("An invalid parent was provided");
            }
        }
    }

    /**
     * Remove a widget using the provided parent and child id values.
     * TODO redraw the UI container
     *
     * @param parent ID value to remove the child from
     * @param child ID value of the child to remove
     */
    public void remove_widget (string parent, string child) {
        var parent_obj = view.model.get_object (parent);
        if (parent_obj is Dactl.Container) {
            var child_obj = (parent_obj as Dactl.Container).get_object (child);
            (parent_obj as Dactl.Container).remove_child (child_obj);
        }
    }

    /**
     * Toggle the fullscreen state of a window.
     *
     * @param id ID value for the window to toggle the fullscreen state of
     */
    public void fullscreen (string id) {
        var window = view.model.get_object (id);
        if (window is Dactl.UI.Window) {
            (window as GLib.ActionGroup).activate_action ("fullscreen", null);
        }
    }
}
