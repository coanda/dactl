SUBDIRS = \
	config \
	icons \
	mime \
	schemas

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
