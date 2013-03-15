require "rubygems"
require "bundler"

Bundler.setup
Bundler.require
require File.expand_path('../../lib/protopack', __FILE__)

# This file was generated by the `rspec --init` command. Conventionally, all
# specs live under a `spec` directory, which RSpec adds to the `$LOAD_PATH`.
# Require this file using `require "spec_helper"` to ensure that it is only
# loaded once.
#
# See http://rubydoc.info/gems/rspec-core/RSpec/Core/Configuration
RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.run_all_when_everything_filtered = true
  config.filter_run :focus

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = 'random'
end

class Widget
  @@widgets = []

  def self.all
    @@widgets
  end

  def self.destroy_all
    @@widgets = []
  end

  def initialize attrs
    @attrs = attrs.is_a?(Hash) ? Hashie::Mash.new(attrs) : attrs
    @@widgets << self
  end

  def method_missing m, *args
    @attrs.send m, *args
  end

  def update_attributes attrs
    @attrs = attrs
  end

  def self.existence attrs
    WidgetRepository.new attrs.colour
  end
end

class WidgetRepository
  def initialize name
    @name = name
  end

  def create! attributes
    Widget.new(attributes)
  end

  def matches
    Widget.all.select { |w| w.colour == @name }
  end

  def empty?
    matches.empty?
  end

  def first
    matches.first
  end
end
