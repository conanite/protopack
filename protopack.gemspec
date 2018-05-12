# -*- coding: utf-8; mode: ruby  -*-

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'protopack/version'

Gem::Specification.new do |gem|
  gem.name          = "protopack"
  gem.version       = Protopack::VERSION
  gem.authors       = ["Conan Dalton"]
  gem.license       = 'MIT'
  gem.email         = ["conan@conandalton.net"]
  gem.description   = %q{ Create objects from object definitions stored as files, like test fixtures, only intended for production use. }
  gem.summary       = %q{ Store packages of object prototypes on-disk as YML; this gem allows you scan each package for missing items and apply them to your repository. }
  gem.homepage      = "https://github.com/conanite/protopack"

  gem.add_dependency             'hashie'
  gem.add_dependency             'aduki', '~> 0.2.6', '>= 0.2.6'
  gem.add_development_dependency 'rspec', '~> 2.9'

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
end
