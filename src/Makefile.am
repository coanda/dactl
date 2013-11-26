#SUBDIRS = lib

bin_PROGRAMS = dactl

VALAFLAGS = \
	-H $(srcdir)/libdactl.h -C -c --thread \
	--vapidir=$(srcdir)/../vapi -X -g -X -pg\
	@VALA_PACKAGES@ --pkg callbacks --pkg config --pkg posix --pkg linux

dactl_CFLAGS = \
	-DPACKAGE_DATA_DIR=\""$(datadir)"\" \
	-DPACKAGE_LOCALE_DIR=\""$(prefix)/$(DATADIRNAME)/locale"\" \
	@PACKAGE_CFLAGS@ \
	$(AM_CFLAGS) \
	$(GLIB_CFLAGS) \
	$(GTK_CFLAGS) \
	$(GEE_CFLAGS) \
	$(GSL_CFLAGS) \
	$(XML_CFLAGS) \
	$(CLD_CFLAGS) \
	$(COMEDI_CFLAGS)

dactl_LDADD = \
	@PACKAGE_LIBS@ \
	$(GLIB_LIBS) \
	$(GTK_LIBS) \
	$(GEE_LIBS) \
	$(GSL_LIBS) \
	$(XML_LIBS) \
	$(CLD_LIBS) \
	$(COMEDI_LIBS)

dactl_headers = \
	common.h \
	dactl.h \
	libdactl.h \
	callbacks.h

dactl_SOURCES = \
	main.vala \
	application-model.vala \
	application-config.vala \
	graphical-view.vala \
	command-line-view.vala \
	application-controller.vala \
	application-settings-dialog.vala \
	aichannel-treeview.vala \
	aochannel-treeview.vala \
	brabender-module-box.vala\
	calibration-treeview.vala \
	channel-treeview.vala \
	chart-widget.vala \
	chart-settings-dialog.vala \
	coefficient-treeview.vala \
	device-treeview.vala \
	dichannel-treeview.vala \
	dio-viewer.vala \
	dochannel-treeview.vala \
	heidolph-module-box.vala \
	licor-module-box.vala \
	log-treeview.vala \
	log-settings-dialog.vala \
	module-treeview.vala \
	parker-module-box.vala \
	parker-settings-box.vala \
	pid-box.vala \
	pid-control-treeview.vala \
	pid-settings-dialog.vala \
	serialport-settings-box.vala \
	utility.vala \
	vchannel-treeview.vala \
	velmex-module-box.vala \
	velmex-settings-box.vala \
	callbacks.c

CLEANFILES = \
	*.stamp \
	stamp-h1 \
	$(srcdir)/libdactl.h
