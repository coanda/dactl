#!/usr/bin/gjs

const Cld = imports.gi.Cld;
const DactlUI = imports.gi.DactlUI;
const Gtk = imports.gi.Gtk;

function onDeleteEvent(widget, event) {
    log("delete event occurred");
    return false;
}

function onDestroy(widget) {
    log("destroy signal occurred");
    Gtk.main_quit();
}

function main() {
    let config = Cld.XmlConfig.with_file_name("examples/cld.xml");
    let context = Cld.Context.from_config(config);
    let chan = context.get_object("ai0");

    Gtk.init(null);

    let win = new Gtk.Window({ type: Gtk.WindowType.TOPLEVEL });
    win.connect("delete-event", onDeleteEvent);
    win.connect("destroy", onDestroy);
    win.set_border_width(10);

    let aictl = new DactlUI.AIControl("/ai0");
    aictl.connect("request_object",
        function() {
            aictl.offer_cld_object(chan);
        });

    win.add(aictl);
    win.show();

    Gtk.main();
}

main();
