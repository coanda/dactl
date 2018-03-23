/**
 * A common interface for different types of user interfaces.
 *
 * XXX not sure how this fits in yet, possible rename to View and AbstractView
 *     and base the UI and CLI views off of these.
 * XXX should these be buildable? if so that would allow for a configuration
 *     selectable interface.
 */
//[GenericAccessors]
//public interface Dactl.View : GLib.Object {

    /**
     * Used to select application administrative features.
     */
    //public abstract bool admin { get; set; }

    /**
     * Read-only property to tell if the interface is active.
     */
    //public abstract bool active { get; private set; }

    /**
     * Launch the interface.
     */
    //public abstract void launch ();

    /**
     * Shutdown the interface.
     */
    //public abstract void shutdown ();

    /**
     * When the interface has been launched.
     */
    //public abstract signal void opened ();

    /**
     * When the interface has been shutdown.
     */
    //public abstract signal void closed ();
//}

/**
 * Skeletal implementation of the {@link Interface} interface.
 *
 * Contains common code shared by all interface implementations.
 */
//public abstract class Dactl.AbstractView : Dactl.AbstractObject, Dactl.View {

    /**
     * {@inheritDoc}
     */
    //public abstract bool admin { get; set; }

    /**
     * {@inheritDoc}
     */
    //public abstract bool active { get; private set; }

    /**
     * {@inheritDoc}
     */
    //public abstract void launch ();

    /**
     * {@inheritDoc}
     */
    //public abstract void shutdown ();

    /**
     * {@inheritDoc}
     */
    //public abstract signal void opened ();

    /**
     * {@inheritDoc}
     */
    //public abstract signal void closed ();
//}
