[GtkTemplate (ui = "/org/coanda/dactl/ui/configuration.ui")]
public class Dactl.ConfigurationEditor : Gtk.Box {

    [GtkChild]
    private Gtk.ScrolledWindow sw_config_view;

    [GtkChild]
    private Gtk.Label lbl_filename;

    private Gtk.SourceBuffer config_buffer;

    private Gtk.SourceView config_view;

    private string _filename;

    public string filename {
        get { return _filename; }
        set {
            _filename = value;
            lbl_filename.label = _filename;
            update_config_buffer ();
        }
    }

    /**
     * Default construction.
     */
    public ConfigurationEditor () {
    }

    private void update_config_buffer () {
        var manager = new Gtk.SourceLanguageManager ();
        var language = manager.guess_language (filename, "text/xml");

        // FIXME: should really be a selectable option using the existing styles
        var style_manager = new Gtk.SourceStyleSchemeManager ();
        var style = style_manager.get_scheme ("solarizeddark");

        config_buffer = new Gtk.SourceBuffer.with_language (language);
        config_buffer.highlight_syntax = true;
        config_buffer.highlight_matching_brackets = true;
        config_buffer.style_scheme = style;

        config_view = new Gtk.SourceView.with_buffer (config_buffer);
        config_view.auto_indent = true;
        config_view.indent_width = 4;
        config_view.show_line_numbers = true;
        config_view.tab_width = 4;

        sw_config_view.add (config_view);

        try {
            string text;
            FileUtils.get_contents (filename, out text);
            config_buffer.text = text;
            message ("Loading file: %s", filename);
            show_all ();
        } catch (GLib.Error e) {
            stderr.printf ("Error: %s\n", e.message);
        }
    }
}
