/**
 * Various helper utilities, some copied from Boxes.
 */
internal class Dactl.Utility {

    public static Gee.List<double?> hex_to_rgb (string hex) {
        Gee.ArrayList<double?> rgb = new Gee.ArrayList<double?> ();

        Gdk.Color color = Gdk.Color ();
        Gdk.Color.parse (hex, out color);
        rgb.add (color.red / 65535.0);
        rgb.add (color.green / 65535.0);
        rgb.add (color.blue / 65535.0);

        return rgb;
    }

    public static Gdk.Pixbuf load_asset (string asset) throws GLib.Error {
        return new Gdk.Pixbuf.from_resource ("/org/coanda/libdactl/icons/" + asset);
    }

    public static Gtk.Builder load_ui (string ui) {
        var builder = new Gtk.Builder ();
        try {
            builder.add_from_resource ("/org/coanda/libdactl/ui/".concat (ui, null));
        } catch (GLib.Error e) {
            GLib.error ("Failed to load UI file `%s': %s", ui, e.message);
        }
        return builder;
    }

    public static Rsvg.Handle load_svg (string svg) {
        Rsvg.Handle rsvg;
        try {
            rsvg = new Rsvg.Handle.from_file (svg);
        } catch (GLib.Error e) {
            GLib.error ("Failed to load SVG file `%s': %s", svg, e.message);
        }
        return rsvg;
    }

    public static Gdk.RGBA get_dactl_bg_color () {
        var style = new Gtk.StyleContext ();
        var path = new Gtk.WidgetPath ();
        path.append_type (typeof (Gtk.Window));
        style.set_path (path);
        style.add_class ("dactl-bg");
        return style.get_background_color (0);
    }

    public static Gdk.RGBA get_color (string desc) {
        Gdk.RGBA color =  Gdk.RGBA ();
        color.parse (desc);
        return color;
    }
}
