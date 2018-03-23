public abstract class Dactl.UI.WebKitWidget : WebKit.WebView, Dactl.Widget, Dactl.Container, Dactl.Buildable, Dactl.Object {

    private Xml.Node* _node;

    /**
     * {@inheritDoc}
     */
    public virtual string id { get; set; }

    public bool fill { get; set; default = true; }

    /**
     * {@inheritDoc}
     */
    protected abstract string xml { get; }

    /**
     * {@inheritDoc}
     */
    protected abstract string xsd { get; }

    /**
     * {@inheritDoc}
     */
    protected virtual Xml.Node* node {
        get {
            return _node;
        }
        set {
            _node = value;
        }
    }

    /**
     * {@inheritDoc}
     */
    public abstract Gee.Map<string, Dactl.Object> objects { get; set; }

    /**
     * {@inheritDoc}
     */
    public abstract void build_from_xml_node (Xml.Node *node);

    /**
     * {@inheritDoc}
     */
    public abstract void update_objects (Gee.Map<string, Dactl.Object> val);
}
