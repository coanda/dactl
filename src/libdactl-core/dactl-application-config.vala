/**
 * Configuration data that loads XML configuration and is used to retrieve user
 * defined settings.
 */
public class Dactl.ApplicationConfig : GLib.Object {

    public string file_name { get; set; default = "dactl.xml"; }

    public bool loaded { get; set; default = false; }

    private Xml.Doc *doc;
    private Xml.XPath.Context *ctx;
    private Xml.XPath.Object *obj;

    /**
     * Used when a property is changed.
     */
    public signal void property_changed (string property);

    /**
     * Default construction, don't really see the point of multiple constructors
     * at this stage.
     */
    public ApplicationConfig (string file_name) {
        this.file_name = file_name;
        try {
            load_document ();
        } catch (Dactl.ConfigError e) {
            message ("Configuration error: %s", e.message);
        }
    }

    private void load_document () throws Dactl.ConfigError {
        /* Load XML document */
        doc = Xml.Parser.parse_file (file_name);
        if (doc == null) {
            loaded = false;
            throw new Dactl.ConfigError.FILE_NOT_FOUND (
                "File %s not found or permissions incorrect.", file_name
            );
        }

        /* Create context for XPath queries */
        ctx = new Xml.XPath.Context (doc);
        ctx->register_ns ("cld", "urn:libcld");
        ctx->register_ns ("ui", "urn:libdactl-ui");

        /* Assume success if we made it here */
        loaded = true;
    }

    public void save () {
        debug ("Saving file `%s'", file_name);
        doc->save_file (file_name);
    }

    public Xml.Node * get_xml_node (string xpath) throws Dactl.ConfigError {
        obj = ctx->eval_expression (xpath);
        if (obj == null) {
            throw new Dactl.ConfigError.INVALID_XPATH_EXPR (
                "The XPath expression %s is invalid.", xpath
            );
        }

        /* XXX add error checking for a set that's > 1 in length */
        Xml.XPath.NodeSet *nodes = obj->nodesetval;

        return nodes->item (0);
    }

    public Xml.XPath.NodeSet * get_xml_nodeset (string xpath) throws Dactl.ConfigError {
        obj = ctx->eval_expression (xpath);
        if (obj == null) {
            throw new Dactl.ConfigError.INVALID_XPATH_EXPR (
                "The XPath expression %s is invalid.", xpath
            );
        }

        /* XXX add error checking for a set that's > 1 in length */
        Xml.XPath.NodeSet *nodes = obj->nodesetval;

        return nodes;
    }

    private int depth = 0;
    private int indent = 0;

    /**
     * XXX this doesn't work
     *
     * Print the tree structure of a node within the configuration.
     *
     * {{{
     *  print_xml_node ("/dactl");
     *
     *  [dactl]
     *   |
     *   +--[objects]
     *       |
     *       +--[object]
     *       |
     *       +--[object]
     * }}}
     *
     * @param xpath XPath query to use for retrieving base node
     */
    public void print_xml_node (string xpath) throws Dactl.ConfigError {
        obj = ctx->eval_expression (xpath);
        if (obj == null) {
            throw new Dactl.ConfigError.INVALID_XPATH_EXPR (
                "The XPath expression %s is invalid.", xpath
            );
        }

        Xml.XPath.NodeSet *nodes = obj->nodesetval;
        Xml.Node *node = nodes->item (0);

        for (Xml.Node *iter = node; iter != null; iter = iter->next) {
            if (iter->type == Xml.ElementType.ELEMENT_NODE &&
                iter->type != Xml.ElementType.COMMENT_NODE) {
                if (iter->name == "object") {
                    var type = iter->get_prop ("type");
                    debug (@"[$type]");
                }
            }
        }
    }

    private void edit_node (Xml.Node *node, string value) {
        node->set_content (value);
        if (node->type != Xml.ElementType.NAMESPACE_DECL)
            node = null;
    }

    /* XXX it might be more useful if these all retrieved the values using an
     *     xpath query but that would limit the ability to port to JSON */

    public bool get_boolean_property (string property) {
        string xpath = "//dactl/property[@name=\"%s\"]".printf (property);
        Xml.Node *node;

        try {
            node = get_xml_node (xpath);
        } catch (Dactl.ConfigError e) {
            error ("Configuration error: %s", e.message);
        }

        return bool.parse (node->get_content ());
    }

    public string get_string_property (string property) {
        string xpath = "//dactl/property[@name=\"%s\"]".printf (property);
        Xml.Node *node;

        try {
            node = get_xml_node (xpath);
        } catch (Dactl.ConfigError e) {
            error ("Configuration error: %s", e.message);
        }

        return node->get_content ();
    }

    public int get_int_property (string property) {
        string xpath = "//dactl/property[@name=\"%s\"]".printf (property);
        Xml.Node *node;

        try {
            node = get_xml_node (xpath);
        } catch (Dactl.ConfigError e) {
            error ("Configuration error: %s", e.message);
        }

        return int.parse (node->get_content ());
    }

    public double get_double_property (string property) {
        string xpath = "//dactl/property[@name=\"%s\"]".printf (property);
        Xml.Node *node;

        try {
            node = get_xml_node (xpath);
        } catch (Dactl.ConfigError e) {
            error ("Configuration error: %s", e.message);
        }

        return double.parse (node->get_content ());
    }

    public double get_float_property (string property) {
        string xpath = "//dactl/property[@name=\"%s\"]".printf (property);
        Xml.Node *node;

        try {
            node = get_xml_node (xpath);
        } catch (Dactl.ConfigError e) {
            error ("Configuration error: %s", e.message);
        }

        return (float)double.parse (node->get_content ());
    }

    public void set_boolean_property (string property, bool value) {
        string xpath = "//dactl/property[@name=\"%s\"]".printf (property);

        try {
            edit_node (get_xml_node (xpath), value.to_string ());
            property_changed (property);
        } catch (Dactl.ConfigError e) {
            error ("Configuration error: %s", e.message);
        }
    }

    public void set_string_property (string property, string value) {
        string xpath = "//dactl/property[@name=\"%s\"]".printf (property);

        try {
            edit_node (get_xml_node (xpath), value.to_string ());
            property_changed (property);
        } catch (Dactl.ConfigError e) {
            error ("Configuration error: %s", e.message);
        }
    }

    public void set_int_property (string property, int value) {
        string xpath = "//dactl/property[@name=\"%s\"]".printf (property);

        try {
            edit_node (get_xml_node (xpath), value.to_string ());
            property_changed (property);
        } catch (Dactl.ConfigError e) {
            error ("Configuration error: %s", e.message);
        }
    }

    public void set_double_property (string property, double value) {
        string xpath = "//dactl/property[@name=\"%s\"]".printf (property);

        try {
            edit_node (get_xml_node (xpath), value.to_string ());
            property_changed (property);
        } catch (Dactl.ConfigError e) {
            error ("Configuration error: %s", e.message);
        }
    }

    public void set_float_property (string property, float value) {
        string xpath = "//dactl/property[@name=\"%s\"]".printf (property);

        try {
            edit_node (get_xml_node (xpath), value.to_string ());
            property_changed (property);
        } catch (Dactl.ConfigError e) {
            error ("Configuration error: %s", e.message);
        }
    }

    /* XXX not sure how this should be done yet, possibly read the current
     *     matching node and iterate through attributes and elements */
    public void set_xml_node (string xpath, Xml.Node *node) {
        Xml.Node *_node;
        try {
            _node = get_xml_node (xpath);
            _node->replace (node);
        } catch (Dactl.ConfigError e) {
            error ("Configuration error: %s", e.message);
        }
        _node->replace (node);
    }
}
