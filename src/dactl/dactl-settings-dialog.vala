[GtkTemplate (ui = "/org/coanda/dactl/ui/settings-dialog.ui")]
public class Dactl.SettingsDialog : Gtk.Window {
    private Dactl.Settings stack_settings;

    [GtkChild]
    private Dactl.SettingsTopbar settings_topbar;

    [GtkChild]
    private Gtk.ListBox listbox_settings;

    [GtkChild]
    private Gtk.Box box_main;

    [GtkChild]
    private Gtk.Box box_choices;

    [GtkChild]
    private Gtk.ListBoxRow listboxrow_general;

    [GtkChild]
    private Gtk.ListBoxRow listboxrow_acquisition;

    [GtkChild]
    private Gtk.ListBoxRow listboxrow_control;

    [GtkChild]
    private Gtk.ListBoxRow listboxrow_log;

    [GtkChild]
    private Gtk.ListBoxRow listboxrow_plugin;

    [GtkChild]
    private Gtk.ListBoxRow listboxrow_chart;

    private Cld.Context cld_ctx;

    private Dactl.ApplicationModel model;

    private Dactl.CldSettingsData cld_data;

    private Dactl.NativeSettingsData dactl_data;

    construct {
        /* Build data objects for Cld and Dactl (ie. native) namespaces */
        model = Dactl.UI.Application.get_default ().model;
        cld_ctx = model.ctx;

        /* Cld */
        cld_data = new Dactl.CldSettingsData.from_object (cld_ctx);
        stack_settings = new Dactl.Settings ();
        Gee.ArrayList<Dactl.CldSettingsData> cld_list = new Gee.ArrayList<Dactl.CldSettingsData> ();
        cld_list.add (stack_settings.acquisition.data);
        cld_list.add (stack_settings.control.data);
        cld_list.add (stack_settings.log.data);
        /* Update the data object when a value changes */
        foreach (var page_data in cld_list) {
            page_data.new_data.connect ((source, uri, spec, value) => {
                cld_data.uri_selected = uri;
                cld_data.set_value (spec, value);
            });
        }

        /* Dactl */

        dactl_data = new Dactl.NativeSettingsData.from_map (model.objects);

        Gee.ArrayList<Dactl.NativeSettingsData> dactl_list = new Gee.ArrayList<Dactl.NativeSettingsData> ();
        dactl_list.add (stack_settings.chart.data);
        /* Update the data object when a value changes */
        foreach (var page_data in dactl_list) {
            page_data.new_data.connect ((source, object, spec, value) => {
                dactl_data.object_selected = object;
                dactl_data.set_value (spec, value);
            });
        }

        /* XXX FIXME Add plugin settings */
        //list.add (stack_settings.plugin.data);

        box_stack_settings.pack_start (stack_settings, true, true, 0);
        //listbox_settings.set_header_func (_update_header);

        /* XXX FIXME There are no separators visible in the ListBox */
        int n = 0;
        foreach (var row in listbox_settings.get_children ()) {
            var sep = new Gtk.Separator (Gtk.Orientation.VERTICAL);
            //row.set_header (separator);
            sep.set_visible (true);
            var color = new Gdk.RGBA ();
            color.red = 255;
            color.green = 255;
            color.blue = 255;
            color.alpha = 1.0;
            sep.override_color (Gtk.StateFlags.NORMAL, color);
            listbox_settings.insert (sep, 2 * n + 1);
            n++;
        }

        settings_topbar.ok.connect (ok);
        settings_topbar.cancel.connect (cancel);
    }

    [GtkCallback]
    private void listbox_settings_row_activated_cb (Gtk.ListBoxRow row) {
        if (row == listboxrow_general) {
            stack_settings.page = Dactl.SettingsStackPage.GENERAL;
            settings_topbar.set_subtitle ("General");
        } else if (row == listboxrow_acquisition) {
            stack_settings.page = Dactl.SettingsStackPage.ACQUISITION;
            settings_topbar.set_subtitle ("Acquisition");
        } else if (row == listboxrow_control) {
            stack_settings.page = Dactl.SettingsStackPage.CONTROL;
            settings_topbar.set_subtitle ("Control");
        } else if (row == listboxrow_log) {
            stack_settings.page = Dactl.SettingsStackPage.LOG;
            settings_topbar.set_subtitle ("Log");
        }else if (row == listboxrow_plugin) {
            stack_settings.page = Dactl.SettingsStackPage.PLUGIN;
            settings_topbar.set_subtitle ("Plugin");
        }else if (row == listboxrow_chart) {
            stack_settings.page = Dactl.SettingsStackPage.CHART;
            settings_topbar.set_subtitle ("Chart");
        } else {
            message ("Unexpected row selection");
        }
    }

    private void ok () {
        /* Copy settings values to objects in the Cld context */
        foreach (var uri in cld_data.keys) {
            var object = cld_ctx.get_object_from_uri (uri);
            if (object != null) {
                var svalues = cld_data.get (uri);
                foreach (var spec in svalues.keys) {
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

        /* Copy dactl settings to objects in the UI model */
        foreach (var object in dactl_data.keys) {
            debug ("%s", object.id);
            if (object != null) {
                var svalues = dactl_data.get (object);
                foreach (var spec in svalues.keys) {
                    var name = spec.get_name ();
                    var value = svalues.get (spec).value;
                    bool writable = (spec.flags & GLib.ParamFlags.WRITABLE) ==
                                                       GLib.ParamFlags.WRITABLE;
                    bool is_dactl_object = value.type ().is_a (Type.from_name ("DactlObject"));
                    if (writable && !is_dactl_object) {
                        debug (
                              "%s:%s  %s:%s",
                              object.id,
                              object.get_type ().name (),
                              name,
                              value.type ().name ()
                              );
                        /* FIXME use reparent if property is Gtk.Widget.parent */
                        if ((object.get_type ()).is_a (typeof (Gtk.Widget))) {
                            if (name == "parent") {
                                /*
                                 *(object as Gtk.Widget).reparent (value as Gtk.Container);
                                 *message ("object is %s with %s that is %s", object.get_type ().name (), name, value.type_name ());
                                 */
                            }
                        } else {
                            object.set_property (name, value);
                        }
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
                    }
                }
            }
        }
        stack_settings.general.update_preferences ();

        destroy ();
    }

    private void cancel () {
        close ();
    }
}

