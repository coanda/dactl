[GtkTemplate (ui = "/org/coanda/dactl/ui/settings-sidebar.ui")]
private class Dactl.SettingsSidebar : Gtk.Box {

    [GtkChild]
    private Gtk.ListStore listmodel;

    [GtkChild]
    private Gtk.TreeModelFilter model_filter;

    [GtkChild]
    private Gtk.TreeSelection selection;

    [GtkChild]
    private Gtk.TreeView tree_view;

    /*
     *[GtkChild]
     *private Gtk.Label label_change_status;
     */

    public weak GLib.SimpleAction selection_action { get; set; }

    construct {
        populate ();
        model_filter.set_visible_column (1);

        var path = new Gtk.TreePath.from_string ("0");
        tree_view.set_cursor (path, null, false);
    }

    private void list_append (string label, bool visible) {
        Gtk.TreeIter iter;

        listmodel.append (out iter);
        listmodel.set (iter, 0, label);
        listmodel.set (iter, 1, visible);
    }

    private void populate () {
        /*
         *foreach (var page in Dactl.SettingsStackPage.all ()) {
         *    message ("Adding %s to settings sidebar", page.to_string ());
         *    // Capitalize
         *    var name = page.to_string ();
         *    name.data[0] -= 0x20;
         *    list_append (name, true);
         *}
         */
    }

    [GtkCallback]
    private void row_activated_cb (Gtk.TreeView treeview, Gtk.TreePath path, Gtk.TreeViewColumn column) {
        Gtk.TreeIter filter_iter, iter;
        model_filter.get_iter (out filter_iter, path);
        model_filter.convert_iter_to_child_iter (out iter, filter_iter);

        //selection_action.activate ((Dactl.SettingsStackPage) listmodel.get_path (iter).get_indices ()[0]);
    }
}
