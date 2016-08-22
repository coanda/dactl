/**
 * Holds constants defined by the build system.
 */

[CCode (cheader_filename = "config.h")]
public class Dactl.DAQ.Config {

    /* Package information */

    [CCode (cname = "DAQ_PACKAGE_NAME")]
    public static const string PACKAGE_NAME;

    [CCode (cname = "DAQ_PACKAGE_STRING")]
    public static const string PACKAGE_STRING;

    [CCode (cname = "DAQ_PACKAGE_VERSION")]
    public static const string PACKAGE_VERSION;

    /* Configured paths - these variables are not present in config.h, they are
     * passed to underlying C code as cmd line macros. */

    [CCode (cname = "DAQ_DATA_DIR")]
    public static const string PACKAGE_DATA_DIR;

    [CCode (cname = "DAQ_DEVICE_DIR")]
    public static const string PACKAGE_DEVICe_DIR;
}
