if ENABLE_PYTHON_PLUGIN

EXTRA_DIST = \
	$(plugin_DATA) \
	pyhello.plugin.in

plugindir = $(libdir)/dactl/plugins
dist_plugin_DATA = \
	pyhello.py \
	pyhello.plugin

endif

-include $(top_srcdir)/git.mk
