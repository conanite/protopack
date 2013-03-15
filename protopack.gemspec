# -*- coding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'protopack/version'

Gem::Specification.new do |gem|
  gem.name          = "protopack"
  gem.version       = Protopack::VERSION
  gem.authors       = ["conanite"]
  gem.email         = ["conan@conandalton.net"]
  gem.description   = %q{Create objects from object definitions stored as files}
  gem.summary       = %q{Store packages of object prototypes on-disk as YML; this gem allows you scan each package for missing items and apply them to your repository.}
  gem.homepage      = ""

  gem.add_dependency             'hashie'
  gem.add_development_dependency 'rspec', '~> 2.9'

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
end
