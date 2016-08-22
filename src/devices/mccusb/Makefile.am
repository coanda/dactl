if ENABLE_MCCUSB_DEVICE

EXTRA_DIST = $(plugin_DATA)

plugindir = $(libdir)/dactl/devices
plugin_LTLIBRARIES = libdactl-device-mccusb.la
dist_plugin_DATA = mccusb.plugin

BUILT_SOURCES = libdactl_device_mccusb_la_vala.stamp

libdactl_device_mccusb_la_vala.stamp: $(libdactl_device_mccusb_la_VALASOURCES)
	$(AM_V_GEN)$(VALAC) \
		$(libdactl_device_mccusb_la_VALAFLAGS) \
		$(addprefix $(srcdir)/,$(libdactl_device_mccusb_la_VALASOURCES)) \
		--ccode \
		&& touch $@

libdactl_device_mccusb_la_VALASOURCES = \
	dactl-mccusb-device.vala \
	$(NULL)

EXTRA_DIST += $(libdactl_device_mccusb_la_VALASOURCES)

nodist_libdactl_device_mccusb_la_SOURCES = \
	dactl-mccusb-device.c \
	$(NULL)

CLEANFILES = $(BUILT_SOURCES) $(nodist_libdactl_device_mccusb_la_SOURCES)

libdactl_device_mccusb_la_VALAFLAGS = \
	$(DEVICE_VALAFLAGS) \
	$(NULL)

libdactl_device_mccusb_la_CFLAGS = \
	-DVALA_VERSION=\""$(VALA_VERSION)"\" \
	-DPACKAGE_DATADIR=\""$(datadir)/dactl-0.4"\" \
	-DG_LOG_DOMAIN=\"mccusb-device\" \
	-DGETTEXT_PACKAGE=\"dactl\" \
	$(DEVICE_CFLAGS) \
	$(LIBDACTL_DAQ_CFLAGS) \
	-Wno-deprecated-declarations \
	-Wno-discarded-qualifiers \
	-Wno-implicit-function-declaration \
	-Wno-incompatible-pointer-types \
	-Wno-unused-but-set-variable \
	-Wno-unused-label \
	-Wno-unused-function \
	$(NULL)

libdactl_device_mccusb_la_LIBADD = $(DEVICE_LIBS)

libdactl_device_mccusb_la_LDFLAGS = \
	$(DEVICE_LDFLAGS) \
	$(LIBDACTL_DAQ_LDFLAGS) \
	$(NULL)

include $(top_srcdir)/src/devices/Makefile.device

endif

-include $(top_srcdir)/git.mk
