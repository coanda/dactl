/**
 * A common interface for many of the objects used throughout. This is a near
 * useless comment and should be fixed in the future.
 */
[GenericAccessors]
public interface Dactl.Object : GLib.Object {

    /**
     * The identifier for the object.
     */
    public abstract string id { get; set; }

    /**
     * Specifies whether the objects provided are equivalent for sorting.
     *
     * @param a one of the objects to use in the comparison.
     * @param b the other object to use in the comparison.
     *
     * @return  ``true`` or ``false`` depending on whether or not the id
     *          parameters match
     */
    public abstract bool equal (Dactl.Object a, Dactl.Object b);

    /**
     * Compares the object to another that is provided.
     *
     * @param a the object to compare this one against.
     *
     * @return  ``0`` if they contain the same id, ``1`` otherwise
     */
    public abstract int compare (Dactl.Object a);
}

/**
 * Skeletal implementation of the {@link Object} interface.
 *
 * Contains common code shared by all object implementations.
 */
public abstract class Dactl.AbstractObject : GLib.Object, Dactl.Object {

    /**
     * {@inheritDoc}
     */
    public abstract string id { get; set; }

    /**
     * {@inheritDoc}
     */
    public virtual bool equal (Dactl.Object a, Dactl.Object b) {
        return a.id == b.id;
    }

    /**
     * {@inheritDoc}
     */
    public virtual int compare (Dactl.Object a) {
        if (id == a.id) {
            return 0;
        } else {
            return 1;
        }
    }
}
