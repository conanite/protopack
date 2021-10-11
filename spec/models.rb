require 'aduki'

class Object
  def blank?
    false
  end
end

class String
  def blank?
    strip == ''
  end
end

class NilClass
  def blank?
    true
  end
end

class Hash
  def deep_merge other
    merge other
  end
end

class Repository
  def initialize klass, name
    @klass, @name = klass, name
  end

  def create! attributes
    @klass.new(attributes)
  end

  def matches
    @klass.all.select { |w| w.colour == @name }
  end

  def empty?
    matches.empty?
  end

  def first
    matches.first
  end
end

class Widget < Aduki::Initializable
  @@widgets = []

  attr_accessor :wots, :colour, :height, :density, :name, :description

  def self.all
    @@widgets
  end

  def self.destroy_all
    @@widgets = []
  end

  def aduki_after_initialize
    @@widgets << self
  end

  def protopack_export_config
    { fields:        [:colour, :height, :density, :name ],
      associations:  [{ get: :mywots, set: :newwots }],
      resources:     %i{ description } }
  end

  def resource_extension_for field
    :html
  end

  def slice *names
    Hash[*(names.zip(names.map { |n| send n }).flatten)]
  end

  def mywots
    self.wots
  end

  def newwots= wots_attrs
    self.wots = wots_attrs.map { |a| Wot::Zit.new a }
  end

  def update_attributes attrs
    aduki_apply_attributes attrs
  end

  def self.existence attrs
    Repository.new Widget, attrs["colour"]
  end
end

module Wot
  class Zit < Aduki::Initializable
    @@wotzits = []

    attr_accessor :colour, :height, :density, :name

    def self.all
      @@wotzits
    end

    def self.destroy_all
      @@wotzits = []
    end

    def aduki_after_initialize
      @@wotzits << self
    end

    def protopack_export_config
      { fields: [:colour, :height, :density, :name ], associations: [] }
    end

    def slice *names
      Hash[*(names.zip(names.map { |n| send n }).flatten)]
    end

    def update_attributes attrs
      aduki_apply_attributes attrs
    end

    def self.existence attrs
      Repository.new Wot::Zit, attrs["colour"]
    end
  end
end
