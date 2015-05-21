[GtkTemplate (ui = "/org/coanda/dactl/ui/configuration.ui")]
public class Dactl.ConfigurationEditor : Gtk.Box {

    [GtkChild]
    private Gtk.ScrolledWindow sw_config_view;

    [GtkChild]
    private Gtk.Label lbl_filename;

    [GtkChild]
    private Gtk.MenuButton btn_styles;

    private Gtk.SourceBuffer config_buffer;

    private Gtk.SourceView config_view;

    private const GLib.ActionEntry[] action_entries = {
        { "undo", undo_activated_cb, null, null, null },
        { "redo", redo_activated_cb, null, null, null },
        { "style", style_activated_cb, "s", "\"solarized-dark\"", null }
    };

    private GLib.SimpleActionGroup action_group;

    private string _filename;

    public string filename {
        get { return _filename; }
        set {
            _filename = value;
            lbl_filename.label = _filename;
            update_config_buffer ();
        }
    }

    construct {
        action_group = new GLib.SimpleActionGroup ();

        var style_manager = new Gtk.SourceStyleSchemeManager ();
        var menu = new GLib.Menu ();
        var section = new GLib.Menu ();

        foreach (var id in style_manager.scheme_ids) {
            var item = new GLib.MenuItem (id, "cfg.style");
            item.set_attribute_value ("target", id);
            section.append_item (item);
        }

        action_group.add_action_entries (action_entries, this);
        this.insert_action_group ("cfg", action_group);

        menu.append_section (null, section);

        btn_styles.menu_model = (GLib.MenuModel) menu;
        btn_styles.use_popover = true;
        btn_styles.relief = Gtk.ReliefStyle.NONE;
        btn_styles.show ();
    }

    private void update_config_buffer () {
        var manager = new Gtk.SourceLanguageManager ();
        var language = manager.guess_language (filename, "text/xml");

        // FIXME: should really be a selectable option using the existing styles
        var style_manager = new Gtk.SourceStyleSchemeManager ();
        var style = style_manager.get_scheme ("solarized-dark");

        config_buffer = new Gtk.SourceBuffer.with_language (language);
        config_buffer.highlight_syntax = true;
        config_buffer.highlight_matching_brackets = true;
        config_buffer.style_scheme = style;

        config_view = new Gtk.SourceView.with_buffer (config_buffer);
        config_view.auto_indent = true;
        config_view.highlight_current_line = true;
        config_view.indent_width = 4;
        config_view.show_line_numbers = true;
        config_view.tab_width = 4;

        sw_config_view.add (config_view);

        try {
            string text;
            FileUtils.get_contents (filename, out text);
            config_buffer.begin_not_undoable_action ();
            config_buffer.text = text;
            config_buffer.end_not_undoable_action ();
            message ("Loading file: %s", filename);
            show_all ();
        } catch (GLib.Error e) {
            stderr.printf ("Error: %s\n", e.message);
        }
    }

    private void undo_activated_cb () {
        config_buffer.undo ();
    }

    private void redo_activated_cb () {
        config_buffer.redo ();
    }

    private void style_activated_cb (GLib.SimpleAction action, Variant? parameter)
        requires (parameter != null)
        requires (parameter.is_of_type (VariantType.STRING)) {

        var popover = btn_styles.get_popover ();
        popover.hide ();
        btn_styles.set_active (false);

        var style_str = parameter.get_string (null);
        var style_manager = new Gtk.SourceStyleSchemeManager ();
        var style = style_manager.get_scheme (style_str);
        config_buffer.style_scheme = style;

        action.set_state (new Variant.string (style_str));
    }

    [GtkCallback]
    public bool key_pressed_cb (Gdk.EventKey event) {
        var default_modifiers = Gtk.accelerator_get_default_mod_mask ();

        if (event.keyval == Gdk.Key.z &&
            (event.state & default_modifiers) == Gdk.ModifierType.CONTROL_MASK) {
            action_group.activate_action ("undo", null);
        } else if (event.keyval == Gdk.Key.y &&
            (event.state & default_modifiers) == Gdk.ModifierType.CONTROL_MASK) {
            action_group.activate_action ("redo", null);
        }

        return false;
    }
}
