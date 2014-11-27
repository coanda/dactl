#!/usr/bin/env ruby

require 'xml'
require 'gir_ffi'

#GirFFI.setup :DactlUI

xml = XML::Node.new('object')
XML::Attr.new(xml, 'id', 'ai-ctl0')
XML::Attr.new(xml, 'type', 'ai')
XML::Attr.new(xml, 'ref', '/ctr0/ai0')

puts xml.to_s

#aictl = MyAIControl.new(xml)
#aictl.signal_connect('request_object') { aictl.offer_cld_object (chan) }
