[GtkTemplate (ui = "/org/coanda/dactl/ui/settings-dialog.ui")]
public class Dactl.SettingsDialog : Gtk.Window {

    [GtkChild]
    private Dactl.SettingsTopbar settings_topbar;

    [GtkChild]
    private Dactl.GeneralSettings general;

    [GtkChild]
    private Dactl.AcquisitionSettings acquisition;

    [GtkChild]
    private Dactl.ControlSettings control;

    [GtkChild]
    private Dactl.LogSettings log;

    [GtkChild]
    private Dactl.PluginSettings plugin;

    [GtkChild]
    private Dactl.WidgetSettings widget;

    private Cld.Context cld_ctx;

    private Dactl.ApplicationModel model;

    private Dactl.CldSettingsData cld_data;

    private Dactl.NativeSettingsData dactl_data;

    construct {
        /* Build data objects for CLD and Dactl (ie. native) namespaces */
        model = Dactl.UI.Application.get_default ().model;
        cld_ctx = model.ctx;

        /* Configurable CLD data */
        cld_data = new Dactl.CldSettingsData.from_object (cld_ctx);
        Gee.ArrayList<Dactl.CldSettingsData> cld_list = new Gee.ArrayList<Dactl.CldSettingsData> ();
        cld_list.add (acquisition.data);
        cld_list.add (control.data);
        cld_list.add (log.data);

        /* Update the data object when a value changes */
        foreach (var page_data in cld_list) {
            page_data.new_data.connect ((source, uri, spec, value) => {
                cld_data.uri_selected = uri;
                cld_data.set_value (spec, value);
            });
        }

        /* Configurable Dactl data */
        dactl_data = new Dactl.NativeSettingsData.from_map (model.objects);
        Gee.ArrayList<Dactl.NativeSettingsData> dactl_list = new Gee.ArrayList<Dactl.NativeSettingsData> ();
        dactl_list.add (widget.data);

        /* Update the data object when a value changes */
        foreach (var page_data in dactl_list) {
            page_data.new_data.connect ((source, object, spec, value) => {
                dactl_data.object_selected = object;
                dactl_data.set_value (spec, value);
            });
        }

        settings_topbar.ok.connect (ok);
        settings_topbar.cancel.connect (cancel);
    }

    private void ok () {
        /* Copy settings values to objects in the Cld context */
        foreach (var uri in cld_data.keys) {
            var object = cld_ctx.get_object_from_uri (uri);
            if (object != null) {
                var svalues = cld_data.get (uri);
                foreach (var spec in svalues.keys) {
                    if (spec.owner_type.name ().contains ("Cld")) {
                        var name = spec.get_name ();
                        var value = svalues.get (spec).value;
                        bool writable = (spec.flags & GLib.ParamFlags.WRITABLE) ==
                                                        GLib.ParamFlags.WRITABLE;
                        bool is_cld_object = value.type ().is_a (Type.from_name ("CldObject"));
                        if (writable && !is_cld_object) {
                            debug (
                                "%s:%s  %s:%s",
                                uri,
                                object.get_type ().name (),
                                name,
                                value.type ().name ()
                                );
                            object.set_property (name, value);
                        } else if (!writable) {
                            debug (
                                "%s:%s  %s:%s is not writable",
                                uri,
                                object.get_type ().name (),
                                name,
                                value.type ().name ()
                                );
                        } else if (writable && is_cld_object) {
                            object.set_object_property (name, (Cld.Object)value);
                        }
                    }
                }
            }
        }

        /* Copy dactl settings to objects in the UI model */
        foreach (var object in dactl_data.keys) {
            debug ("%s", object.id);
            if (object != null) {
                var svalues = dactl_data.get (object);
                foreach (var spec in svalues.keys) {
                    if (spec.owner_type.name ().contains ("Dactl")) {
                        var name = spec.get_name ();
                        var value = svalues.get (spec).value;
                        bool writable = (spec.flags & GLib.ParamFlags.WRITABLE) ==
                                                        GLib.ParamFlags.WRITABLE;
                        bool is_dactl_object = value.type ().is_a (Type.from_name ("DactlObject"));
                        bool is_cld_object = value.type ().is_a (Type.from_name ("CldObject"));
                        if (writable && !is_dactl_object && !is_cld_object) {
                            debug (
                                "%s:%s  %s:%s",
                                object.id,
                                object.get_type ().name (),
                                name,
                                value.type ().name ()
                                );
                            /* FIXME use reparent if property is Gtk.Widget.parent */
                            /*
                            *if ((object.get_type ()).is_a (typeof (Gtk.Widget))) {
                            *    if (name == "parent") {
                            *        (object as Gtk.Widget).reparent (value as Gtk.Container);
                            *        message ("object is %s with %s that is %s", object.get_type ().name (), name, value.type_name ());
                            *    }
                            *} else {
                            */
                                object.set_property (name, value);
                                debug ("id: %s prop name: %s", object.id, name);
                            /*
                            *}
                            */
                        } else if (!writable) {
                            debug (
                                "%s:%s  %s:%s is not writable",
                                object.id,
                                object.get_type ().name (),
                                name,
                                value.type ().name ()
                                );
                        } else if (writable && is_dactl_object) {
                            /* XXX FIXME This doesn't do anything yet */
                            /*object.set_object_property (name, (Dactl.Object)value);*/
                        } else if (writable && is_cld_object) {
                            /* XXX FIXME This doesn't do anything yet */
                            /*object.set_object_property (name, (Cld.Object)value);*/
                        }
                    }
                }
            }
        }

        general.update_preferences ();

        destroy ();
    }

    private void cancel () {
        close ();
    }
}

