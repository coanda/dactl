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
	--vapidir=$(top_srcdir)/src/libdactl-daq \
	--vapidir=$(top_srcdir)/src/libdactl-net \
	--pkg posix \
	--pkg gio-2.0 \
	--pkg gee-0.8 \
	--pkg json-glib-1.0 \
	--pkg libsoup-2.4 \
	--pkg libzmq \
	--pkg dactl-config \
	--pkg dactl-core-0.4 \
	--pkg dactl-cli-0.4 \
	--pkg dactl-daq-0.4 \
	--pkg dactl-net-0.4 \
	$(NULL)

dactl_daq_includes = \
	-include config.h \
	-DLOCALEDIR=\""$(datadir)/locale"\" \
	-DDATADIR=\""$(shareddir)"\" \
	-I$(top_srcdir)/src/libdactl-core \
	-I$(top_srcdir)/src/libdactl-cli \
	-I$(top_srcdir)/src/libdactl-daq \
	-I$(top_srcdir)/src/libdactl-net \
	$(NULL)

dactl_daq_CFLAGS = \
	-DG_LOG_DOMAIN=\"dactl-daq\" \
	-DGETTEXT_PACKAGE=\"dactl\" \
	$(LIBDACTL_CFLAGS) \
	$(LIBDACTL_CLI_CFLAGS) \
	$(LIBDACTL_NET_CFLAGS) \
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
	$(LIBDACTL_NET_LIBS) \
	$(top_builddir)/src/libdactl-core/libdactl-core-0.4.la \
	$(top_builddir)/src/libdactl-cli/libdactl-cli-0.4.la \
	$(top_builddir)/src/libdactl-daq/libdactl-daq-0.4.la \
	$(top_builddir)/src/libdactl-net/libdactl-net-0.4.la \
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
