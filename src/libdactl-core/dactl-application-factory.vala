/**
 * Class use to build objects from configuration data.
 */
public class Dactl.ApplicationFactory : GLib.Object, Dactl.Factory {

    /* Factory singleton */
    private static Dactl.ApplicationFactory app_factory;

    private static Gee.ArrayList<Dactl.Factory> factories;

    /**
     * Retrieves the singleton for the class creating it first if it's not
     * already available.
     */
    public static Dactl.ApplicationFactory get_default () {
        if (factories == null) {
            factories = new Gee.ArrayList<Dactl.Factory> ();
        }

        if (app_factory == null) {
            app_factory = new Dactl.ApplicationFactory ();
        }

        return app_factory;
    }

    public static void register_factory (Dactl.Factory factory) {
        if (factories == null) {
            factories = new Gee.ArrayList<Dactl.Factory> ();
        }
        factories.add (factory);
    }

    /**
     * {@inheritDoc}
     */
    public Gee.TreeMap<string, Dactl.Object> make_object_map (Xml.Node *node) {
        var objects = new Gee.TreeMap<string, Dactl.Object> ();

        /**
         * FIXME: Instead of passing in /dactl/objects/object this should
         *        receive just the root node and then parse out the namespaces
         *        for each factory.
         */
        foreach (var factory in Dactl.ApplicationFactory.factories) {
            var map = factory.make_object_map (node);
            objects.set_all (map);
        }

        /**
         * FIXME: Reiterating over the nodeset shouldn't be necessary.
         */
/*
 *        for (Xml.Node *iter = node; iter != null; iter = iter->next) {
 *            if (iter->type == Xml.ElementType.ELEMENT_NODE &&
 *                iter->type != Xml.ElementType.COMMENT_NODE) {
 *                try {
 *                    message ("Attempting to load object of type `%s'",
 *                             iter->get_prop ("type"));
 *                    var object = make_object_from_node (iter);
 *
 *                    [> no point adding an object type that isn't recognized <]
 *                    if (object != null) {
 *                        objects.set (object.id, object);
 *                        message ("Loading object of type `%s' with id `%s'",
 *                                iter->get_prop ("type"), object.id);
 *                    }
 *                } catch (GLib.Error e) {
 *                    critical (e.message);
 *                }
 *            }
 *        }
 */
        build_complete ();

        return objects;
    }

    /**
     * {@inheritDoc}
     */
    public Dactl.Object make_object (Type type)
                                     throws GLib.Error {
        Dactl.Object object = null;

        foreach (var factory in Dactl.ApplicationFactory.factories) {
            try {
                object = factory.make_object (type);
            } catch (GLib.Error e) {
                critical (e.message);
            }
        }

        /* The type was not found in any of the registered factories, check the
         * application last */
        if (object == null) {
            switch (type.name ()) {
                case "DactlFoo":
                    break;
                default:
                    throw new Dactl.FactoryError.TYPE_NOT_FOUND (
                        _("The type requested is not a known Dactl type."));
            }
        }

        return object;
    }

    /**
     * {@inheritDoc}
     */
    public Dactl.Object make_object_from_node (Xml.Node *node)
                                               throws GLib.Error {
        Dactl.Object object = null;

        foreach (var factory in Dactl.ApplicationFactory.factories) {
            try {
                object = factory.make_object_from_node (node);
            } catch (GLib.Error e) {
                critical (e.message);
            }
        }

        /* The type was not found in any of the registered factories, check the
         * application last */
        if (object == null) {
            if (node->name == "object") {
                var type = node->get_prop ("type");
                switch (type) {
                    case "foo":
                        break;
                    default:
                        throw new Dactl.FactoryError.TYPE_NOT_FOUND (
                            _("The type requested is not a known Dactl type."));
                }
            }
        }

        return object;
    }
}
