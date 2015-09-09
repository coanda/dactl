/**
 * Implementations of this interface will provide a relevant settings menu
 * and connect to it
 */
public interface Dactl.Settable : GLib.Object {

    protected abstract Dactl.SettingsWidget settings_menu { get; set; }

    /**
     * signal is emitted to indicate that a settings menu has been requested
     *
     * @param settings_menu The settings menu to be revealed
     */
    public abstract signal void reveal_menu (Gtk.Widget settings_menu);

    /**
     * Emit a signal when the item is double clicked
     */
    public virtual bool button_press_event_cb (Gdk.EventButton event) {
        if (event.type == Gdk.EventType.2BUTTON_PRESS) {
            update_settings_menu ();
            reveal_menu (settings_menu);
        }

        return false;
    }

    /**
     * Load the current settings values in to the menu widget
     */
    protected abstract void update_settings_menu ();
}

/**
 * A graphical interface e,ement that is used to set the properties of another
 * element.
 */
public interface Dactl.SettingsWidget : Gtk.Widget {

    /**
     * The parent of this
     */
    /*public abstract Dactl.Settable parent { get; set; }*/
}
