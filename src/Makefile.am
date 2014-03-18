SUBDIRS = libdactl-core

# this is stupid, dactl is a graphical program only now, remove
if BUILD_UI
SUBDIRS += libdactl-ui
endif

SUBDIRS += dactl plugins

MAINTAINERCLEANFILES = Makefile.in

vala-clean:
	rm -f `find . -name "*.stamp"`
