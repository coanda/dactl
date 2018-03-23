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
    public virtual bool equal (Dactl.Object a, Dactl.Object b) {
        return a.id == b.id;
    }

    /**
     * Compares the object to another that is provided.
     *
     * @param a the object to compare this one against.
     *
     * @return  ``0`` if they contain the same id, ``1`` otherwise
     */
    public virtual int compare (Dactl.Object a) {
        return this.id.ascii_casecmp (a.id);
    }

    /**
     * Print all properties of the object.
     */
    public virtual string to_string () {
        string result = "";
        Type type = get_type ();
        ObjectClass ocl = (ObjectClass)type.class_ref ();
        result += "[%s(@id=%s)]\n".printf (type.name (), id);
        result += " Properties:\n";
        result += " %-24s%-35s%-24s%-20s\n".printf ("Name:", "Value:", "Value Type:", "Owner Type:");

        foreach (ParamSpec spec in ocl.list_properties ()) {
            string value;
            Type ptype = spec.value_type;
            string name = spec.get_name ();
            Value number = Value (ptype);
            get_property (name, ref number);
            result += " %-24s%-35s%-24s%-20s\n".printf (
                spec.get_name (),
                number.strdup_contents (),
                spec.value_type.name (),
                spec.owner_type.name ()
            );
        }

        return result;
    }

    /**
     * Get the nickname of the object.
     * Used to clean up the output in the application configurations.
     */
    //public virtual
}
