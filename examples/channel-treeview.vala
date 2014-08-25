/**
 * To compile:

     valac -X -I../src/libdactl-ui/ -X -I../src/libdactl-core/ \
        -X -L../src/libdactl-ui/ -X -L../src/libdactl-core/ \
        -X -ldactl-ui-0.3 -X -ldactl-core-0.3 --vapidir ../src/libdactl-core/ \
        --vapidir ../src/libdactl-ui/ --pkg dactl-ui-0.3 channel-treeview.vala
 */

private static int main (string[] args) {

    Gtk.init (ref args);

    var window = new Gtk.Window ();
    var treeview = new Dactl.ChannelTreeView ();

    treeview.channels_loaded.connect (() => {
        message ("All channels have been loaded");
    });

    var channel = new Cld.AIChannel ();
    channel.id = "ai0";

    treeview.request_object.connect ((id) => {
        treeview.offer_cld_object (channel);
    });

    var calibration = new Cld.Calibration ();
    calibration.id = "cal0";
    (channel as Cld.Container).add (calibration);

    var entry = new Dactl.ChannelTreeEntry ();
    entry.ch_ref = channel.id;

    var category = new Dactl.ChannelTreeCategory ();
    category.add_child (entry);

    (treeview as Dactl.Container).add_child (category);

    window.add (treeview);

    window.destroy.connect (Gtk.main_quit);
    window.show_all ();

    Gtk.main ();

    return 0;
}
