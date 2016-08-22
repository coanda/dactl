[Flags]
public enum Dactl.GridFlag {
    DRAW_BORDER     = 0x01;

    public Dactl.GridFlag set (Dactl.GridFlag flag) {
        return (this | flag);
    }

    public Dactl.GridFlag unset (Dactl.GridFlag flag) {
        return (this & ~flag);
    }

    public bool is_set (Dactl.GridFlag flag) {
        return (flag in this);
    }
}

//public class Dactl.GridCell : GLib.Object, Dactl.Object, Dactl.Buildable {

    //private Xml.Node* _node;

    //private string _xml = """
        //<object id=\"ai-ctl0\" type=\"ai\" ref=\"cld://ai0\"/>
    //""";

    //private string _xsd = """
        //<xs:element name="object">
          //<xs:attribute name="id" type="xs:string" use="required"/>
          //<xs:attribute name="type" type="xs:string" use="required"/>
          //<xs:attribute name="ref" type="xs:string" use="required"/>
        //</xs:element>
    //""";

    /**
     * {@inheritDoc}
     */
    //protected virtual Xml.Node* node {
        //get {
            //return _node;
        //}
        //set {
            //_node = value;
        //}
    //}

    /**
     * {@inheritDoc}
     */
    //public string id { get; set; default = "cell0"; }

    /**
     * {@inheritDoc}
     */
    //protected virtual string xml {
        //get { return _xml; }
    //}

    /**
     * {@inheritDoc}
     */
    //protected virtual string xsd {
        //get { return _xsd; }
    //}

    //public int row { get; set; default = 0; }

    //public int col { get; set; default = 0; }

    //public int row_span { get; set; default = 1; }

    //public int col_span { get; set; default = 1; }

    /**
     * Construction using data provided.
     */
    //public GridCell.with_data (string id, int row, int col, int row_span, int col_span) {
        //this.id = id;
        //this.row = row;
        //this.col = col;
        //this.row_span = row_span;
        //this.col_span = col_span;
    //}

    /**
     * Construction using an XML node.
     */
    //public GridCell.from_xml_node (Xml.Node *node) {
        //build_from_xml_node (node);
    //}

    /**
     * {@inheritDoc}
     */
    //internal void build_from_xml_node (Xml.Node *node) {
        //string? value;

        //if (node->type == Xml.ElementType.ELEMENT_NODE &&
            //node->type != Xml.ElementType.COMMENT_NODE) {
            //id = node->get_prop ("id");

            //[> Iterate through node children <]
            //for (Xml.Node *iter = node->children; iter != null; iter = iter->next) {
                //if (iter->name == "property") {
                    //switch (iter->get_prop ("name")) {
                        //case "row":
                            //value = iter->get_content ();
                            //row = int.parse (value);
                            //break;
                        //case "col":
                            //value = iter->get_content ();
                            //col = int.parse (value);
                            //break;
                        //case "row-span":
                            //value = iter->get_content ();
                            //row_span = int.parse (value);
                            //break;
                        //case "col-span":
                            //value = iter->get_content ();
                            //col_span = int.parse (value);
                            //break;
                        //default:
                            //break;
                    //}
                //}
            //}
        //}
    //}
//}

/**
 * Grid data model class that is configurable using the application builder.
 */
//public class Dactl.GridModel : GLib.Object, Dactl.Object, Dactl.Buildable, Dactl.Container {

    //private Xml.Node* _node;

    //private string _xml = """
        //<object id=\"ai-ctl0\" type=\"ai\" ref=\"cld://ai0\"/>
    //""";

    //private string _xsd = """
        //<xs:element name="object">
          //<xs:attribute name="id" type="xs:string" use="required"/>
          //<xs:attribute name="type" type="xs:string" use="required"/>
          //<xs:attribute name="ref" type="xs:string" use="required"/>
        //</xs:element>
    //""";

    /**
     * {@inheritDoc}
     */
    //protected virtual Xml.Node* node {
        //get {
            //return _node;
        //}
        //set {
            //_node = value;
        //}
    //}

    /**
     * {@inheritDoc}
     */
    //public string id { get; set; default = "grid0"; }

    /**
     * {@inheritDoc}
     */
    //protected virtual string xml {
        //get { return _xml; }
    //}

    /**
     * {@inheritDoc}
     */
    //protected virtual string xsd {
        //get { return _xsd; }
    //}

    /**
     * {@inheritDoc}
     */
    //private Gee.Map<string, Dactl.Object> _objects;
    //public Gee.Map<string, Dactl.Object> objects {
        //get { return _objects; }
        //set { update_objects (value); }
    //}

    //public string page_ref { get; set; }

    /**
     * Common object construction.
     */
    //construct {
        //objects = new Gee.TreeMap<string, Dactl.Object> ();
    //}

    /**
     * Default construction.
     */
    //public GridModel () { }

    /**
     * Construction using an XML node.
     */
    //public GridModel.from_xml_node (Xml.Node *node) {
        //build_from_xml_node (node);
    //}

    /**
     * {@inheritDoc}
     */
    //internal void build_from_xml_node (Xml.Node *node) {
        //if (node->type == Xml.ElementType.ELEMENT_NODE &&
            //node->type != Xml.ElementType.COMMENT_NODE) {
            //id = node->get_prop ("id");
            //page_ref = node->get_prop ("pgref");

            //[> Iterate through node children <]
            //for (Xml.Node *iter = node->children; iter != null; iter = iter->next) {
                //if (iter->name == "property") {
                    //switch (iter->get_prop ("name")) {
                        /*
                         *case "":
                         *     = iter->get_content ();
                         *    break;
                         */
                        //default:
                            //break;
                    //}
                //} else if (iter->name == "object") {
                    //var type = iter->get_prop ("type");
                    //if (type == "grid-cell") {
                        //var cell = new GridCell.from_xml_node (iter);
                        //add_child (cell);
                    //}
                //}
            //}
        //}
    //}

    /**
     * {@inheritDoc}
     */
    //public void update_objects (Gee.Map<string, Dactl.Object> val) {
        //_objects = val;
    //}
//}

/**
 * Chart class to perform the drawing.
 *
 * XXX this could very easily be changed to a Clutter.GridLayout if the
 *     application was switch to use Clutter for the entire layout in the future
 */
//public class Dactl.GridView : Clutter.Actor {

    /**
     * Backend data model used to configure the class.
     */
    //public GridModel model { get; private set; }

    //construct {
        //layout_manager = new Clutter.GridLayout ();
        //(layout_manager as Clutter.GridLayout).column_spacing = 5;
        //(layout_manager as Clutter.GridLayout).row_spacing = 5;
        //x_align = Clutter.ActorAlign.FILL;
        //y_align = Clutter.ActorAlign.FILL;
        //x_expand = true;
        //y_expand = true;
        //height = 320;
        //width = 640;
        //margin_bottom = 5;
        //margin_top = 5;
        //margin_left = 5;
        //margin_right = 5;
    //}

    /**
     * Default construction.
     */
    //public GridView () {
        //model = new GridModel ();
        //connect_signals ();
    //}

    /**
     * Construction using a provided data model.
     */
    //public GridView.with_model (GridModel model) {
        //this.model = model;
        //connect_signals ();
    //}

    /**
     * Connect any signals including the notifications from the model.
     */
    //private void connect_signals () {

        /*
         *model.notify["xxx"].connect (() => {
         *    [> Change the xxx <]
         *});
         */
    //}

    //public void add_child_using_cell (Clutter.Actor child, Dactl.GridCell cell) {
        //(layout_manager as Clutter.GridLayout).attach (child,
                                                       //cell.col,
                                                       //cell.row,
                                                       //cell.col_span,
                                                       //cell.row_span);
    //}
//}

public class Dactl.Grid : GLib.Object, Dactl.Object {

    /**
     * {@inheritDoc}
     */
    public string id { get; set; }

    //public Dactl.GridModel model { get; private set; }
    //public Dactl.GridView view { get; private set; }

    public Dactl.GridFlag flags { get; set; }

    construct {
        flags = Dactl.GridFlag.DRAW_BORDER;
    }

    /**
     * Default construction.
     */
    //public Grid () {
        //model = new Dactl.GridModel ();
        //view = new Dactl.GridView.with_model (model);
    //}

    /**
     * Construction using a data model.
     */
    //public Grid.with_model (Dactl.GridModel model) {
        //this.model = model;
        //view = new Dactl.GridView.with_model (model);
    //}

    /**
     * Add the views for any children that are available in the model.
     */
    //public void add_children () {
        //var cells = model.get_children (typeof (Dactl.ChannelTreeView));
        //foreach (var cell in cells.values) {
            //GLib.message ("Adding cell `%s' to grid `%s'", cell.id, id);
            //var cell_actor = new Clutter.Actor ();
            //cell_actor.x_align = Clutter.ActorAlign.FILL;
            //cell_actor.y_align = Clutter.ActorAlign.FILL;
            //cell_actor.x_expand = true;
            //cell_actor.y_expand = true;
            //view.add_child_using_cell (cell_actor, cell as Dactl.GridCell);
        //}
    //}
}
