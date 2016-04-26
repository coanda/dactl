[GtkTemplate (ui = "/org/coanda/dactl/ui/settings-treeview.ui")]
public abstract class Dactl.SettingsTreeView : Gtk.TreeView {
    protected int tree_depth = 10;

    /* XXX FIXME Make this resizable */
    protected Gtk.TreeIter[] treeiter;

    //[GtkChild]
    protected Gtk.TreeStore treestore;

    protected Gtk.TreePath active_path;

    /**
     * true if the selected row's children should expand
     */
    protected bool expand_all;

    construct {
        add_events (Gdk.EventMask.BUTTON_PRESS_MASK |
                    Gdk.EventMask.BUTTON_RELEASE_MASK |
                    Gdk.EventMask.POINTER_MOTION_MASK |
                    Gdk.EventMask.KEY_PRESS_MASK |
                    Gdk.EventMask.KEY_RELEASE_MASK |
                    Gdk.EventMask.SCROLL_MASK);

        treeiter = new Gtk.TreeIter[tree_depth];
    }

    [GtkCallback]
    public abstract void cursor_changed_cb ();

    [GtkCallback]
    public virtual void row_activated_cb (Gtk.TreePath path, Gtk.TreeViewColumn column) {
        active_path = path;
    }

    /**
     * Use double click to expand the row and ctrl double click to expand all
     */
    [GtkCallback]
    public bool button_press_event_cb (Gdk.EventButton event) {
        if (event.button == 1) {
            if ((event.type & Gdk.EventType.DOUBLE_BUTTON_PRESS) ==
                                            Gdk.EventType.DOUBLE_BUTTON_PRESS) {
                if ((event.state & Gdk.ModifierType.CONTROL_MASK) ==
                                            Gdk.ModifierType.CONTROL_MASK) {
                    expand_all = true;
                } else {
                    expand_all = false;
                }

                if (is_row_expanded (active_path)) {
                    collapse_row (active_path);
                } else {
                    expand_row (active_path, expand_all);
                }
            }
        }

        return false;
    }
}

public class Dactl.CldSettingsTreeView : Dactl.SettingsTreeView {
    public enum Columns {
        TYPE,
        ID,
        URI
    }

    /* Emits a signal containing the unique idetifier of the selected row */
    public signal void select (string identity);

    construct {
        treestore = new Gtk.TreeStore (3, typeof (string), typeof (string), typeof (string));
        set_model (treestore);

        insert_column_with_attributes (Columns.TYPE, "Object Type",
                        new Gtk.CellRendererText (), "text", Columns.TYPE, null);
        insert_column_with_attributes (Columns.ID, "ID",
                        new Gtk.CellRendererText (), "text", Columns.ID, null);
        insert_column_with_attributes (Columns.URI, "URI",
                        new Gtk.CellRendererText (), "text", Columns.URI, null);
    }

    public void generate (Cld.Object object, int d) {
        GLib.Type type = object.get_type ();
        GLib.ObjectClass ocl = (ObjectClass)type.class_ref ();
        if (d > 0)
            treestore.append (out treeiter[d], treeiter[d - 1]);
        else
            treestore.append (out treeiter[d], null);
        treestore.set (treeiter[d], Columns.TYPE, object.get_nickname (),
                                    Columns.ID, object.id,
                                    Columns.URI, object.uri,
                                    -1);

        if (object is Cld.Container) {
            foreach (var obj in (object as Cld.Container).get_objects ().values) {
                /** XXX TBD - This will require some restructuring of the
                  * Cld library make it to work properly.
                  *
                  * Populate only direct descendants if not in a:dministrator mode
                  *
                  *var admin = Dactl.UI.Application.get_default ().model.admin;
                  *var related = obj.get_parent_uri () == object.uri;
                  *if (admin || related)
                  */
                    generate (obj, d + 1);
            }
        }
    }

    public override void cursor_changed_cb () {
        Gtk.TreePath path;
        Gtk.TreeViewColumn column;

        get_cursor (out path, out column);
        if (path != null) {
            Gtk.TreeIter iterator;
            treestore.get_iter (out iterator, path);
            string* uri = "";
            treestore.get (iterator, Columns.URI, &uri, -1);
            debug ("selected path: %s column: %s uri: %s", path.to_string (), column.get_title (), uri);
            select (uri);
            GLib.free (uri);
        }
    }
}


public class Dactl.NativeSettingsTreeView : Dactl.SettingsTreeView {
    public enum Columns {
        TYPE,
        ID,
        OBJECT
    }

    /* Emits a signal containing the unique idetifier of the selected row */
    public signal void select (Dactl.Object object);

    construct {
        /*
         *var ts = new Gtk.TreeStore (2, typeof (string), typeof (string));
         */
        treestore = new Gtk.TreeStore (3, typeof (string), typeof (string), typeof (void*));
        set_model (treestore);
        insert_column_with_attributes (Columns.TYPE, "Object Type",
                        new Gtk.CellRendererText (), "text", Columns.TYPE, null);
        insert_column_with_attributes (Columns.ID, "ID",
                        new Gtk.CellRendererText (), "text", Columns.ID, null);
    }

    public void generate (Gee.Map<string, Dactl.Object> map, int d) {
        foreach (var object in map.values)
            generate_from_object (object, d);
    }

    public void generate_from_object (Dactl.Object object, int d) {
        GLib.Type type = object.get_type ();
        GLib.ObjectClass ocl = (ObjectClass)type.class_ref ();
        void* o = object;

        if (d > 0)
            treestore.append (out treeiter[d], treeiter[d - 1]);
        else
            treestore.append (out treeiter[d], null);
        /* XXX FIXME This should use nicknames, not names
         *treestore.set (treeiter[d], Columns.TYPE, object.get_nickname (),
         *                            Columns.ID, object.id,
         *                            -1);
         */
        /*
         *treestore.set (treeiter[d], Columns.TYPE, object.get_type ().name (),
         *                            Columns.ID, object.id,
         *                            Columns.OBJECT, object,
         *                            -1);
         */
        treestore.set (treeiter[d], Columns.TYPE, object.get_type ().name (),
                                    Columns.ID, object.id,
                                    Columns.OBJECT, o,
                                    -1);

        if (object is Dactl.Container) {
            foreach (var obj in (object as Dactl.Container).objects.values) {
                    generate_from_object (obj, d + 1);
            }
        }
    }

    public override void cursor_changed_cb () {
        Gtk.TreePath path;
        Gtk.TreeViewColumn column;

        get_cursor (out path, out column);

        if (path != null) {
            Gtk.TreeIter iterator;
            treestore.get_iter (out iterator, path);
            void* object = null;
            treestore.get (iterator, Columns.OBJECT, &object, -1);
            debug ("object id: %s", (object as Dactl.Object).id);
            select (object as Dactl.Object);
        }
    }
}

