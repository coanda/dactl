/**
 * This file is a modified version taken from Rygel.
 *
 * Parse plugin sidecar file and provide path to the module.
 *
 * Sidecar files are keyfiles, loosely compatible with the files used by
 * libpeas.
 *
 * A minimal file for the plugin libdactl-sompelugin.so looks like this:
 *
 * [Plugin]
 * Name = SomeNameForThePlugin
 * Module = someplugin
 *
 * Name must not contain any whitespaces.
 */
public class Dactl.PluginInformation : GLib.Object {
    /// Full path to the loadable module file
    public string module_path { get; construct; }

    /// Name of this module
    public string name { get; construct; }

    private PluginInformation (string module_path, string name) {
        GLib.Object (module_path: module_path, name : name);
    }

    /**
     * Factory method to create a #DactlPluginInformation from #GFile.
     *
     * @param file a #GFile pointing to the sidecar file
     * @return A new instance of #DactlPluginInformation
     */
    public static PluginInformation new_from_file (File file) throws Error {
        var keyfile = new KeyFile ();
        keyfile.load_from_file (file.get_path (), KeyFileFlags.NONE);
        if (!keyfile.has_group ("Plugin")) {
            throw new KeyFileError.GROUP_NOT_FOUND
                                        (_("[Plugin] group not found"));
        }

        var name = keyfile.get_string ("Plugin", "Name");
        var module = keyfile.get_string ("Plugin", "Module");

        var module_dir = file.get_parent ();
        var module_file = module_dir.get_child ("libdactl-%s.%s".printf (
                                                module,
                                                Module.SUFFIX));

        if (!module_file.query_exists ()) {
            // try .libs for uninstalled
            module_file = module_dir.get_child (".libs%clibdactl-%s.%s".printf (
                                                Path.DIR_SEPARATOR,
                                                module,
                                                Module.SUFFIX));
            if (!module_file.query_exists ()) {
                throw new FileError.EXIST (_("Plugin module %s does not exist"),
                                           module_file.get_path ());
            }
        }

        return new PluginInformation (module_file.get_path (), name);
    }
}
