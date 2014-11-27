/**
 * Plugin UI factory to build objects from configuration data.
 */
public class Dactl.Velmex.Factory : GLib.Object, Dactl.Factory {

    /**
     * {@inheritDoc}
     */
    public Gee.TreeMap<string, Dactl.Object> make_object_map (Xml.Node *node) {
        var objects = new Gee.TreeMap<string, Dactl.Object> ();
        for (Xml.Node *iter = node; iter != null; iter = iter->next) {
            try {
                var object = make_object_from_node (iter);
                if (object != null) {
                    objects.set (object.id, object);
                    message ("Loading object of type `%s' with id `%s'",
                            iter->get_prop ("type"), object.id);
                }
            } catch (GLib.Error e) {
                critical (e.message);
            }
        }
        build_complete ();

        return objects;
    }

    /**
     * {@inheritDoc}
     */
    public Dactl.Object make_object (Type type)
                                     throws GLib.Error {
        Dactl.Object object = null;

        switch (type.name ()) {
            case "DactlVelmexControl":
                break;
            default:
                throw new Dactl.FactoryError.TYPE_NOT_FOUND (
                    _("The type requested is not a known Dactl type"));
        }

        return object;
    }

    /**
     * {@inheritDoc}
     */
    public Dactl.Object make_object_from_node (Xml.Node *node)
                                               throws GLib.Error {
        Dactl.Object object = null;

        if (node->type == Xml.ElementType.ELEMENT_NODE &&
            node->type != Xml.ElementType.COMMENT_NODE) {
            if (node->name == "object") {
                var type = node->get_prop ("type");
                message ("Attempting to construct a plugin control of type `%s'", type);
                switch (type) {
                    case "plugin-control":
                        return make_velmex_plugin_control (node);
                    default:
                        throw new Dactl.FactoryError.TYPE_NOT_FOUND (
                            _("The type requested is not a known Dactl type"));
                }
            }
        }

        return object;
    }

    private Dactl.Object make_velmex_plugin_control (Xml.Node *node) {
        return new Dactl.Velmex.Control.from_xml_node (node);
    }
}
