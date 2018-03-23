[Compact]
public class Dactl.Point : GLib.Object {
    public double x { get; set; default = 0.0; }
    public double y { get; set; default = 0.0; }

    public Point (double x, double y) {
        GLib.Object (x : x, y : y);
    }
}

public struct Dactl.SimplePoint {
    double x;
    double y;
}

public struct Dactl.TriplePoint {
    public double a;
    public double b;
    public double c;
}
