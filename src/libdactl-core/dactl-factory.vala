public errordomain Dactl.FactoryError {
    TYPE_NOT_FOUND
}

public interface Dactl.Factory : GLib.Object {
    /**
     * Emitted when a build of the object tree has completed.
     */
    public signal void build_complete ();

    /**
     * Constructs the object tree using the top level object types, which for
     * the time being are only pages.
     *
     * @param node XML content to use for building application objects from
     */
    public abstract Gee.TreeMap<string, Dactl.Object> make_object_map (Xml.Node *node);

    /**
     * Constructs an object of the type provided using the default build
     * settings for that class and returns the result.
     *
     * @param type Class type to construct.
     * @return Resulting object constructed with associated default settings
     */
    public abstract Dactl.Object make_object (Type type)
                                              throws GLib.Error;

    /**
     * Constructs an object using the XML node provided and returns the result.
     *
     * @param node Configuration node to base the object off of
     * @return Resulting object constructed from the input node
     */
    public abstract Dactl.Object make_object_from_node (Xml.Node *node)
                                                        throws GLib.Error;
}
