include $(top_srcdir)/common.am

if ENABLE_WEBKIT

EXTRA_DIST = $(extensions_DATA)

extensionsdir = $(libdir)/dactl/extensions
extensions_LTLIBRARIES = libdactl-ui-extension-dom.la

BUILT_SOURCES = libdactl_ui_extension_dom_la_vala.stamp

libdactl_ui_extension_dom_la_vala.stamp: $(libdactl_ui_extension_dom_la_VALASOURCES)
	$(AM_V_GEN)$(VALAC) \
		$(libdactl_ui_extension_dom_la_VALAFLAGS) \
		$(addprefix $(srcdir)/,$(libdactl_ui_extension_dom_la_VALASOURCES)) \
		--ccode \
		&& touch $@

libdactl_ui_extension_dom_la_VALASOURCES = \
	dactl-ui-extension-dom.vala \
	$(NULL)

EXTRA_DIST += $(libdactl_ui_extension_dom_la_VALASOURCES)

nodist_libdactl_ui_extension_dom_la_SOURCES = \
	dactl-ui-extension-dom.c \
	$(NULL)

CLEANFILES = $(BUILT_SOURCES) $(nodist_libdactl_ui_extension_dom_la_SOURCES)

libdactl_ui_extension_dom_la_VALAFLAGS = \
	--vapidir=$(top_srcdir)/vapi \
	--pkg webkit2gtk-web-extension-4.0 \
	--pkg javascriptcoregtk-3.0 \
	$(NULL)

libdactl_ui_extension_dom_la_CFLAGS = \
	-DG_LOG_DOMAIN=\"libdactl-ui-extension-dom\" \
	-DGETTEXT_PACKAGE=\"dactl\" \
	$(WEBKIT_CFLAGS) \
	$(NULL)

libdactl_ui_extension_dom_la_LIBADD = $(WEBKIT_LIBS)
libdactl_ui_extension_dom_la_LDFLAGS = -module -avoid-version -no-undefined

endif

-include $(top_srcdir)/git.mk
