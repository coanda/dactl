SUBDIRS = \
	config \
	icons \
	schemas \
	ui

desktopdir = $(datadir)/applications
desktop_in_files = dactl.desktop.in
desktop_DATA = $(desktop_in_files:.desktop.in=.desktop)

CLEANFILES = \
	$(desktop_DATA)

EXTRA_DIST = \
	$(desktop_in_files)

# This should be fixed to use variables that can be set for the user and group
# when ./configure is run, perhaps --with-conf-user and --with-conf-group

install-data-hook:
	chown -R gjohn.$(id -gn gjohn) $(sysconfdir)/@PACKAGE@ && \
	chmod -R g+w $(sysconfdir)/@PACKAGE@ && \
	chmod +x $(desktopdir)/@PACKAGE@.desktop
