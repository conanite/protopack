class Protopack::Package < Aduki::Initializable
  attr_accessor :name
  attr_accessor :title
  attr_accessor :description
  attr_accessor :authors
  attr_accessor :item_files
  attr_accessor :root
  aduki updated: Date, depends: Protopack::Depends

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

  def self.config= cfg
    @@config = cfg
  end

  def self.config
    @@config
  end

  def self.config_root= root
    @@config_root = root
  end

  def self.config_root
    @@config_root
  end

  def self.load_package root
    return unless File.exist? "#{root}/package-config.yml"
    cfg = YAML.load(File.read("#{root}/package-config.yml"))
    content_dir = File.join root, "content"
    if File.exist?(content_dir)
      cfg["item_files"] = Dir.glob("#{content_dir}/*.yml")
    else
      cfg["item_files"] = Dir.glob("#{root}/*item*.yml")
    end
    cfg["root"] = root
    cfg["depends"] ||= Protopack::Depends.new
    pkg = new cfg
    pkg.depends.package = pkg
    pkg
  end

  def self.all
    Dir.glob("#{config_root}/*").map { |root|
      load_package root
    }.compact
  end

  def self.find name
    load_package "#{config_root}/#{name}"
  end

  def self.update_repositories path, list
    list.each { |info|
      name   = info["name"]
      remote = info["repo"]
      repo   = File.join(path, name)
      exists = File.exists? repo

      if exists
        `cd #{repo} ; git pull ; git checkout master`
      else
        `cd #{path} ; git clone #{remote} ; cd #{name} ; git checkout master`
      end
    }
  end
end
