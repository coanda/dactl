namespace Dactl {

    /* Package information */

    [CCode (cheader_filename = "dactl-config.h")]
    public extern const string PACKAGE_NAME;

    [CCode (cheader_filename = "dactl-config.h")]
    public extern const string PACKAGE_STRING;

    [CCode (cheader_filename = "dactl-config.h")]
    public extern const string PACKAGE_VERSION;

    [CCode (cheader_filename = "dactl-config.h")]
    public extern const string PACKAGE_URL;

    [CCode (cheader_filename = "dactl-config.h")]
    public extern const string DATADIR;

    [CCode (cheader_filename = "dactl-config.h")]
    public extern const string CONFDIR;

    [CCode (cheader_filename = "dactl-config.h")]
    public extern const string LOCALEDIR;

    [CCode (cheader_filename = "dactl-config.h")]
    public extern const string WEB_EXTENSION_DIR;

    [CCode (cheader_filename = "dactl-config.h")]
    public extern const string PLUGINDIR;

    [CCode (cheader_filename = "dactl-config.h")]
    public extern const string VERSION;

    [CCode (cheader_filename = "dactl-config.h")]
    public extern const string WEBSITE;

    [CCode (cheader_filename = "dactl-config.h")]
    public extern const string GETTEXT_PACKAGE;
}

/* TODO: Need to add more constants to the config */

/*
 *[CCode (cheader_filename = "dactl-config.h")]
 *namespace Dactl.Config {
 */

    /* Gettext package */

/*
 *    [CCode (cname = "GETTEXT_PACKAGE")]
 *    public extern const string GETTEXT_PACKAGE;
 *
 *    [CCode (cname = "LOCALEDIR")]
 *    public extern const string LOCALEDIR;
 */

    /* Configured paths - these variables are not present in config.h, they are
     * passed to underlying C code as cmd line macros. */

/*
 *    [CCode (cname = "SYS_CONFIG_DIR")]
 *    public extern const string SYS_CONFIG_DIR;
 *
 *    [CCode (cname = "PLUGIN_DIR")]
 *    public extern const string PLUGIN_DIR;
 *
 *    [CCode (cname = "UI_DIR")]
 *    public extern const string UI_DIR;
 *
 *    [CCode (cname = "WEB_EXTENSION_DIR")]
 *    public extern const string WEB_EXTENSION_DIR;
 */

    /*
     *[CCode (cname = "DEVICE_DIR")]
     *public extern const string DEVICE_DIR;
     */

    /*
     *[CCode (cname = "BACKEND_DIR")]
     *public extern const string BACKEND_DIR;
     */

/*
 *    [CCode (cname = "LIBDIR")]
 *    public extern const string LIBDIR;
 *}
 */
