/**
 * Helper utilities for the UI namespace, mainly an extension of others
 * in the core or application areas.
 */
namespace Dactl.UI {

    /**
     * Type of the object to test for.
     *
     * @param name Name of the type to check
     * @return Valid type on success, null otherwise
     */
    public Type? type_from_name (string name) {
        Type? type = null;

        string simplified = name.replace ("ui", "");

        switch (simplified) {
			case "aicontrol":
				type = typeof (Dactl.AIControl);
				break;
            case "aocontrol":
                type = typeof (Dactl.AOControl);
                break;
			case "box":
				type = typeof (Dactl.Box);
				break;
            case "channeltreeview":
                type = typeof (Dactl.ChannelTreeView);
                break;
            case "page":
                type = typeof (Dactl.Page);
                break;
            case "richcontent":
                type = typeof (Dactl.UI.RichContent);
                break;
            case "window":
                type = typeof (Dactl.UI.Window);
                break;
            default:
                break;
        }

        return type;
    }

    /**
     * A sign or signum function.
     *
     * @param x Any double precision number
     * @return 1 if x > 0, 0 if x = 0, -1 if x < 0
     */
    public int signum (double x) {
        if (x == 0)
            return 0;
        else
            return (int)(GLib.Math.fabs (x) / x);
    }

    /**
     * Convert angle from degrees to radians
     *
     * @param t angle in degrees
     * @return angle in radians
     */
    public double degrees_to_radians (double t) {
        return t * GLib.Math.PI / 180;
    }

    /**
     * Convert angle in radians to an equivalent positive value < 360
     *
     * @param t angle in degrees
     * @return positive angle less than 360
     */
    public double degrees_to_positive (double t) {
        var value = GLib.Math.fabs (GLib.Math.fmod (t, 360));
        if (t < 0)
            value = 360 - value;

        return value;
    }

    /**
     * Linear interpolation of in HSV color space *
     *
     * @param value1 the smallest values
     * @param color1 color represented by value1
     * @param value2 the largest value
     * @param color2 color represented by value2
     * @return the interpolated color
     */
    private Gdk.RGBA hsv_lerp (double value,
                               Gdk.RGBA color1, double value1,
                               Gdk.RGBA color2, double value2)
                               requires (value2 > value1)
                               requires (value >= value1)
                               requires (value <= value2)
                               requires (value1 >= 0)
                               requires (value1 <=1.0)
                               requires (value2 >= 0)
                               requires (value2 <=1.0) {
        double h1, s1, v1;
        double h2, s2, v2;
        double h, s, v;
        double r, g, b, a;

        Gtk.rgb_to_hsv (color1.red, color1.green, color1.blue,
                                                        out h1, out s1, out v1);
        Gtk.rgb_to_hsv (color2.red, color2.green, color2.blue,
                                                        out h2, out s2, out v2);

        h = h1 + (value - value1) * (h2 - h1);
        s = s1 + (value - value1) * (s2 - s1);
        v = v1 + (value - value1) * (v2 - v1);
        a = color1.alpha + (value - value1) * (color2.alpha - color1.alpha);

        Gtk.HSV.to_rgb (h, s, v, out r, out g, out b);
        Gdk.RGBA color = Gdk.RGBA () { red = r, green = g, blue = b, alpha = a };

        return color;
    }

    /**
     * Linear interpolation of in RGB color space *
     *
     * @param value1 the smallest values
     * @param color1 color represented by value1
     * @param value2 the largest value
     * @param color2 color represented by value2
     * @return the interpolated color
     */
    private Gdk.RGBA rgb_lerp (double value,
                               Gdk.RGBA color1, double value1,
                               Gdk.RGBA color2, double value2)
                               requires (value2 > value1)
                               requires (value >= value1)
                               requires (value <= value2)
                               requires (value1 >= 0)
                               requires (value1 <=1.0)
                               requires (value2 >= 0)
                               requires (value2 <=1.0) {
        double r, g, b, a;

        r = color1.red + (value - value1) * (color2.red - color1.red);
        g = color1.green + (value - value1) * (color2.green - color1.green);
        b = color1.blue + (value - value1) * (color2.blue - color1.blue);
        a = color1.alpha + (value - value1) * (color2.alpha - color1.alpha);

        Gdk.RGBA color = Gdk.RGBA () { red = r, green = g, blue = b, alpha = a };

        return color;
    }

	/**
     * Convert a hexidecimal string into the corresponding RGB values.
     *
     * @param hex Hexidecimal string to convert
     * @return A list of doubles representing the RGB values
     */
    public Gee.List<double?> hex_to_rgb (string hex) {
        Gee.ArrayList<double?> rgb = new Gee.ArrayList<double?> ();

        Gdk.Color color = Gdk.Color ();
        Gdk.Color.parse (hex, out color);
        rgb.add (color.red / 65535.0);
        rgb.add (color.green / 65535.0);
        rgb.add (color.blue / 65535.0);

        return rgb;
    }

	/**
     * Get the Gdk color value for a given descriptive value, eg. `blue'.
     *
     * @param desc The description value to convert.
     * @return The color struct for the given descriptive value.
     */
    public Gdk.RGBA get_color (string desc) {
        Gdk.RGBA color = Gdk.RGBA ();
        color.parse (desc);
        return color;
    }
}
