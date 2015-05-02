[GtkTemplate (ui = "/org/coanda/dactl/ui/settings-treeview.ui")]
public class Dactl.SettingsTreeView : Gtk.TreeView {

    public enum Columns {
        OBJECT,
        ID,
        URI
    }

    protected int tree_depth = 10;

    /* XXX FIXME Make this resizable */
    protected Gtk.TreeIter[] treeiter;

    [GtkChild]
    protected Gtk.TreeStore treestore;

    /* Emits a signal containing the URI of the selected row */
    public signal void select (string uri);

    construct {
        treeiter = new Gtk.TreeIter[tree_depth];

        insert_column_with_attributes (Columns.OBJECT, "Object",
                        new Gtk.CellRendererText (), "text", Columns.OBJECT);
        insert_column_with_attributes (Columns.ID, "ID",
                        new Gtk.CellRendererText (), "text", Columns.ID);
        insert_column_with_attributes (Columns.URI, "URI",
                        new Gtk.CellRendererText (), "text", Columns.URI);

    }

    public void generate (Cld.Object object, int d) {
        GLib.Type type = object.get_type ();
        GLib.ObjectClass ocl = (ObjectClass)type.class_ref ();

        if (d > 0)
            treestore.append (out treeiter[d], treeiter[d - 1]);
        else
            treestore.append (out treeiter[d], null);
        treestore.set (treeiter[d], Columns.OBJECT, object.get_nickname (),
                                    Columns.ID, object.id,
                                    Columns.URI, object.uri,
                                    -1);

        if (object is Cld.Container) {
            foreach (var obj in (object as Cld.Container).get_objects ().values) {
                /** XXX TBD - This will require some restructuring of the
                  * Cld library make it to work properly.
                  *
                  * Populate only direct descendants if not in administrator mode
                  *
                  *var admin = Dactl.UI.Application.get_default ().model.admin;
                  *var related = obj.get_parent_uri () == object.uri;
                  *if (admin || related)
                  */
                    generate (obj, d + 1);
            }
        }
    }

    [GtkCallback]
    public void cursor_changed_cb () {
        Gtk.TreePath path;
        Gtk.TreeViewColumn column;

        get_cursor (out path, out column);
        Gtk.TreeIter iterator;
        treestore.get_iter (out iterator, path);
        string* uri = "";
        treestore.get (iterator, Columns.URI, &uri, -1);
        message ("selected path: %s column: %s uri: %s", path.to_string (), column.get_title (), uri);
        select (uri);
        GLib.free (uri);
    }

    /*
     *[GtkCallback]
     *public void row_activated_cb (Gtk.TreePath path, Gtk.TreeViewColumn column) {
     *    Gtk.TreeIter iterator;
     *    treestore.get_iter (out iterator, path);
     *    string* uri = "";
     *    treestore.get (iterator, Columns.URI, &uri, -1);
     *    message ("selected path: %s column: %s uri: %s", path.to_string (), column.get_title (), uri);
     *    select (uri);
     *    GLib.free (uri);
     *}
     */
}
