/**
 * Class use to build objects from configuration data.
 */
public class Dactl.UI.Factory : GLib.Object, Dactl.Factory {

    /* Factory singleton */
    private static Dactl.UI.Factory factory;

    public static Dactl.UI.Factory get_default () {
        if (factory == null) {
            factory = new Dactl.UI.Factory ();
        }

        return factory;
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
            case "DactlAIControl":              break;
            case "DactlAOControl":              break;
            case "DactlAxis":                   break;
            case "DactlBox":                    break;
            case "DactlChart":                  break;
            case "DactlExec":                   break;
            case "DactlLogControl":             break;
            case "DactlPage":                   break;
            case "DactlPid":                    break;
            case "DactlPnid":                   break;
            case "DactlPnidElement":            break;
            case "DactlPolarChart":             break;
            case "DactlRTChart":                break;
            case "DactlStripChart":             break;
            case "DactlStripChartTrace":        break;
            case "DactlTrace":                  break;
            case "DactlChannelTreeView":        break;
            case "DactlChannelTreeCategory":    break;
            case "DactlChannelTreeEntry":       break;
            case "DactlVideoProcessor":         break;
            case "DactlRichContent":            break;
            case "DactlUIWindow":               break;
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
                    case "ai":                  return make_ai (node);
                    case "ao":                  return make_ao (node);
                    case "axis":                return make_axis (node);
                    case "box":                 return make_box (node);
                    case "chart":               return make_chart (node);
                    case "exec":                return make_exec (node);
                    case "log":                 return make_log (node);
                    case "page":                return make_page (node);
                    case "pid":                 return make_pid (node);
                    case "pnid":                return make_pnid (node);
                    case "pnid-element":        return make_pnid_element (node);
                    case "polar-chart":         return make_polar_chart (node);
                    case "rt-chart":            return make_rt_chart (node);
                    case "stripchart":          return make_stripchart (node);
                    case "stripchart-trace":    return make_stripchart_trace (node);
                    case "trace":               return make_trace (node);
                    case "tree":                return make_tree (node);
                    case "tree-category":       return make_tree_category (node);
                    case "tree-entry":          return make_tree_entry (node);
                    case "video":               return make_video_processor (node);
                    case "rich-content":        return make_rich_content (node);
                    case "window":              return make_window (node);
                    default:
                        throw new Dactl.FactoryError.TYPE_NOT_FOUND (
                            _("The type requested is not a known Dactl type"));
                }
            }
        }

        return object;
    }

    /**
     * XXX not really sure about whether or not this should let the objects
     *     construct themselves or if the actual property assignment should
     *     happen here
     */

    private Dactl.Object make_ai (Xml.Node *node) {
        return new Dactl.AIControl.from_xml_node (node);
    }

    private Dactl.Object make_ao (Xml.Node *node) {
        return new Dactl.AOControl.from_xml_node (node);
    }

    private Dactl.Object make_axis (Xml.Node *node) {
        return new Dactl.Axis.from_xml_node (node);
    }

    private Dactl.Object make_box (Xml.Node *node) {
        return new Dactl.Box.from_xml_node (node);
    }

    private Dactl.Object make_chart (Xml.Node *node) {
        return new Dactl.Chart.from_xml_node (node);
    }

    private Dactl.Object make_exec (Xml.Node *node) {
        return new Dactl.ExecControl.from_xml_node (node);
    }

    private Dactl.Object make_log (Xml.Node *node) {
        return new Dactl.LogControl.from_xml_node (node);
    }

    private Dactl.Object make_page (Xml.Node *node) {
        return new Dactl.Page.from_xml_node (node);
    }

    private Dactl.Object make_pid (Xml.Node *node) {
        return new Dactl.PidControl.from_xml_node (node);
    }

    private Dactl.Object make_pnid (Xml.Node *node) {
        return new Dactl.Pnid.from_xml_node (node);
    }

    private Dactl.Object make_pnid_element (Xml.Node *node) {
        return new Dactl.PnidElement.from_xml_node (node);
    }

    private Dactl.Object make_polar_chart (Xml.Node *node) {
        return new Dactl.PolarChart.from_xml_node (node);
    }

    private Dactl.Object make_rich_content (Xml.Node *node) {
        return new Dactl.UI.RichContent.from_xml_node (node);
    }

    private Dactl.Object make_rt_chart (Xml.Node *node) {
        return new Dactl.RTChart.from_xml_node (node);
    }

    private Dactl.Object make_stripchart (Xml.Node *node) {
        return new Dactl.StripChart.from_xml_node (node);
    }

    private Dactl.Object make_stripchart_trace (Xml.Node *node) {
        return new Dactl.StripChartTrace.from_xml_node (node);
    }

    private Dactl.Object make_trace (Xml.Node *node) {
        return new Dactl.Trace.from_xml_node (node);
    }

    private Dactl.Object make_tree (Xml.Node *node) {
        return new Dactl.ChannelTreeView.from_xml_node (node);
    }

    private Dactl.Object make_tree_category (Xml.Node *node) {
        return new Dactl.ChannelTreeCategory.from_xml_node (node);
    }

    private Dactl.Object make_tree_entry (Xml.Node *node) {
        return new Dactl.ChannelTreeEntry.from_xml_node (node);
    }

    private Dactl.Object make_video_processor (Xml.Node *node) {
        return new Dactl.VideoProcessor.from_xml_node (node);
    }

    private Dactl.Object make_window (Xml.Node *node) {
        return new Dactl.UI.Window.from_xml_node (node);
    }
}
