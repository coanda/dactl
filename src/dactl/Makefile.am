include $(top_srcdir)/common.am

bin_PROGRAMS = dactl

gresource_file = $(top_srcdir)/data/dactl.gresource.xml

# There should be an option to --enable-ui during configuration to allow for
# building only the cli. Useful for example on an embedded device possibly.
#
# This is going to be confusing for a while because plugins have ui components,
# and so do several of the configurable objects that use views like the chart
# and grid. These will likely be broken out into multiple files later on.
if BUILD_UI
UI_SOURCES = \
	dactl-ui-application.vala \
	dactl-ui-application-settings-dialog.vala \
	dactl-ui-application-view.vala \
	dactl-ao-box.vala \
	dactl-aichannel-treeview.vala \
	dactl-aochannel-treeview.vala \
	dactl-calibration-treeview.vala \
	dactl-channel-treeview.vala \
	dactl-chart.vala \
	dactl-chart-axis.vala \
	dactl-chart-trace.vala \
	dactl-chart-settings-dialog.vala \
	dactl-chart-widget.vala \
	dactl-coefficient-treeview.vala \
	dactl-data-file-dialog.vala \
	dactl-device-treeview.vala \
	dactl-dichannel-treeview.vala \
	dactl-dio-viewer-dialog.vala \
	dactl-do-box.vala \
	dactl-dochannel-treeview.vala \
	dactl-experiment-treeview.vala \
	dactl-export-csv-dialog.vala \
	dactl-grid.vala \
	dactl-log-settings-dialog.vala \
	dactl-log-treeview.vala \
	dactl-module-treeview.vala \
	dactl-pid-box.vala \
	dactl-pid-control-treeview.vala \
	dactl-pid-settings-dialog.vala \
	dactl-pnid.vala \
	dactl-recent-files-dialog.vala \
	dactl-serialport-settings-box.vala \
	dactl-vchannel-treeview.vala \
	dactl-xml-config-dialog.vala
endif

dactl_VALAFLAGS = \
	--enable-experimental --target-glib=2.38 --gresources $(gresource_file) \
	-H $(srcdir)/libdactl.h -C -c --thread \
	--vapidir=$(top_srcdir)/vapi \
	-X -g -X -pg -X -w \
	--pkg posix \
	--pkg linux \
	$(DACTL_DEPS_VALAFLAGS) \
	$(DACTL_CLD_DEPS_VALAFLAGS) \
	$(DACTL_UI_DEPS_VALAFLAGS) \
	$(DACTL_COMMON_LIBDACTL_CORE_VALAFLAGS) \
	$(DACTL_COMMON_VALAFLAGS)

dactl_CFLAGS = \
	--include config.h \
	-DG_LOG_DOMAIN='"Dactl"' \
	-DLOCALEDIR=\""$(datadir)/locale"\" \
	$(DACTL_DEPS_CFLAGS) \
	$(DACTL_CLD_DEPS_CFLAGS) \
	$(DACTL_UI_DEPS_CFLAGS) \
	$(DACTL_COMMON_LIBDACTL_CORE_CFLAGS)

dactl_LDADD = \
	$(DACTL_DEPS_LIBS) \
	$(DACTL_CLD_DEPS_LIBS) \
	$(DACTL_UI_DEPS_LIBS) \
	$(DACTL_COMMON_LIBDACTL_CORE_LIBS)

dactl_headers = \
	dactl.h \
	libdactl.h

resource_files = $(shell $(GLIB_COMPILE_RESOURCES) --generate-dependencies --sourcedir=$(top_srcdir)/data $(gresource_file))
resources.c: $(gresource_file) $(resource_files)
	$(AM_V_GEN) $(GLIB_COMPILE_RESOURCES) --target=$@ --sourcedir=$(top_srcdir)/data --generate-source $<

BUILT_SOURCES = resources.c

dactl_SOURCES = \
	$(BUILT_SOURCES) \
	dactl-main.vala \
	dactl-dbus-service.vala \
	dactl-application.vala \
	dactl-application-builder.vala \
	dactl-application-config.vala \
	dactl-application-model.vala \
	dactl-application-controller.vala \
	dactl-application-view.vala \
	dactl-utility.vala \
	dactl-view.vala \
	$(CLI_SOURCES) \
	$(UI_SOURCES) \
	$(NULL)

MAINTAINERCLEANFILES += $(BUILT_SOURCES)

CLEANFILES = \
	*.stamp \
	stamp-h1 \
	$(srcdir)/libdactl.h

EXTRA_DIST = \
	$(gresource_file) \
	$(BUILT_SOURCES)
