/**
 * To compile:

     valac -X -I../src/libdactl-ui/ -X -I../src/libdactl-core/ \
        -X -L../src/libdactl-ui/ -X -L../src/libdactl-core/ \
        -X -ldactl-ui-0.3 -X -ldactl-core-0.3 --vapidir ../src/libdactl-core/ \
        --vapidir ../src/libdactl-ui/ --pkg dactl-ui-0.3 box.vala
 */

private static int main (string[] args) {

    Gtk.init (ref args);

    var window = new Gtk.Window ();
    var box = new Dactl.Box ();
    (box as Gtk.Box).orientation = Gtk.Orientation.HORIZONTAL;

    Type type = typeof (Dactl.Box);
    stdout.printf ("\n--- ex: %s ---\n\n", type.name ());

    window.add (box);

    window.destroy.connect (Gtk.main_quit);
    window.show_all ();

    Gtk.main ();

    return 0;
}
