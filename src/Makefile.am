#SUBDIRS = lib

bin_PROGRAMS = dactl

VALAFLAGS = \
	-H $(srcdir)/libdactl.h -C -c --thread \
	--vapidir=$(srcdir)/../vapi -X -g \
	@VALA_PACKAGES@ --pkg callbacks --pkg config --pkg threads

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
	callbacks.h \
	threads.h

dactl_SOURCES = \
	aichannel-treeview.vala \
	aochannel-treeview.vala \
	application-config.vala \
	application-controller.vala \
	application-data.vala \
	application-settings-dialog.vala \
	brabender-module-box.vala\
	calibration-treeview.vala \
	channel-treeview.vala \
	chart-widget.vala \
	coefficient-treeview.vala \
	command-line-interface.vala \
	device-treeview.vala \
	driver-data.vala \
	licor-module-box.vala \
	log-treeview.vala \
	pid-box.vala \
	pid-control-treeview.vala \
	pid-settings-dialog.vala \
	user-interface-data.vala \
	utility.vala \
	velmex-module-box.vala \
	velmex-settings-box.vala \
	main.vala \
	callbacks.c \
	threads.c

CLEANFILES = \
	*.stamp \
	stamp-h1 \
	$(srcdir)/libdactl.h
