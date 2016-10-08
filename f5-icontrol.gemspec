# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'f5/icontrol/version'

Gem::Specification.new do |spec|
  spec.name          = "f5-icontrol"
  spec.version       = F5::Icontrol::VERSION
  spec.authors       = ["Sean Walberg"]
  spec.email         = ["sean@ertw.com"]
  spec.description   = "A gem to manage F5 BigIP devices using the iControl API"
  spec.summary= "A gem to manage F5 BigIP devices using the iControl API"
  spec.homepage      = "https://github.com/swalberg/f5-icontrol"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "savon", "~> 2.0"
  spec.add_dependency "rest-client"
  spec.add_dependency "thor"
  spec.add_dependency "rack", "~> 1.6.4"
  spec.add_dependency "json"

  spec.add_development_dependency "awesome_print"
  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "byebug"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "webmock", "~> 2.1.0"
  spec.add_development_dependency "vcr"
  spec.add_development_dependency "byebug"
end
