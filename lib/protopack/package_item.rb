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

  def name ; atrtibutes[:name] ; end

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
    (resources || {}).inject(hsh) { |hsh, (k, v)|
      hsh[k] = File.read(File.join d, v)
      hsh
    }
  end

  def apply!
    factory = existence
    if factory.empty?
      factory.create! load_resources(attributes.to_hash)
    else
      factory.first.update_attributes attributes.to_hash
    end
  end

  def self.load filename
    Protopack::PackageItem.new(YAML.load(File.read(filename)).merge(protopack_filename: filename))
  rescue
    raise "error reading from file #{filename}"
  end
end
