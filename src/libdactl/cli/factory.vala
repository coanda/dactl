public class Dactl.CLI.Factory : GLib.Object, Dactl.Factory {

    /* Singleton */
    private static Once<Dactl.CLI.Factory> _instance;

    /**
     * Instantiate singleton for the CLI object factory.
     *
     * @return Instance of the factory.
     */
    public static unowned Dactl.CLI.Factory get_default () {
        return _instance.once(() => { return new Dactl.CLI.Factory (); });
    }

    /**
     * {@inheritDoc}
     */
    public Gee.TreeMap<string, Dactl.Object> make_object_map (Xml.Node *node) {
        var objects = new Gee.TreeMap<string, Dactl.Object> ();
        for (Xml.Node *iter = node; iter != null; iter = iter->next) {
            try {
                Dactl.Object object = make_object_from_node (iter);

                /* XXX is this check necessary with the exception? */
                if (object != null) {
                    objects.set (object.id, object);
                    debug ("Loading object of type `%s' with id `%s'",
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
            case "DactlCLISomething":   break;
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
                switch (type) {
                    case "something":   return make_something (node);
                    default:
                        throw new Dactl.FactoryError.TYPE_NOT_FOUND (
                            _("The type requested is not a known Dactl type"));
                }
            }
        }

        return object;
    }

    private Dactl.Object? make_something (Xml.Node *node) {
        //return new Dactl.CLI.Something.from_xml_node (node);
        return null;
    }
}
