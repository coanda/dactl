private static int main (string[] args) {

    Gtk.init (ref args);

    var window = new Gtk.Window ();
    var chart = new Dactl.Chart ();

    window.add (chart);

    window.destroy.connect (Gtk.main_quit);
    window.show_all ();

    Gtk.main ();

    return 0;
}
