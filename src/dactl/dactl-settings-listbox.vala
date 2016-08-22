[GtkTemplate (ui = "/org/coanda/dactl/ui/settings-listbox.ui")]
public class Dactl.SettingsListBox : Gtk.ListBox {

    [GtkChild]
    private Gtk.SizeGroup size_group;

    public signal void request_choices (Dactl.PropertyBox box, GLib.Type type);

    public signal void new_data (GLib.ParamSpec spec, GLib.Value value);

    public signal void request_data (string uri);

    public void populate (Dactl.SettingValues svalues) {
        foreach (var row in get_children ())
            remove (row);

        foreach (GLib.ParamSpec spec in svalues.keys) {
            Value value = svalues.get (spec).value;

            if (spec.owner_type.name ().contains ("Cld" ) ||
                spec.owner_type.name ().contains ("Dactl")) {

                debug ("%s: %s %s nick: %s", spec.get_name (),
                                             spec.value_type.name (),
                                             value.strdup_contents (),
                                             spec.get_nick ());

                var box = new Dactl.PropertyBox.from_data (spec, value);
                box.request_choices.connect ((source, type) => {
                    request_choices (box, type);
                });

                box.notify["value"].connect (() => {
                    debug ("%s %s", box.spec.get_name (), box.value.type ().name ());
                    new_data (box.spec, box.value);
                });

                size_group.add_widget (box.box_labels);

                box.request_choices (value.type ());
                var row = new Gtk.ListBoxRow ();
                row.add (box);
                add (row);
            }
        }

        /* Sorts rows by sensitivity then alphabetically */
        set_sort_func ((row1, row2) => {
            var box1 = row1.get_child ();
            var box2 = row2.get_child ();
            var name1 = (box1 as Dactl.PropertyBox).lbl_nick.get_text ();
            var name2 = (box2 as Dactl.PropertyBox).lbl_nick.get_text ();
            var sens1 = box1.get_sensitive ();
            var sens2 = box2.get_sensitive ();
            if (sens1 && !sens2)
                return -1;
            else if (!sens1 && sens2)
                return 1;

            return name1.ascii_casecmp (name2);
        });

        show_all ();
    }
}

[GtkTemplate (ui = "/org/coanda/dactl/ui/settings-propertybox.ui")]
public class Dactl.PropertyBox : Gtk.Box {
    [GtkChild]
    public Gtk.Box box_labels;

    [GtkChild]
    public Gtk.Label lbl_nick;

    [GtkChild]
    public Gtk.Label lbl_blurb;

    /* A data model for storing a list or tree of choices */
    private Gtk.ComboBox combo;

    public Value value { get; private set; }

    public GLib.ParamSpec spec { get; private set; }

    public signal void request_choices (GLib.Type type);

    public PropertyBox.from_data (GLib.ParamSpec spec, Value value) {
        _spec = spec;
        this.value = value;
        this.orientation = Gtk.Orientation.HORIZONTAL;
        this.spacing = 20;
        lbl_nick.set_text (spec.get_nick ());
        lbl_blurb.set_text (spec.get_blurb ());

        /*
         *Gtk.Box box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
         *pack_start (box);
         */

        var type = value.type ();
        debug ("%s", type.name ());
        if (type.is_a (typeof (string))) {
            make_string ();
        } else if (type.is_a (typeof (double))) {
            make_double ();
        } else if (type.is_a (typeof (int))) {
            make_int ();
        } else if (type.is_a (typeof (int64))) {
            make_int64 ();
        } else if (type.is_a (typeof (bool))) {
            make_boolean ();
        } else if (type.is_a (typeof (Cld.Object))) {
            make_cld ();
        } else if (type.is_a (typeof (GLib.File))) {
            make_gfile ();
        } else if (type.is_enum ()) {
            make_enum ();
        } else if (type.is_flags ()) {
            make_flags ();
        } else if (type.is_a (typeof (Gdk.RGBA))) {
            make_rgba ();
        } else {
            Gtk.Entry entry = new Gtk.Entry ();
            entry.set_text (type.name ());
            pack_start (entry);
        }
        bool writable = (spec.flags & GLib.ParamFlags.WRITABLE) ==
                                                       GLib.ParamFlags.WRITABLE;
        if (!writable)
           set_sensitive (false);
    }

    private void make_string () {
        Gtk.Entry entry = new Gtk.Entry ();
        entry.set_text (value.strdup_contents ().replace ("\"", ""));

        entry.changed.connect (() => {
            value = entry.get_text ();
            debug ("%s", value.dup_string ());
        });

        pack_start (entry);
    }

    private void make_double () {
        double val = value.get_double ();
        Gtk.Entry entry = new Gtk.Entry ();
        if ((GLib.Math.fabs (val) > 1e6) || (GLib.Math.fabs (val) < 0.001)) {
            entry.set_text ("%.6e".printf (val));
        } else {
            entry.set_text ("%.8g".printf (val));
        }

        entry.changed.connect (() => {
            value = double.parse (entry.get_text ());
            debug ("%s", value.get_double ().to_string ());
        });

        entry.activate.connect (() => {
            string txt = entry.get_text ();
            val = double.parse (txt);
            if ((GLib.Math.fabs (val) > 1e6) || (GLib.Math.fabs (val) < 0.001)) {
                entry.set_text ("%.6e".printf (val));
            } else {
                entry.set_text ("%.8g".printf (val));
            }
        });
        pack_start (entry);
    }

    private void make_int () {
        int val = value.get_int ();
        Gtk.SpinButton spinbutton = new Gtk.SpinButton.with_range (-int.MAX, int.MAX, 1);
        spinbutton.set_numeric (true);
        spinbutton.set_update_policy (Gtk.SpinButtonUpdatePolicy.IF_VALID);
        spinbutton.set_value (val);
        spinbutton.value_changed.connect (() => {
            value =  (int)spinbutton.get_value ();
            debug ("%d", value.get_int());
        });

        pack_start (spinbutton);
    }

    private void make_int64 () {
        int64 val = value.get_int64 ();
        Gtk.SpinButton spinbutton = new Gtk.SpinButton.with_range (-int64.MAX, int64.MAX, 1);
        spinbutton.set_numeric (true);
        spinbutton.set_update_policy (Gtk.SpinButtonUpdatePolicy.IF_VALID);
        spinbutton.set_value (val);
        spinbutton.value_changed.connect (() => {
            value =  (int)spinbutton.get_value ();
            debug ("%d", value.get_int());
        });

        pack_start (spinbutton);
    }

    private void make_boolean () {
        bool state = value.get_boolean ();
        Gtk.ComboBoxText combo = new Gtk.ComboBoxText ();

        //combo = new Gtk.ComboBoxText ();
        combo.append (null, "TRUE");
        combo.append (null, "FALSE");

        if (state)
            combo.set_active (0);
        else
            combo.set_active (1);

        combo.changed.connect (() => {
            if (combo.get_active () == 0)
                value = true;
            else
                value = false;
        });
        pack_start (combo);
    }


    private void make_cld () {
        Cld.Object object = (Cld.Object)value;
        Gtk.ListStore store = new Gtk.ListStore (2, typeof (string), typeof (Cld.Object));
        Gtk.TreeIter iter;
        store.append (out iter);
        store.set (iter, 0, object.uri, 1, object);

        Gtk.CellRendererText renderer = new Gtk.CellRendererText ();

        combo = new Gtk.ComboBox.with_model (store);
        combo.pack_start (renderer, true);
        combo.add_attribute (renderer, "text", 0);
        combo.set_active (0);
        combo.changed.connect (() => {
            combo.get_active_iter (out iter);
            Value val;
            store.get_value (iter, 1, out val);
            value = val;
            Value uri;
            store.get_value (iter, 0, out uri);
            debug ("%s %s",(string) uri, ((Cld.Object)value).uri);
        });

        pack_start (combo);
    }

    private void make_gfile () {
        GLib.File file = (GLib.File)value;
        Gtk.FileChooser dialog = null;
        Gtk.Button button = new Gtk.Button.with_label (file.get_basename ());

        button.clicked.connect (() => {
            dialog = new Gtk.FileChooserDialog (
                                        "Choose a file",
                                        null,
                                        Gtk.FileChooserAction.SAVE,
                                        _("_Cancel"),
                                        Gtk.ResponseType.CANCEL,
                                        _("_Open"),
                                        Gtk.ResponseType.ACCEPT,
                                        null);
            try {
                dialog.set_file (file);
            } catch (GLib.Error e) {
                GLib.warning ("Message: %s Error code: %d", e.message, e.code);
            }

            if (dialog.get_uri () == null)
                dialog.set_current_name (file.get_basename ());

            debug ("file: %s folder: %s", file.get_uri (), dialog.get_uri ());
            dialog.set_do_overwrite_confirmation (true);
            (dialog as Gtk.Dialog).set_modal (true);
            (dialog as Gtk.Dialog).set_destroy_with_parent (true);

            var response = (dialog as Gtk.Dialog).run ();
            switch (response) {
                case Gtk.ResponseType.CANCEL:
                    debug ("CANCEL");
                    break;
                case Gtk.ResponseType.ACCEPT:
                    debug ("ACCEPT");
                    if (dialog.get_file () == null)
                        file = dialog.get_current_folder_file ();
                    file = dialog.get_file ();
                    break;
                default:
                    break;
            }

            try {
                dialog.set_file (file);
            } catch (GLib.Error e) {
                GLib.warning ("Message: %s Error code: %d", e.message, e.code);
            }
            button.set_label (file.get_basename ());
            debug ("file: %s folder: %s", file.get_uri (), dialog.get_uri ());
            value = file;
            (dialog as Gtk.Dialog).destroy ();
        });


        // Emitted when there is a change in the set of selected files:
        dialog.selection_changed.connect (() => {
            GLib.File f = dialog.get_file ();
            value = f;
            debug ("File chosen: %s %s", f.get_parent ().get_path (), f.get_basename ());
            f.unref ();
        });

        pack_start (button, true, true, 0);
    }

    private void make_enum () {
        GLib.EnumClass enumc = (EnumClass)value.type ().class_ref ();
        var nick = enumc.get_value (value.get_enum ()).value_nick;
        Gtk.ListStore store = new Gtk.ListStore (2, typeof (string), typeof (int));
        Gtk.TreeIter iter;
        store.append (out iter);
        store.set (iter, 0, nick, 1, value.get_enum ());

        Gtk.CellRendererText renderer = new Gtk.CellRendererText ();

        combo = new Gtk.ComboBox.with_model (store);
        combo.pack_start (renderer, true);
        combo.add_attribute (renderer, "text", 0);
        combo.set_active (0);
        combo.changed.connect (() => {
            combo.get_active_iter (out iter);
            Value val;
            store.get_value (iter, 1, out val);
            value = val;
            Value uri;
            store.get_value (iter, 0, out uri);
            debug ("%s %s",(string) uri, ((Cld.Object)value).uri);
        });
        for (int i = 0; i < enumc.n_values; i++) {

            nick = enumc.values[i].value_nick;
            var val = enumc.get_value_by_nick (nick).value;
            debug ("%s %d", nick, val);
            store.append (out iter);
            store.set (iter, 0, nick, 1, val);
        }

        pack_start (combo);
    }

    private void make_flags () {
        /* FlagsClass has a bug that is fixed by FlagsClass2 */
        GLib.FlagsClass2 flagsc = (FlagsClass2)value.type ().class_ref ();
        Gtk.ButtonBox box = new Gtk.ButtonBox (Gtk.Orientation.VERTICAL);
        box.set_layout (Gtk.ButtonBoxStyle.START);
        var type = value.type ();
        GLib.Value val = Value (type);

        foreach (var flags_value in flagsc.values) {
            var button = new Gtk.CheckButton.with_label (flags_value.value_name);
            if ((value.get_flags () & flags_value.value) == flags_value.value)
                button.set_active (true);
            button.toggled.connect (() => {

                if (button.get_active ()) {
                    val.set_flags (value.get_flags () | flags_value.value);
                } else {
                    val.set_flags (value.get_flags () & ~flags_value.value);
                }

                value = val;
            });
            box.add (button);
        }

        pack_start (box);
    }

    private void make_rgba () {
        Gdk.RGBA rgba = (Gdk.RGBA)value;
        Gtk.ColorButton button = new Gtk.ColorButton.with_rgba (rgba);

        button.set_title ("Color");
        button.set_use_alpha (true);
        button.color_set.connect (() => {
            uint16 alpha = button.get_alpha ();
            value = button.rgba;
        });
        pack_start (button, true, true, 0);
    }

    public void set_cld_object_choices (Gee.Map<string, Cld.Object> map) {
        Gtk.TreeIter iter;
        Gtk.ListStore store = combo.get_model () as Gtk.ListStore;

        foreach (var object in map.values) {
            store.append (out iter);
            store.set (iter, 0, object.uri, 1, object);
        }
    }

    public void set_dactl_object_choices (Gee.Map<string, Dactl.Object> map) {
        Gtk.TreeIter iter;
        Gtk.ListStore store = combo.get_model () as Gtk.ListStore;

        foreach (var object in map.values) {
            store.append (out iter);
            store.set (iter, 0, object.id, 1, object);
        }
    }

    public void set_enum_choices () {

    }
}

