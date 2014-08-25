# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'keen/version'

Gem::Specification.new do |spec|
  spec.name          = "keen"
  spec.version       = Keen::VERSION
  spec.authors       = ["Geoff Johnson"]
  spec.email         = ["geoff.jay@gmail.com"]
  spec.description   = %q{Command line tool for interfacing with Dactl and CLD}
  spec.summary       = %q{Commander Keen controls all the data}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"

  spec.add_runtime_dependency "user_config"
  spec.add_runtime_dependency "thor"
  spec.add_runtime_dependency "ruby-dbus"
end
