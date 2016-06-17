[DBus (name = "org.coanda.Dactl.Extension")]
public class Dactl.UI.Extension.DOM : GLib.Object {

    private int count;

    private WebKit.WebPage page;

    public signal void div_clicked (string number);

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
    public void div_clicked_cb (WebKit.DOM.EventTarget target, WebKit.DOM.Event event) {
        div_clicked (((WebKit.DOM.Element) target).get_attribute ("id"));
    }
}

[DBus (name = "org.coanda.Dactl.Extension")]
public errordomain DOMError {
    ERROR
}

[CCode (cname = "G_MODULE_EXPORT webkit_web_extension_initialize", instance_pos = -1)]
public static void webkit_web_extension_initialize (WebKit.WebExtension extension) {
    Dactl.UI.Extension.DOM dom = new Dactl.UI.Extension.DOM ();
    extension.page_created.connect (dom.page_created_cb);
    Bus.own_name (BusType.SESSION, "org.coanda.Dactl.Extension", BusNameOwnerFlags.NONE,
                  dom.bus_acquired_cb, null,
                  () => { warning ("Could not acquired bus name"); });
}
