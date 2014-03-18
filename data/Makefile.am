SUBDIRS = \
	config \
	icons \
	mime \
	schemas \
	ui

desktopdir = $(datadir)/applications
desktop_in_files = dactl.desktop.in
desktop_DATA = $(desktop_in_files:.desktop.in=.desktop)

gresource_file = dactl.gresource.xml
resource_files = $(shell $(GLIB_COMPILE_RESOURCES) --generate-dependencies $(gresource_file))

CLEANFILES = \
	$(desktop_DATA)

EXTRA_DIST = \
	$(gresource_file) \
	$(resource_files) \
	$(desktop_in_files)

# This should be fixed to use variables that can be set for the user and group
# when ./configure is run, perhaps --with-conf-user and --with-conf-group

install-data-hook:
	chown -R crdc.$(id -gn crdc) $(sysconfdir)/@PACKAGE@ && \
	chmod -R g+w $(sysconfdir)/@PACKAGE@ && \
	chmod +x $(desktopdir)/@PACKAGE@.desktop
