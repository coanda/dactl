[Compact]
private class Dactl.ZoomWindow : Cairo.Context {

    public ZoomWindow (Cairo.Surface target) {
        base (target);
    }

    /*
     *public void draw (Cairo.Context source, int x, int y) {
     *}
     */

    public void draw () {
        scale (2.0, 2.0);
    }
}
