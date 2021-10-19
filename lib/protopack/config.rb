class Protopack::Config < Aduki::Initializable
  attr_accessor :root
  aduki repositories: Protopack::Repository

  def load_package base
    return unless File.exist? "#{base}/package-config.yml"
    cfg = YAML.load(File.read("#{base}/package-config.yml"))
    content_dir = File.join base, "content"
    if File.exist?(content_dir)
      cfg["item_files"] = Dir.glob("#{content_dir}/*.yml")
    else
      cfg["item_files"] = Dir.glob("#{base}/*item*.yml")
    end
    cfg["root"] = base
    cfg["depends"] ||= Protopack::Depends.new
    pkg = Protopack::Package.new cfg
    pkg.depends.package = pkg
    pkg
  end

  def all
    Dir.glob("#{root}/*").map { |dir| load_package dir }.compact
  end

  def find name
    load_package "#{root}/#{name}"
  end

  def update_repositories logger=nil
    logger ||= Logger.new($stdout)
    repositories.each { |repo| repo.update(root, logger) }
  end
end
