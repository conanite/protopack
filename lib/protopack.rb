require "yaml"
require "aduki"
require "protopack/version"
require "protopack/repository"
require "protopack/config"
require "protopack/depends"
require "protopack/package"
require "protopack/package_item"
require "protopack/styled_yaml"
require "protopack/exporter"

module Protopack
  RUBY2 = (RUBY_VERSION =~ /^2\./)

  if RUBY2
    def self.yaml_read txt ; YAML.load(txt) ; end
  else
    def self.yaml_read txt ; YAML.load(txt, permitted_classes: [Time, Date, Symbol]) ; end
  end
end
