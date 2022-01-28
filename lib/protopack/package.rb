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
  rescue
    raise "installing missing from package #{name}"
  end

  def apply_all
    items = sorted_items
    items = items.select { |i| yield i } if block_given?
    items.each(&:apply!)
  rescue
    raise "installing all from package #{name}"
  end

  def sorted_items
    items.sort { |a, b|
      a, b = a.ordinal, b.ordinal
      a ? (b ? a <=> b : -1) : (b ? 1 : 0)
    }
  end
end
