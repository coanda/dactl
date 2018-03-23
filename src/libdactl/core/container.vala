/**
 * A common interface inherited by any object that has its own list of sub
 * objects.
 */
public interface Dactl.Container : GLib.Object {

    /**
     * The map collection of the objects that belong to the container.
     */
    public abstract Gee.Map<string, Dactl.Object> objects { get; set; }

    /**
     * Used by implementing classes to request a child object for addition.
     */
    public abstract signal void request_object (string id);

    /**
     * Add a object to the array list of objects
     *
     * @param object object to add to the list
     */
    //public abstract void add_child (Dactl.Object object);
    public virtual void add_child (Dactl.Object object) {
        objects.set (object.id, object);
    }

    /**
     * Remove an object to the array list of objects
     *
     * @param object object to remove from the list
     */
    public virtual void remove_child (Dactl.Object object) {
        GLib.Value value;
        objects.unset (object.id, out value);
    }

    /**
     * Update the internal object list.
     *
     * @param val List of objects to replace the existing one
     */
    public abstract void update_objects (Gee.Map<string, Dactl.Object> val);

    /**
     * Search the object list for the object with the given ID
     *
     * @param id ID of the object to retrieve
     * @return The object if found, null otherwise
     */
    public virtual Dactl.Object? get_object (string id) {
        Dactl.Object? result = null;

        if (objects.has_key (id)) {
            result = objects.get (id);
        } else {
            foreach (var object in objects.values) {
                if (object is Dactl.Container) {
                    result = (object as Dactl.Container).get_object (id);
                    if (result != null) {
                        break;
                    }
                }
            }
        }

        return result;
    }

    /**
     * Retrieves a map of all objects of a certain type.
     *
     * {{{
     *  var pg_map = ctr.get_object_map (typeof (Dactl.UI.Page));
     * }}}
     *
     * @param type class type to retrieve
     * @return map of all objects of a certain class type
     */
    public virtual Gee.Map<string, Dactl.Object> get_object_map (Type type) {
        var map = new Gee.TreeMap<string, Dactl.Object> ();
        foreach (var object in objects.values) {
            if (object.get_type ().is_a (type)) {
                map.set (object.id, object);
            } else if (object is Dactl.Container) {
                var sub_map = (object as Dactl.Container).get_object_map (type);
                foreach (var sub_object in sub_map.values) {
                    map.set (sub_object.id, sub_object);
                }
            }
        }
        return map;
    }

    /**
     * Retrieve a map of the children of a certain type.
     *
     * {{{
     *  var children = ctr.get_children (typeof (Dactl.UI.Box));
     * }}}
     *
     * @param type class type to retrieve
     * @return map of all objects of a certain class type
     */
    public virtual Gee.Map<string, Dactl.Object> get_children (Type type) {
        Gee.Map<string, Dactl.Object> map = new Gee.TreeMap<string, Dactl.Object> ();
        foreach (var object in objects.values) {
            if (object.get_type ().is_a (type)) {
                map.set (object.id, object);
            }
        }
        return map;
    }

    /**
     * Sort the contents of the objects map collection.
     */
    public virtual void sort_objects () {
        Gee.List<Dactl.Object> map_values = new Gee.ArrayList<Dactl.Object> ();

        map_values.add_all (objects.values);
        map_values.sort ((GLib.CompareDataFunc<Dactl.Object>?) Dactl.Object.compare);
        objects.clear ();
        foreach (Dactl.Object object in map_values) {
            objects.set (object.id, object);
        }
    }

    /**
     * Recursively print the contents of the objects map.
     *
     * @param depth current level of the object tree
     */
    public virtual void print_objects (int depth = 0) {
        foreach (var object in objects.values) {
            string indent = string.nfill (depth * 2, ' ');
            debug ("%s[%s: %s]", indent, object.get_type ().name (), object.id);
            if (object is Dactl.Container) {
                (object as Dactl.Container).print_objects (depth + 1);
            }
        }
    }
}
