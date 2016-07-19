CLEANFILES =
DISTCLEANFILES =
BUILT_SOURCES =
EXTRA_DIST =

BUILT_SOURCES += \
	dactl-daq.service \
	dactl-log.service \
	dactl-ctl.service \
	$(NULL)

EXTRA_DIST += \
	dactl-daq.service.in \
	dactl-log.service.in \
	dactl-ctl.service.in \
	$(NULL)

edit = sed \
	-e 's|@bindir[@]|$(bindir)|g' \
	-e 's|@sbindir[@]|$(sbindir)|g' \
	-e 's|@sysconfdir[@]|$(sysconfdir)|g'

dactl-daq.service: dactl-daq.service.in
	$(edit) $< >$@

dactl-log.service: dactl-log.service.in
	$(edit) $< >$@

dactl-ctl.service: dactl-ctl.service.in
	$(edit) $< >$@

install-service: install-sysconfig
	$(MKDIR_P) $(DESTDIR)$(SYSTEMD_UNITDIR)
	$(INSTALL_DATA) dactl-daq.service $(DESTDIR)$(SYSTEMD_UNITDIR)/dactl-daq.service
	$(INSTALL_DATA) dactl-log.service $(DESTDIR)$(SYSTEMD_UNITDIR)/dactl-log.service
	$(INSTALL_DATA) dactl-ctl.service $(DESTDIR)$(SYSTEMD_UNITDIR)/dactl-ctl.service

uninstall-service: uninstall-sysconfig
	rm -f $(DESTDIR)$(SYSTEMD_UNITDIR)/dactl-daq.service
	rm -f $(DESTDIR)$(SYSTEMD_UNITDIR)/dactl-log.service
	rm -f $(DESTDIR)$(SYSTEMD_UNITDIR)/dactl-ctl.service
	rmdir $(DESTDIR)$(SYSTEMD_UNITDIR) || :

-include $(top_srcdir)/git.mk
