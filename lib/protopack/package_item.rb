class Protopack::PackageItem < Aduki::Initializable
  attr_accessor :id
  attr_accessor :description
  attr_accessor :locale
  attr_accessor :default_locale
  attr_accessor :type
  attr_accessor :ordinal
  attr_accessor :attributes
  attr_accessor :resources
  attr_accessor :protopack_filename

  def name ; attributes[:name] || attributes["name"] ; end

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

  def load_resources hsh, d = File.dirname(protopack_filename)
    resource_dir = File.join(d, "resources")
    d = File.exist?(resource_dir) ? resource_dir : d
    (resources || {}).inject(hsh) { |hsh, (k, v)|
      hsh[k] = File.read(File.join d, v)
      hsh
    }
  end

  def apply!
    factory = existence
    a       = load_resources(attributes.to_hash)
    if factory.empty?
      factory.create! a
    else
      factory.first.update_attributes a
    end
  end

  def self.load filename
    id = File.basename filename, ".yml"
    Protopack::PackageItem.new(YAML.load(File.read filename).merge(id: id, protopack_filename: filename))
  rescue
    raise "error reading from file #{filename}"
  end
end
