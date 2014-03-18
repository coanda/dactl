/**
 * A common interface for buildable objects.
 */
[GenericAccessors]
public interface Dactl.Buildable : Dactl.Object {

    /**
     * Build the object using an XML node
     *
     * @param node XML node to construction the object from
     */
    public abstract void build_from_xml_node (Xml.Node *node);
}

/**
 * Skeletal implementation of the {@link Buildable} interface.
 *
 * Contains common code shared by all interface implementations.
 */
public abstract class Dactl.AbstractBuildable : Dactl.AbstractObject, Dactl.Buildable {

    /**
     * {@inheritDoc}
     */
    public virtual void build_from_xml_node (Xml.Node *node) {

        if (node->type == Xml.ElementType.ELEMENT_NODE &&
            node->type != Xml.ElementType.COMMENT_NODE) {
            id = node->get_prop ("id");
        }
    }
}
