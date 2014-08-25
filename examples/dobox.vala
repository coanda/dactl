private static int main (string[] args) {

    Gtk.init (ref args);

    var window = new Gtk.Window ();
    var dobox = new Dactl.DOBox ("do0");

    var channel = new Cld.DOChannel ();
    channel.id = "do0";

    dobox.request_object.connect ((id) => {
        message ("The channel `%s' was requested", id);
        dobox.offer_cld_object (channel);
    });

    window.add (dobox);

    window.destroy.connect (Gtk.main_quit);
    window.show_all ();

    Gtk.main ();

    return 0;
}
