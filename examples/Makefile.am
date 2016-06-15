include $(top_srcdir)/common.am

noinst_PROGRAMS = box channel-treeview chart chart-axis page pnid

example_VALAFLAGS = \
	$(DACTL_DEPS_VALAFLAGS) \
	$(DACTL_CLD_DEPS_VALAFLAGS) \
	$(DACTL_UI_DEPS_VALAFLAGS) \
	$(DACTL_COMMON_LIBDACTL_CORE_VALAFLAGS) \
	$(DACTL_COMMON_LIBDACTL_UI_VALAFLAGS) \
	$(DACTL_COMMON_VALAFLAGS)

example_CFLAGS = \
	$(DACTL_DEPS_CFLAGS) \
	$(DACTL_CLD_DEPS_CFLAGS) \
	$(DACTL_UI_DEPS_CFLAGS) \
	$(DACTL_COMMON_LIBDACTL_CORE_CFLAGS) \
	$(DACTL_COMMON_LIBDACTL_UI_CFLAGS)

example_LDADD = \
	$(DACTL_DEPS_LIBS) \
	$(DACTL_CLD_DEPS_LIBS) \
	$(DACTL_UI_DEPS_LIBS) \
	$(DACTL_COMMON_LIBDACTL_CORE_LIBS) \
	$(DACTL_COMMON_LIBDACTL_UI_LIBS)

if ENABLE_WEBKIT
example_VALAFLAGS += --pkg webkit2gtk-4.0
example_CFLAGS += $(WEBKIT_CFLAGS)
example_LDADD += $(WEBKIT_LIBS)
endif

box_SOURCES = box.vala
box_DEPENDENCIES = $(example_DEPENDENCIES)
box_VALAFLAGS = $(example_VALAFLAGS)
box_CPPFLAGS = $(example_CFLAGS)
box_LDADD = $(example_LDADD)

channel_treeview_SOURCES = channel-treeview.vala
channel_treeview_DEPENDENCIES = $(example_DEPENDENCIES)
channel_treeview_VALAFLAGS = $(example_VALAFLAGS)
channel_treeview_CPPFLAGS = $(example_CFLAGS)
channel_treeview_LDADD = $(example_LDADD)

chart_SOURCES = chart.vala
chart_DEPENDENCIES = $(example_DEPENDENCIES)
chart_VALAFLAGS = $(example_VALAFLAGS)
chart_CPPFLAGS = $(example_CFLAGS)
chart_LDADD = $(example_LDADD)

chart_axis_SOURCES = chart-axis.vala
chart_axis_DEPENDENCIES = $(example_DEPENDENCIES)
chart_axis_VALAFLAGS = $(example_VALAFLAGS)
chart_axis_CPPFLAGS = $(example_CFLAGS)
chart_axis_LDADD = $(example_LDADD)

page_SOURCES = pnid.vala
page_DEPENDENCIES = $(example_DEPENDENCIES)
page_VALAFLAGS = $(example_VALAFLAGS)
page_CPPFLAGS = $(example_CFLAGS)
page_LDADD = $(example_LDADD)

pnid_SOURCES = pnid.vala
pnid_DEPENDENCIES = $(example_DEPENDENCIES)
pnid_VALAFLAGS = $(example_VALAFLAGS)
pnid_CPPFLAGS = $(example_CFLAGS)
pnid_LDADD = $(example_LDADD)

-include $(top_srcdir)/git.mk
