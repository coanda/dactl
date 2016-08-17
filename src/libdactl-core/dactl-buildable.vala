/**
 * A common interface for buildable objects.
 */
public interface Dactl.Buildable : GLib.Object {

    protected abstract string xml { get; }

    protected abstract string xsd { get; }

    protected abstract Xml.Node* node { get; set; }

    public static unowned string get_xml_default () {
        return "<object type=\"buildable\"/>";
    }

    public static unowned string get_xsd_default () {
        return """
                <xs:element name="object">
                  <xs:attribute name="id" type="xs:string" use="required"/>
                  <xs:attribute name="type" type="xs:string" use="required"/>
                </xs:element>
               """;
    }

    /**
     * Build the object using an XML node
     *
     * @param node XML node to construction the object from
     */
    internal abstract void build_from_xml_node (Xml.Node *node);
}
