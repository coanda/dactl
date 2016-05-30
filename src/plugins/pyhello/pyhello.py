# Example taken from: https://github.com/gregier/libpeas/tree/master/peas-demo

from gi.repository import GObject
from gi.repository import Peas
from gi.repository import PeasGtk
from gi.repository import Gtk

LABEL_STRING="Python Says Hello!"

class PyHelloPlugin(GObject.Object, Peas.Activatable):
    __gtype_name__ = 'PyHelloPlugin'

    object = GObject.property(type=GObject.Object)

    def do_activate(self):
        print("PyHelloPlugin.do_activate")

    def do_deactivate(self):
        print("PyHelloPlugin.do_deactivate")

    def do_update_state(self):
        print("PyHelloPlugin.do_update_state")

class PyHelloConfigurable(GObject.Object, PeasGtk.Configurable):
    __gtype_name__ = 'PyHelloConfigurable'

    def do_create_configure_widget(self):
        return Gtk.Label.new("Python Hello configure widget")
