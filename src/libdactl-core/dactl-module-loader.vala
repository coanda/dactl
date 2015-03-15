/*
 * This file is a modified version taken from Rygel.
 */

/**
 * Recursively walk a folder looking for shared libraries.
 *
 * The folder can either be walked synchronously or asynchronously.
 * Implementing classes need to implement the abstract method
 * load_module_from_file() which is called when the walker encounters a
 * dynamic module file.
 */
public abstract class Dactl.ModuleLoader : GLib.Object {
    private static const string LOADER_ATTRIBUTES =
                            FileAttribute.STANDARD_NAME + "," +
                            FileAttribute.STANDARD_TYPE + "," +
                            FileAttribute.STANDARD_IS_HIDDEN + "," +
                            FileAttribute.STANDARD_CONTENT_TYPE;

    private delegate void FolderHandler (File folder);

    private bool done;

    public string base_path { construct set; get; }

    /**
     * Create a recursive module loader for a given path.
     *
     * Either call load_modules() or load_modules_sync() to start descending
     * into the folder hierarchy and load the modules.
     *
     * @param path base path of the loader.
     */
    public ModuleLoader (string path) {
        GLib.Object (base_path : path);
    }

    public override void constructed () {
        base.constructed ();
        this.done = false;
    }

    // Plugin loading functions

    /**
     * Walk asynchronously through the tree and load modules.
     */
    public void load_modules () {
        assert (Module.supported());

        var folder = File.new_for_path (this.base_path);
        assert (folder != null && this.is_folder (folder));

        this.load_modules_from_folder.begin (folder);
    }

    /**
     * Walk synchronously through the tree and load modules.
     */
    public void load_modules_sync (Cancellable? cancellable = null) {
        debug ("Searching for modules in folder '%s'",
               this.base_path);
        var queue = new Queue<File> ();

        queue.push_head (File.new_for_path (this.base_path));
        while (!queue.is_empty ()) {
            if (cancellable != null && cancellable.is_cancelled ()) {
                break;
            }

            var folder = queue.pop_head ();
            try {
                var enumerator = folder.enumerate_children
                                        (LOADER_ATTRIBUTES,
                                         FileQueryInfoFlags.NONE,
                                         cancellable);
                var info = enumerator.next_file (cancellable);
                while (info != null) {
                    this.handle_file_info (folder, info, (subfolder) => {
                        queue.push_head (subfolder);
                    });
                    info = enumerator.next_file (cancellable);
                }
            } catch (Error error) {
                debug ("Failed to enumerate folder %s: %s",
                       folder.get_path (),
                       error.message);
            }
        }
    }

    /**
     * Load module from file.
     *
     * @param file File to load the module from
     * @return The implementation should return true if the class should
     *         continue to search for modules, false otherwise.
     */
    protected abstract bool load_module_from_file (File file);

    protected abstract bool load_module_from_info (PluginInformation info);

    /**
     * Process children of a folder.
     *
     * Recurse into folders or call load_module_from_file() if it looks
     * like a shared library.
     *
     * @param folder the folder
     */
    private async void load_modules_from_folder (File folder) {
        debug ("Searching for modules in folder '%s'.", folder.get_path ());

        GLib.List<FileInfo> infos;
        FileEnumerator enumerator;

        try {
            enumerator = yield folder.enumerate_children_async
                                        (LOADER_ATTRIBUTES,
                                         FileQueryInfoFlags.NONE,
                                         Priority.DEFAULT,
                                         null);

            infos = yield enumerator.next_files_async (int.MAX,
                                                       Priority.DEFAULT,
                                                       null);
        } catch (Error error) {
            critical (_("Error listing contents of folder '%s': %s"),
                      folder.get_path (),
                      error.message);

            return;
        }

        foreach (var info in infos) {
            if (this.done) {
                break;
            }

            this.handle_file_info (folder, info, (subfolder) => {
                this.load_modules_from_folder.begin (subfolder);
            });
        }

        debug ("Finished searching for modules in folder '%s'",
               folder.get_path ());
    }

    /**
     * Process a file info.
     * Utility method used by sync and async tree walk.
     *
     * @param folder parent folder
     * @param info the FileInfo of the file to process
     * @param handler a call-back if the FileInfo represents a folder.
     */
    private void handle_file_info (File          folder,
                                   FileInfo      info,
                                   FolderHandler handler) {
            var file = folder.get_child (info.get_name ());

            if (this.is_folder_eligible (info)) {
                handler (file);
            } else if (info.get_name ().has_suffix (".plugin")) {
                try {
                    var plugin_info = PluginInformation.new_from_file (file);

                    if (!this.load_module_from_info (plugin_info)) {
                        this.done = true;
                    }
                } catch (Error error) {
                    warning (_("Could not load plugin: %s"),
                             error.message);
                }
            }

    }

    private bool is_folder_eligible (FileInfo file_info) {
        return file_info.get_file_type () == FileType.DIRECTORY &&
               (file_info.get_name () == ".libs" ||
                !file_info.get_is_hidden ());
    }

    /**
     * Check if a File is a folder.
     *
     * @param file the File to check
     * @return true, if file is folder, false otherwise.
     */
    private bool is_folder (File file) {
        try {
            var file_info = file.query_info (FileAttribute.STANDARD_TYPE + "," +
                                             FileAttribute.STANDARD_IS_HIDDEN,
                                             FileQueryInfoFlags.NONE,
                                             null);

            return this.is_folder_eligible (file_info);
        } catch (Error error) {
            critical (_("Failed to query content type for '%s'"),
                      file.get_path ());

            return false;
        }
    }
}
