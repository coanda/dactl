private static int main (string[] args) {

    Gtk.init (ref args);

    var window = new Gtk.Window ();
    var aobox = new Dactl.AOBox ("ao0");

    var channel = new Cld.AOChannel ();
    channel.id = "ao0";

    aobox.request_object.connect ((id) => {
        message ("The channel `%s' was requested", id);
        aobox.offer_cld_object (channel);
    });

    window.add (aobox);

    window.destroy.connect (Gtk.main_quit);
    window.show_all ();

    Gtk.main ();

    return 0;
}
