CLEANFILES =
DISTCLEANFILES =
BUILT_SOURCES =
EXTRA_DIST =

bin_PROGRAMS = dactl-log

dactl_log_VALAFLAGS = \
	-H $(srcdir)/libdactl-log.h -C -c --thread \
	--vapidir=$(top_srcdir)/vapi \
	--vapidir=$(top_srcdir)/src/libdactl-core \
	--vapidir=$(top_srcdir)/src/libdactl-cli \
	--vapidir=$(top_srcdir)/src/libdactl-log \
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
	--pkg dactl-log-0.4 \
	--pkg dactl-net-0.4 \
	$(NULL)

dactl_log_includes = \
	--include config.h \
	-DLOCALEDIR=\""$(datadir)/locale"\" \
	-DDATADIR=\""$(shareddir)"\" \
	-I$(top_srcdir)/src/libdactl-core \
	-I$(top_srcdir)/src/libdactl-cli \
	-I$(top_srcdir)/src/libdactl-log \
	-I$(top_srcdir)/src/libdactl-net \
	$(NULL)

dactl_log_CFLAGS = \
	-DG_LOG_DOMAIN=\"dactl-log\" \
	-DGETTEXT_PACKAGE=\"dactl\" \
	$(LIBDACTL_CFLAGS) \
	$(LIBDACTL_CLI_CFLAGS) \
	$(LIBDACTL_LOG_CFLAGS) \
	$(LIBDACTL_NET_CFLAGS) \
	$(DEBUG_CFLAGS) \
	$(OPTIMIZE_CFLAGS) \
	$(dactl_log_includes) \
	-Wno-deprecated-declarations \
	-Wno-discarded-qualifiers \
	-Wno-implicit-function-declaration \
	-Wno-incompatible-pointer-types \
	-Wno-unused-but-set-variable \
	-Wno-unused-label \
	-Wno-unused-function \
	$(NULL)

dactl_log_LDADD = \
	$(LIBDACTL_LIBS) \
	$(LIBDACTL_CLI_LIBS) \
	$(LIBDACTL_NET_LIBS) \
	$(top_builddir)/src/libdactl-core/libdactl-core-0.4.la \
	$(top_builddir)/src/libdactl-cli/libdactl-cli-0.4.la \
	$(top_builddir)/src/libdactl-log/libdactl-log-0.4.la \
	$(top_builddir)/src/libdactl-net/libdactl-net-0.4.la \
	$(NULL)

dactl_log_headers = \
	libdactl-log.h \
	$(NULL)

dactl_log_SOURCES = \
	main.vala \
	server.vala \
	dbus-service.vala \
	rest-service.vala \
	zmq-service.vala \
	zmq-client.vala \
	$(NULL)

BUILT_SOURCES += libdactl-log.h

-include $(top_srcdir)/git.mk
