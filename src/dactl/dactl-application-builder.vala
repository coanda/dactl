/**
 * Class use to build objects from configuration data.
 */
public class Dactl.ApplicationBuilder : Dactl.AbstractContainer {

    /**
     * {@inheritDoc}
     */
    public override string id { get; set; }

    /**
     * {@inheritDoc}
     */
    private Gee.Map<string, Dactl.Object> _objects;
    public override Gee.Map<string, Dactl.Object> objects {
        get { return (_objects); }
        set { update_objects (value); }
    }

    public ApplicationBuilder.from_application_config (ApplicationConfig config) {
        _objects = new Gee.TreeMap<string, Dactl.Object> ();
        /* Get the nodeset to use from the configuration */
        try {
            Xml.Node *node = config.get_xml_node ("/dactl/objects/object");
            build_object_map (node);
        } catch (Dactl.ConfigError e) {
            GLib.error ("Configuration error: %s", e.message);
        }
        setup_references ();
    }

    public ApplicationBuilder.from_xml_node (Xml.Node *node) {
        _objects = new Gee.TreeMap<string, Dactl.Object> ();
        build_object_map (node);
        setup_references ();
    }

    /**
     * Constructs the object tree using the top level object types.
     */
    private void build_object_map (Xml.Node *node) {
        string type;

        for (Xml.Node *iter = node; iter != null; iter = iter->next) {
            if (iter->type == Xml.ElementType.ELEMENT_NODE &&
                iter->type != Xml.ElementType.COMMENT_NODE) {
                /* Load all available top level objects */
                if (iter->name == "object") {
                    Dactl.Object? object = null;
                    type = iter->get_prop ("type");
                    switch (type) {
                        case "chart":
                            var model = new Dactl.ChartModel.from_xml_node (iter);
                            object = new Dactl.Chart.with_model (model);
                            break;
                        case "dataset":
                            //var model = new Dactl.DataSetModel.from_xml_node (iter);
                            //object = new Dactl.DataSet.with_model (model);
                            break;
                        case "grid":
                            var model = new Dactl.GridModel.from_xml_node (iter);
                            object = new Dactl.Grid.with_model (model);
                            break;
                        case "history":
                            //var model = new Dactl.HistoryModel.from_xml_node (iter);
                            //object = new Dactl.History.with_model (model);
                            break;
                        case "page":
                            var model = new Dactl.PageModel.from_xml_node (iter);
                            object = new Dactl.Page.with_model (model);
                            break;
                        case "tree":
                            var model = new Dactl.ChannelTreeModel.from_xml_node (iter);
                            object = new Dactl.ChannelTree.with_model (model);
                            break;
                        default:
                            object = null;
                            break;
                    }

                    /* no point adding an object type that isn't recognized */
                    if (object != null) {
                        add (object);
                        message ("Loading object of type `%s' with id `%s'", type, object.id);
                    }
                }
            }
        }
    }

    /**
     * Sets up all of the weak references between the objects in the tree that
     * require it.
     */
    private void setup_references () {
        string ref_id;

        foreach (var object in objects.values) {
            /* Setup the references for all of the object types */
            if (object is Dactl.ChartModel) {
              /* ... */
            /*
             *} else if (object is Dactl.ChannelTreeViewModel) {
             *  [> ... <]
             */
            } else if (object is Dactl.GridModel) {
              /* ... */
            //} else if (object is Dactl.GridCellModel) {
              /* ... */
            }
        }
    }

    /**
     * {@inheritDoc}
     */
    public override void update_objects (Gee.Map<string, Dactl.Object> val) {
        _objects = val;
    }
}
