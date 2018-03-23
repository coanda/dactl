# Example taken from: https://github.com/gregier/libpeas/tree/master/peas-demo

import gi
gi.require_version('Gtk', '3.0')
gi.require_version('Peas', '1.0')
gi.require_version('PeasGtk', '1.0')
gi.require_version('DactlCore', '0.4')
gi.require_version('DactlUI', '0.4')
from gi.repository import GObject
from gi.repository import Gtk
from gi.repository import Peas
from gi.repository import PeasGtk
from gi.repository import DactlCore
from gi.repository import DactlUI

LABEL_STRING="Python Plugin Sample"

class PyHelloPlugin(GObject.Object, Peas.Activatable):
    __gtype_name__ = 'PythonPlugin'

    # view = GObject.Property(type=DactlCore.ApplicationView)
    object = GObject.property(type=GObject.Object)

    def do_activate(self):
        print("PyHelloPlugin.do_activate")
        self.button = Gtk.Button(label="Quit")
        self.button.connect("clicked", Gtk.main_quit)
        self.object.view.add(self.button)
        self.button.show()
        # window._pyhello_label = Gtk.Label()
        # window._pyhello_label.set_text(LABEL_STRING)
        # window._pyhello_label.show()
        # window.get_child().pack_start(window._pyhello_label, True, True, 0)

    def do_deactivate(self):
        print("PyHelloPlugin.do_deactivate")
        self.view.remove(self.button)
        # window.get_child().remove(window._pyhello_label)
        # window._pyhello_label.destroy()

    def do_update_state(self):
        print("PyHelloPlugin.do_update_state")

class PyHelloConfigurable(GObject.Object, PeasGtk.Configurable):
    __gtype_name__ = 'PyHelloConfigurable'

    def do_create_configure_widget(self):
        return Gtk.Label.new("Python Hello configure widget")
