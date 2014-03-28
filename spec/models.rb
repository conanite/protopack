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
    @attrs[m.to_s]
  end

  def update_attributes attrs
    @attrs = attrs
  end

  def self.existence attrs
    Repository.new Widget, attrs.colour
  end
end

module Wot
  class Zit
    @@wotzits = []

    def self.all
      @@wotzits
    end

    def self.destroy_all
      @@wotzits = []
    end

    def initialize attrs
      @attrs = attrs.is_a?(Hash) ? Hashie::Mash.new(attrs) : attrs
      @@wotzits << self
    end

    def method_missing m, *args
      @attrs.send m, *args
    end

    def update_attributes attrs
      @attrs = attrs
    end

    def self.existence attrs
      Repository.new Wot::Zit, attrs.colour
    end
  end
end
