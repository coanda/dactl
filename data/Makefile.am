SUBDIRS = gsettings config glade icons mime systemd templates .

@APPSTREAM_XML_RULES@
@INTLTOOL_XML_RULE@

appstream_in_files = org.coanda.Dactl.appdata.xml.in
appstream_XML = $(appstream_in_files:.xml.in=.xml)

desktopdir = $(datadir)/applications
desktop_in_in_files = org.coanda.Dactl.desktop.in.in
desktop_in_files = org.coanda.Dactl.desktop.in
desktop_DATA = $(desktop_in_files:.desktop.in=.desktop)
@INTLTOOL_DESKTOP_RULE@

# D-Bus service file.
servicedir = $(datadir)/dbus-1/services
service_in_files = org.coanda.Dactl.service.in
service_DATA = $(service_in_files:.service.in=.service)

org.coanda.Dactl.service: org.coanda.Dactl.service.in
	$(AM_V_GEN)	\
		[ -d $(@D) ] || $(mkdir_p) $(@D) ; \
		sed -e "s|\@bindir\@|$(bindir)|" $< > $@.tmp && mv $@.tmp $@

gresource_file = dactl.gresource.xml
resource_files = $(shell $(GLIB_COMPILE_RESOURCES) --generate-dependencies $(gresource_file))

EXTRA_DIST = \
	$(gresource_file) \
	$(resource_files) \
	$(appstream_in_files) \
	$(desktop_in_files) \
	$(service_in_files) \
	$(NULL)

CLEANFILES = \
	$(appstream_XML) \
	$(desktop_DATA) \
	$(desktop_in_files) \
	$(service_DATA) \
	$(NULL)

DISTCLEANFILES = \
	$(desktop_in_files) \
	$(NULL)

desktop-file-validate: $(desktop_DATA)
	for f in $^; do \
		$(DESKTOP_FILE_VALIDATE) $$f; \
	done

check-local: desktop-file-validate

.PHONY: desktop-file-validate

-include $(top_srcdir)/git.mk
