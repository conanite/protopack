class Protopack::Package
  attr_reader :config

  def method_missing m, *args
    config.send m, *args
  end

  def initialize cfg
    @config = (cfg.is_a?(Hashie::Mash) ? cfg : Hashie::Mash.new(cfg))
  end

  def items
    config.items.map { |item_file|
      Protopack::PackageItem.new(Hashie::Mash.new(YAML.load(File.read(item_file))))
    }
  end

  def item id
    items.each do |item|
      return item if (item.id == id)
    end
  end

  def apply_missing
    sorted_items.select(&:missing?).each &:apply!
  end

  def apply_all
    sorted_items.each &:apply!
  end

  def sorted_items
    items.sort { |a, b|
      a, b = a.ordinal, b.ordinal
      a ? (b ? a <=> b : -1) : (b ? 1 : 0)
    }
  end

  def self.config_root= root
    @@config_root = root
  end

  def self.config_root
    @@config_root
  end

  def self.all
    Dir.glob("#{config_root}/*/package-config.yml").map { |pkg_cfg|
      cfg = Hashie::Mash.new(YAML.load(File.read(pkg_cfg)))
      root = File.dirname pkg_cfg
      cfg["items"] = Dir.glob("#{root}/*item*.yml")
      cfg["root"] = root
      new cfg
    }
  end

  def self.find name
    root = "#{config_root}/#{name}"
    cfg = Hashie::Mash.new(YAML.load(File.read("#{root}/package-config.yml")))
    cfg["items"] = Dir.glob("#{root}/*item*.yml")
    cfg["root"] = root
    new cfg
  end
end
