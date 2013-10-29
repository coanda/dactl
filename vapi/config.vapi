[CCode (prefix = "", lower_case_cprefix = "", cheader_filename = "config.h")]
namespace Config {
    /* Package information */
    public const string PACKAGE_NAME;
    public const string PACKAGE_STRING;
    public const string PACKAGE_VERSION;

    /* Gettext package */
    public const string GETTEXT_PACKAGE;

    /* Configured paths - these variables are not present in config.h, they are
     * passed to underlying C code as cmd line macros. */
    public const string LOCALEDIR;  /* /usr/local/share/locale */
    public const string DATADIR;    /* /usr/local/etc/dactl */
    public const string UI_DIR;     /* /usr/local/etc/dactl/ui */
    public const string LIBDIR;     /* /usr/local/lib - ??? not sure if needed */
}
