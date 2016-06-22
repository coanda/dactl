CLEANFILES =
DISTCLEANFILES =
BUILT_SOURCES =
EXTRA_DIST =

bin_PROGRAMS = dactl-daq

dactl_daq_VALAFLAGS = \
	-H $(srcdir)/libdactl-daq.h -C -c --thread \
	--vapidir=$(top_srcdir)/vapi \
	--vapidir=$(top_srcdir)/src/libdactl-core \
	--vapidir=$(top_srcdir)/src/libdactl-cli \
	--pkg posix \
	--pkg gio-2.0 \
	--pkg gee-0.8 \
	--pkg json-glib-1.0 \
	--pkg libsoup-2.4 \
	--pkg libzmq \
	--pkg dactl-config \
	--pkg dactl-core-0.3 \
	--pkg dactl-cli-0.3 \
	$(NULL)

dactl_daq_includes = \
	--include config.h \
	-DLOCALEDIR=\""$(datadir)/locale"\" \
	-DDATADIR=\""$(shareddir)"\" \
	-I$(top_srcdir)/src/libdactl-core \
	-I$(top_srcdir)/src/libdactl-cli \
	$(NULL)

dactl_daq_CFLAGS = \
	-DG_LOG_DOMAIN=\"dactl-daq\" \
	-DGETTEXT_PACKAGE=\"dactl\" \
	$(LIBDACTL_CFLAGS) \
	$(LIBDACTL_CLI_CFLAGS) \
	$(DACTL_SERVER_CFLAGS) \
	$(DEBUG_CFLAGS) \
	$(OPTIMIZE_CFLAGS) \
	$(dactl_daq_includes) \
	-Wno-deprecated-declarations \
	-Wno-discarded-qualifiers \
	-Wno-implicit-function-declaration \
	-Wno-incompatible-pointer-types \
	-Wno-unused-but-set-variable \
	-Wno-unused-label \
	-Wno-unused-function \
	$(NULL)

dactl_daq_LDADD = \
	$(LIBDACTL_LIBS) \
	$(LIBDACTL_CLI_LIBS) \
	$(DACTL_SERVER_LIBS) \
	$(top_builddir)/src/libdactl-core/libdactl-core-0.3.la \
	$(top_builddir)/src/libdactl-cli/libdactl-cli-0.3.la \
	$(NULL)

dactl_daq_headers = \
	libdactl-daq.h \
	$(NULL)

dactl_daq_SOURCES = \
	main.vala \
	server.vala \
	dbus-service.vala \
	rest-service.vala \
	zmq-service.vala \
	$(NULL)

BUILT_SOURCES += libdactl-daq.h

-include $(top_srcdir)/git.mk
