SUBDIRS = build src

templatefiles = \
	autogen.sh.jnj \
	configure.ac.jnj \
	README.md.jnj

commontemplatedir = $(datadir)/@PACKAGE@/templates/common
commontemplate_DATA = \
	__git.mk \
	__Makefile.am \
	$(templatefiles)

-include $(top_srcdir)/git.mk
