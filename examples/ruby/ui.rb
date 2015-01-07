#!/usr/bin/env ruby

require 'gir_ffi'
require 'gir_ffi-gtk3'

GirFFI.setup :Cld
GirFFI.setup :DactlUI

# load the CLD configuration
config = Cld::XmlConfig.with_file_name('examples/cld.xml')
context = Cld::Context.from_config(config)

chan = context.get_object('ai0')

dev = context.get_object('dev0')
dev.open
if !dev.is_open
  puts("Opening device #{dev.id} failed")
end
#task = context.get_object('tk0')
#task.run

Gtk.init

win = Gtk::Window.new :toplevel
win.show
win.signal_connect('destroy') { Gtk.main_quit }

aictl = DactlUI::AIControl.new('/daqctl0/dev0/ai0')
aictl.signal_connect('request_object') { aictl.offer_cld_object (chan) }
win.add(aictl)

Gtk.main

dev.close
