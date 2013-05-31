## MIMEFILES = dactl.xml.in

mimexmldir = $(datadir)/mime/packages
mimexml_DATA = dactl.xml

## See tabler for original example that includes i18n
## @INTLTOOL_XML_RULE@

CLEANFILES = $(mimexml_DATA)

EXTRA_DIST = $(mimexml_DATA)

## Update mime only when system wide installation takes place

install-data-local: install-mimexmlDATA
	if [ -f $(DESTDIR)$(datadir)/mime/packages/freedesktop.org.xml ] ; then \
		if which update-mime-database>/dev/null 2>&1; then \
			update-mime-database $(DESTDIR)$(datadir)/mime; \
		fi \
	fi

uninstall-local:
	if [ -f $(DESTDIR)$(datadir)/mime/packages/freedesktop.org.xml ] ; then \
		if which update-mime-database>/dev/null 2>&1; then \
			update-mime-database $(DESTDIR)$(datadir)/mime; \
		fi \
	fi
