[DBus (name = "org.coanda.Dactl.Extension")]
public class Dactl.UI.Extension.DOM : GLib.Object {

    private int count;

    private WebKit.WebPage page;

    private static double value = 0.0;

    private static bool value_dir = false;

    private static const JSCore.StaticFunction[] class_functions = {{
        "get_analog", (JSCore.ObjectCallAsFunctionCallback) meas_get_analog_cb, JSCore.PropertyAttribute.ReadOnly
    },{
        "get_digital", (JSCore.ObjectCallAsFunctionCallback) meas_get_digital_cb, JSCore.PropertyAttribute.ReadOnly
    },{
        null, null, 0
    }};

    private static const JSCore.ClassDefinition class_definition = {
        0,                          // version
        JSCore.ClassAttribute.None, // attributes
        "Measurement",              // className
        null,                       // parentClass
        null,                       // staticValues
        class_functions,            // staticFunctions
        null,                       // initialize
        null,                       // finalize
        null,                       // hasProperty
        null,                       // getProperty
        null,                       // setProperty
        null,                       // deleteProperty
        null,                       // getPropertyNames
        null,                       // callAsFunction
        (JSCore.ObjectCallAsConstructorCallback) class_constructor_cb,       // callAsConstructor
        null,                       // hasInstance
        null                        // convertToType
    };

    public signal void div_clicked (string number);

    [DBus (visible = false)]
    public void bus_acquired_cb (DBusConnection connection) {
        try {
            connection.register_object ("/org/coanda/dactl/extension", this);
        } catch (IOError error) {
            warning ("Could not register service: %s", error.message);
        }
    }

    [DBus (visible = false)]
    public void page_created_cb (WebKit.WebExtension extension,
                                 WebKit.WebPage page) {

        this.page = page;

        WebKit.DOM.Document document = page.get_dom_document ();

        debug ("Page %d created for %s with title %s",
               (int) page.get_id (),
               page.uri,
               document.title);
    }

    [DBus (visible = false)]
    public void window_object_cleared_cb (WebKit.WebPage page,
                                          WebKit.Frame frame) {
        debug ("Window object cleared");
        debug ("URI: %s", frame.get_uri ());
        debug ("Main frame: %s", ((frame.is_main_frame () == true) ? "true" : "false"));

        var ctx = frame.get_javascript_global_context ();
        var global_obj = ((JSCore.GlobalContext) ctx).get_global_object ();

        var str = new JSCore.String.with_utf8_c_string ("Measurement");
        var class = new JSCore.Class (class_definition);
        var obj = new JSCore.Object ((JSCore.Context) ctx, class, (void *) ctx);

        global_obj.set_property ((JSCore.GlobalContext) ctx,
                                 str,
                                 obj,
                                 JSCore.PropertyAttribute.None,
                                 null);
    }

    /**
     * Simple DBus call to test adding a div tag using the WebKit DOM.
     *
     * @param color The color to set the added div element
     */
    public void add_div (string color) {
        int x = Random.int_range (0, 300),
            y = Random.int_range (0, 300);
        count += 1;
        WebKit.DOM.Document document = page.get_dom_document ();

        try {
            WebKit.DOM.Element el = document.create_element ("div");
            el.append_child (document.create_text_node (@"$count"));
            el.set_attribute ("style", @"background: $color; left: $x; top: $y;");
            el.set_attribute ("id", @"$count");
            ((WebKit.DOM.EventTarget) el).add_event_listener_with_closure (
                "click", div_clicked_cb, false);
            document.body.insert_before (el, null);
        } catch (Error error) {
            warning ("DOM Error: %s", error.message);
        }
    }

    [DBus (visible = false)]
    public void div_clicked_cb (WebKit.DOM.EventTarget target, WebKit.DOM.Event event) {
        div_clicked (((WebKit.DOM.Element) target).get_attribute ("id"));
    }

    [DBus (visible = false)]
    private JSCore.Object class_constructor_cb (JSCore.Context ctx,
                                                JSCore.Object constructor,
                                                JSCore.Value[] arguments,
                                                out JSCore.Value exception) {
        debug ("Inititialize JS measurement class");

        var c = new JSCore.Class (class_definition);
        var o = new JSCore.Object (ctx, c, null);

        // Do something with the object

        return o;
    }

    [DBus (visible = false)]
    public static JSCore.Value meas_get_analog_cb (JSCore.Context ctx,
                                                   JSCore.Object function,
                                                   JSCore.Object thisObject,
                                                   JSCore.ConstValue[] arguments,
                                                   out JSCore.Value exception) {
        if (value_dir == false) {
            if (value >= 1.0) {
                value_dir = true;
                value -= 0.1;
            } else {
                value += 0.1;
            }
        } else if (value_dir == true) {
            if (value <= 0.0) {
                value_dir = false;
                value += 0.1;
            } else {
                value -= 0.1;
            }
        }

        return new JSCore.Value.number (ctx, value);
    }

    [DBus (visible = false)]
    public static JSCore.Value meas_get_digital_cb (JSCore.Context ctx,
                                                    JSCore.Object function,
                                                    JSCore.Object thisObject,
                                                    JSCore.ConstValue[] arguments,
                                                    out JSCore.Value exception) {
        return new JSCore.Value.boolean (ctx, false);
    }
}

[DBus (name = "org.coanda.Dactl.Extension")]
public errordomain DOMError {
    ERROR
}

[CCode (cname = "G_MODULE_EXPORT webkit_web_extension_initialize", instance_pos = -1)]
public static void webkit_web_extension_initialize (WebKit.WebExtension extension) {
    Dactl.UI.Extension.DOM dom = new Dactl.UI.Extension.DOM ();
    WebKit.ScriptWorld world = WebKit.ScriptWorld.get_default ();

    extension.page_created.connect (dom.page_created_cb);
    world.window_object_cleared.connect (dom.window_object_cleared_cb);

    Bus.own_name (BusType.SESSION, "org.coanda.Dactl.Extension", BusNameOwnerFlags.NONE,
                  dom.bus_acquired_cb, null,
                  () => { warning ("Could not acquired bus name"); });
}
