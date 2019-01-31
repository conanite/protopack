class Protopack::PackageItem
  attr_reader :config

  def method_missing m, *args
    config.send m, *args
  end

  def initialize cfg
    @config = (cfg.is_a?(Hashie::Mash) ? cfg : Hashie::Mash.new(cfg))
  end

  def name
    attributes.name
  end

  def lookup_class base, list
    base = base.const_get list.shift
    return base if list.empty?
    lookup_class base, list
  end

  def target_class
    lookup_class Kernel, type.split("::")
  end

  def missing?
    existence.empty?
  end

  def existence
    target_class.existence attributes
  end

  def apply!
    factory = existence
    if factory.empty?
      factory.create! attributes.to_hash
    else
      factory.first.update_attributes attributes.to_hash
    end
  end

  def self.load filename
    Protopack::PackageItem.new(Hashie::Mash.new(YAML.load(File.read(filename))))
  rescue
    raise "error reading from file #{filename}"
  end
end
