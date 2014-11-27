public enum Dactl.UI.State {
    WINDOWED,
    FULLSCREEN,
}

/**
 * The Gtk.Application class expects an ApplicationWindow so a lot is being
 * moved here from outside of the actual view class.
 */
[GtkTemplate (ui = "/org/coanda/dactl/ui/application-view.ui")]
public class Dactl.UI.ApplicationView : Gtk.ApplicationWindow, Dactl.ApplicationView {

    /* Property backing fields */
    private int _chan_scroll_min_width = 50;

    /**
     * From previous versions, limits the width of an interface element.
     */
    public int chan_scroll_min_width {
        get { return _chan_scroll_min_width; }
        set { _chan_scroll_min_width = value; }
    }

    /**
     * The value is controlled by the existence of certain configuration
     * elements. If it's true a default interface layout will be constructed
     * otherwise a valid layout is expected to be provided.
     */
    public bool using_default { get; private set; default = true; }

    /* Model used to update the view */
    private Dactl.ApplicationModel model;

    [GtkChild]
    private Dactl.Topbar topbar;

    [GtkChild]
    private Dactl.Sidebar sidebar;

    [GtkChild]
    private Gtk.Stack layout;

    [GtkChild]
    private Gtk.Box settings;

    [GtkChild]
    private Dactl.ConfigurationEditor configuration;

    [GtkChild]
    private Dactl.CsvExport export;

    [GtkChild]
    private Dactl.Settings settings_content;

    private uint configure_id;

    public static const uint configure_id_timeout = 100;    // ms

    private string previous_page;

    public Dactl.UI.State state { get; set; default = Dactl.UI.State.WINDOWED; }

    // The application page is intentionally left out
    private string[] pages = { "configuration", "export", "settings" };

    /**
     * Default construction.
     *
     * @param model Data model class that the interface uses to update itself
     * @return A new instance of an ApplicationView object
     */
    internal ApplicationView (Dactl.ApplicationModel model) {
        GLib.Object (title: "Data Acquisition and Control",
                     window_position: Gtk.WindowPosition.CENTER);

        this.model = model;
        assert (this.model != null);

        /* FIXME: Load previous window size and fullscreen state using settings. */
        set_default_size (1280, 720);

        setup ();
        load_style ();
    }

    private void setup () {
        layout.transition_duration = 400;
        layout.transition_type = Gtk.StackTransitionType.CROSSFADE;
        layout.expand = true;

        configuration.filename = model.config_filename;
    }

    /**
     * Load the application styling from CSS.
     */
    private void load_style () {

        /* XXX use resource instead - see gtk3-demo for example */

        /* Apply stylings from CSS resource */
        var provider = Dactl.load_css ("gtk-style.css");
        Gtk.StyleContext.add_provider_for_screen (Gdk.Screen.get_default (),
                                                  provider,
                                                  600);
    }

    public void add_actions () {
        /* sidebar actions */
        sidebar.settings_selection_action.activate.connect (settings_selection_activated_cb);
        this.add_action (sidebar.settings_selection_action);
    }

    /**
     * Construct the layout using the contents of the configuration file.
     *
     * Lists of objects included:
     * - pages
     * - boxes
     * - trees
     * - charts
     * - control views
     * - module/plugin views
     */
    public void construct_layout () {

        /* Currently only pages can be added to the notebook */
        var pages = model.get_object_map (typeof (Dactl.Page));
        if (pages.size == 0) {
            layout_add_page (new Dactl.Page ());
        } else {
            foreach (var page in pages.values) {
                message ("Constructing layout for page `%s'", page.id);
                layout_add_page (page as Dactl.Page);
            }
        }

        layout.show_all ();

        layout_change_page (model.startup_page);
        connect_signals ();
    }

    private void layout_add_page (Dactl.Page page) {
        message ("Adding page `%s' with title `%s'", page.id, page.title);
        layout.add_titled (page, page.id, page.title);
        pages += page.id;
    }

    public void layout_change_page (string id) {
        debug ("Changing layout page from `%s' to `%s'", layout.visible_child_name, id);
        if (layout.visible_child_name != id) {
            if (id == "configuration" && layout.visible_child != configuration) {
                previous_page = layout.visible_child_name;
                layout.visible_child = configuration;
                topbar.set_visible_child_name (id);
                sidebar.page = Dactl.SidebarPage.NONE;
            } else if (id == "export" && layout.visible_child != export) {
                previous_page = layout.visible_child_name;
                layout.visible_child = export;
                topbar.set_visible_child_name (id);
                sidebar.page = Dactl.SidebarPage.NONE;
            } else if (id == "settings" && layout.visible_child != settings) {
                previous_page = layout.visible_child_name;
                layout.visible_child = settings;
                topbar.set_visible_child_name (id);
                sidebar.page = Dactl.SidebarPage.SETTINGS;
            } else {
                layout.set_visible_child_name (id);
                topbar.set_visible_child_name ("application");
                sidebar.page = Dactl.SidebarPage.NONE;
            }
        }
    }

    public void layout_back_page () {
        var id = previous_page;
        layout_change_page (id);
    }

    public void layout_previous_page () {
        int pos = -1;

        for (int i = 0; i < pages.length; i++) {
            if (layout.visible_child_name == pages[i])
                pos = i;
        }

        if (pos != -1 && pages[pos - 1] != "settings") {
            layout.transition_type = Gtk.StackTransitionType.SLIDE_LEFT_RIGHT;
            layout_change_page (pages[pos - 1]);
            layout.transition_type = Gtk.StackTransitionType.CROSSFADE;
        }
    }

    public void layout_next_page () {
        int pos = -1;

        for (int i = 0; i < pages.length; i++) {
            if (layout.visible_child_name == pages[i])
                pos = i;
        }

        if (pos != -1 && pages[pos + 1] != "configuration") {
            layout.transition_type = Gtk.StackTransitionType.SLIDE_LEFT_RIGHT;
            layout_change_page (pages[pos + 1]);
            layout.transition_type = Gtk.StackTransitionType.CROSSFADE;
        }
    }

    public void connect_signals () {
        /* Callbacks with functions */
        var treeviews = model.get_object_map (typeof (Dactl.ChannelTreeView));
        foreach (var treeview in treeviews.values) {
            (treeview as Dactl.ChannelTreeView).channel_selected.connect (treeview_channel_selected_cb);
        }
    }

    private void treeview_channel_selected_cb (string id) {
        debug ("Selected channel `%s' to be highlighted on chart", id);
        var channel = model.ctx.get_object (id);

        /**
         * FIXME: the stripchart class doesn't use the chart as its base yet
         */
        var charts = model.get_object_map (typeof (Dactl.StripChart));
        foreach (var chart in charts.values) {
            (chart as Dactl.StripChart).highlight_trace (id);
        }
    }

    /**
     * Action callback for settings page selection.
     */
    private void settings_selection_activated_cb (SimpleAction action, Variant? parameter) {
        (settings_content as Dactl.Settings).page = (Dactl.SettingsPage) parameter;
    }

    [GtkCallback]
    public bool key_pressed_cb (Gdk.EventKey event) {
        var app = Dactl.UI.Application.get_default ();
        var default_modifiers = Gtk.accelerator_get_default_mod_mask ();

        if (event.keyval == Gdk.Key.Home) {
            layout_change_page (model.startup_page);
        } else if (event.keyval == Gdk.Key.F11) {
            if (state == Dactl.UI.State.WINDOWED) {
                (this as Gtk.Window).fullscreen ();
                state = Dactl.UI.State.FULLSCREEN;
            } else {
                (this as Gtk.Window).unfullscreen ();
                state = Dactl.UI.State.WINDOWED;
            }
            return true;
        } else if (event.keyval == Gdk.Key.F1) {
            app.activate_action ("help", null);
            return true;
        } else if (event.keyval == Gdk.Key.q &&
                   (event.state & default_modifiers) == Gdk.ModifierType.CONTROL_MASK) {
            app.activate_action ("quit", null);
            return true;
        } else if (event.keyval == Gdk.Key.Left && // ALT + Left -> back
                   (event.state & default_modifiers) == Gdk.ModifierType.MOD1_MASK) {
            //topbar.click_back_button ();
            return true;
        } else if (event.keyval == Gdk.Key.Right && // ALT + Right -> forward
                   (event.state & default_modifiers) == Gdk.ModifierType.MOD1_MASK) {
            //topbar.click_forward_button ();
            return true;
        } else if (event.keyval == Gdk.Key.Escape) { // ESC -> cancel
            //topbar.click_cancel_button ();
        }

        return false;
    }

    [GtkCallback]
    private bool configure_event_cb () {
        if (state == Dactl.UI.State.FULLSCREEN)
            return false;

        if (configure_id != 0)
            GLib.Source.remove (configure_id);

        configure_id = Timeout.add (configure_id_timeout, () => {
            configure_id = 0;
            //save_window_geometry ();
            return false;
        });

        return false;
     }

    [GtkCallback]
    private bool window_state_event_cb (Gdk.EventWindowState event) {
        if (Dactl.UI.State.FULLSCREEN in event.changed_mask)
            this.notify_property ("fullscreen");

        if (state == Dactl.UI.State.FULLSCREEN)
            return false;

        //settings.set_boolean ("window-maximized", maximized);

        return false;
    }

    [GtkCallback]
    private bool delete_event_cb () {
        /**
         * FIXME: this doesn't work, it still closes the window, not really a
         *        big surprise though
         * FIXME: should be checking if the window was closed during an
         *        important operation, or while in a state that could cause
         *        issues
         * FIXME: this should just chain up to the application quit but is
         *        doesn't seem to want to fire the dialog when it does
         */

/*
 *        var dialog = new Gtk.MessageDialog (null,
 *                                            Gtk.DialogFlags.MODAL,
 *                                            Gtk.MessageType.QUESTION,
 *                                            Gtk.ButtonsType.YES_NO,
 *                                            "Are you sure you want to quit?");
 *
 *        (dialog as Gtk.Dialog).response.connect ((response_id) => {
 *            switch (response_id) {
 *                case Gtk.ResponseType.NO:
 *                    (dialog as Gtk.Dialog).destroy ();
 *                    break;
 *                case Gtk.ResponseType.YES:
 *                    var app = Dactl.UI.Application.get_default ();
 *                    app.remove_window (this);
 *                    (dialog as Gtk.Dialog).destroy ();
 *                    app.quit ();
 *                    break;
 *            }
 *        });
 *
 *        (dialog as Gtk.Dialog).run ();
 */

        var app = Dactl.UI.Application.get_default ();
        app.remove_window (this);
        app.quit ();

        return false;
    }
}
