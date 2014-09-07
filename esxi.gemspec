# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'esxi/version'

Gem::Specification.new do |spec|
  spec.name          = "esxi"
  spec.version       = Esxi::VERSION
  spec.authors       = ["Prashanth Rajagopal"]
  spec.email         = ["mail@prashanthr.net"]
  spec.summary       = %q{Essential interaction with ESXI}
  spec.description   = %q{A simple gem written to solve only once purpose - Interact with ESXI}
  spec.homepage      = "http://github.com/prashanthrajagopal/esxi"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency 'rake', '~> 10.3'
  spec.add_runtime_dependency 'net-ssh', '~> 2.7'
end
