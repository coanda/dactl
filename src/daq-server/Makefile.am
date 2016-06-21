CLEANFILES =
DISTCLEANFILES =
BUILT_SOURCES =
EXTRA_DIST =

bin_PROGRAMS = daq-server

daq_server_VALAFLAGS = \
	-H $(srcdir)/libdaq-server.h -C -c --thread \
	--vapidir=$(top_srcdir)/vapi \
	--vapidir=$(top_srcdir)/src/libdactl-core \
	--vapidir=$(top_srcdir)/src/libdactl-cli \
	--pkg posix \
	--pkg gio-2.0 \
	--pkg gee-0.8 \
	--pkg json-glib-1.0 \
	--pkg libsoup-2.4 \
	--pkg dactl-config \
	--pkg dactl-core-0.3 \
	--pkg dactl-cli-0.3 \
	$(NULL)

daq_server_includes = \
	--include config.h \
	-DLOCALEDIR=\""$(datadir)/locale"\" \
	-DDATADIR=\""$(shareddir)"\" \
	-I$(top_srcdir)/src/libdactl-core \
	-I$(top_srcdir)/src/libdactl-cli \
	$(NULL)

daq_server_CFLAGS = \
	-DG_LOG_DOMAIN=\"daq-server\" \
	-DGETTEXT_PACKAGE=\"dactl\" \
	$(LIBDACTL_CFLAGS) \
	$(LIBDACTL_CLI_CFLAGS) \
	$(DACTL_SERVER_CFLAGS) \
	$(DEBUG_CFLAGS) \
	$(OPTIMIZE_CFLAGS) \
	$(daq_server_includes) \
	-Wno-deprecated-declarations \
	-Wno-discarded-qualifiers \
	-Wno-implicit-function-declaration \
	-Wno-incompatible-pointer-types \
	-Wno-unused-but-set-variable \
	-Wno-unused-label \
	-Wno-unused-function \
	$(NULL)

daq_server_LDADD = \
	$(LIBDACTL_LIBS) \
	$(LIBDACTL_CLI_LIBS) \
	$(DACTL_SERVER_LIBS) \
	$(top_builddir)/src/libdactl-core/libdactl-core-0.3.la \
	$(top_builddir)/src/libdactl-cli/libdactl-cli-0.3.la \
	$(NULL)

daq_server_headers = \
	libdaq-server.h \
	$(NULL)

daq_server_SOURCES = \
	main.vala \
	application.vala \
	dbus-service.vala \
	rest-service.vala \
	$(NULL)

BUILT_SOURCES += libdaq-server.h

-include $(top_srcdir)/git.mk
