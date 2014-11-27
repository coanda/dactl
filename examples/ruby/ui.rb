#!/usr/bin/env ruby

require 'xml'
require 'gir_ffi'
require 'gir_ffi-gtk3'

GirFFI.setup :Cld
GirFFI.setup :DactlUI

class MyAIControl < DactlUI::AIControl
  def initiate(xml)
    @xml = xml
    from_xml_node(xml)
  end
end

config = Cld::XmlConfig.with_file_name('examples/cld.xml')
context = Cld::Context.from_config(config)
chan = context.get_object('ai0')

Gtk.init

win = Gtk::Window.new :toplevel
win.show
win.signal_connect('destroy') { Gtk.main_quit }

xml = XML::Node.new('object')
XML::Attr.new(xml, 'id', 'ai-ctl0')
XML::Attr.new(xml, 'type', 'ai')
XML::Attr.new(xml, 'ref', '/ctr0/ai0')

aictl = MyAIControl.new(xml)
aictl.signal_connect('request_object') { aictl.offer_cld_object (chan) }
win.add(aictl)

Gtk.main
