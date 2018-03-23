#ifndef CONFIG_H_INCLUDED
#include "config.h"

/**
 * All this is to keep Vala happy & configured..
 */

const char *DACTL_PACKAGE_NAME = PACKAGE_NAME;
const char *DACTL_PACKAGE_STRING = PACKAGE_STRING;
const char *DACTL_PACKAGE_VERSION = PACKAGE_VERSION;
const char *DACTL_PACKAGE_URL = PACKAGE_URL;

const char *DACTL_DATADIR = DATADIR;
const char *DACTL_CONFDIR = SYSCONFDIR;
const char *DACTL_LOCALEDIR = LOCALEDIR;
const char *DACTL_WEB_EXTENSION_DIR = WEB_EXTENSION_DIR;
const char *DACTL_PLUGINDIR = PLUGINDIR;
const char *DACTL_VERSION = PACKAGE_VERSION;
const char *DACTL_WEBSITE = PACKAGE_URL;
const char *DACTL_GETTEXT_PACKAGE = GETTEXT_PACKAGE;

#else
#error config.h missing!
#endif
