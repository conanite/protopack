class Protopack::Package < Aduki::Initializable
  attr_accessor :name
  attr_accessor :title
  attr_accessor :description
  attr_accessor :authors
  attr_accessor :item_files
  attr_accessor :root
  aduki updated: Date

  def items
    item_files.map { |item_file| Protopack::PackageItem.load(item_file) }
  end

  def item id
    items.each do |item|
      return item if (item.id == id)
    end
  end

  def apply_missing
    items = sorted_items.select(&:missing?)
    items = items.select { |i| yield i } if block_given?
    items.each(&:apply!)
  end

  def apply_all
    items = sorted_items
    items = items.select { |i| yield i } if block_given?
    items.each(&:apply!)
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
      cfg = YAML.load(File.read(pkg_cfg))
      root = File.dirname pkg_cfg
      cfg["item_files"] = Dir.glob("#{root}/*item*.yml")
      cfg["root"] = root
      new cfg
    }
  end

  def self.find name
    root = "#{config_root}/#{name}"
    cfg = YAML.load(File.read("#{root}/package-config.yml"))
    cfg["item_files"] = Dir.glob("#{root}/*item*.yml")
    cfg["root"] = root
    new cfg
  end
end
