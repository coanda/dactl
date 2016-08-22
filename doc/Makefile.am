if ENABLE_DOC

include Makefile.sphinx

docdir=$(datadir)/devhelp/references/dactl-0.4
innerdocdir=$(datadir)/devhelp/references/dactl-0.4/dactl-0.4
imgdir=$(datadir)/devhelp/references/dactl-0.4/dactl-0.4/img

core_valaflags = \
	--pkg=cld-0.3 \
	--pkg=comedi \
	--pkg=dactl-config \
	--pkg=gee-0.8 \
	--pkg=gmodule-2.0 \
	--pkg=json-glib-1.0 \
	--pkg=libxml-2.0 \
	--pkg=libpeas-1.0

ui_valaflags = \
	--pkg=cairo \
	--pkg=gsl \
	--pkg=gtk+-3.0 \
	--pkg=gtksourceview-3.0 \
	--pkg=librsvg-2.0 \
	--pkg=pango \
	--pkg=webkit2gtk-4.0

net_valaflags = \
	--pkg=libsoup-2.4 \
	--pkg=libzmq

doc_data = \
	dactl-0.4/*.css \
	dactl-0.4/*.png \
	$(NULL)

doc_DATA = \
	dactl-0.4/index.html \
	$(doc_data) \
	$(NULL)

innerdoc_DATA = \
	dactl-0.4/dactl-0.4/index.htm \
	dactl-0.4/dactl-0.4/*.html \
	$(NULL)

img_DATA = \
	dactl-0.4/dactl-0.4/*.png \
	$(NULL)

$(doc_data) $(innerdoc_DATA) $(img_DATA): dactl-0.4/index.html

dactl-0.4/index.html:
	$(VALADOC) -o dactl-0.4/ --wiki ./ --target-glib=2.44 \
		--force -b $(top_srcdir) \
		$(top_srcdir)/src/libdactl-core/*.vala \
		$(top_srcdir)/src/libdactl-ui/*.vala \
		$(top_srcdir)/src/libdactl-cli/*.vala \
		$(top_srcdir)/src/libdactl-daq/*.vala \
		$(top_srcdir)/src/libdactl-log/*.vala \
		$(top_srcdir)/src/libdactl-net/*.vala \
		--pkg=linux \
		--pkg=posix \
		$(core_valaflags) \
		$(ui_valaflags) \
		$(net_valaflags) \
		--vapidir=$(top_srcdir)/src/libdactl-core \
		--vapidir=$(top_srcdir)/vapi

EXTRA_DIST = \
	index.wiki \
	$(NULL)

endif

GITIGNOREFILES = \
	build \
	dactl-0.4 \
	$(NULL)

-include $(top_srcdir)/git.mk
