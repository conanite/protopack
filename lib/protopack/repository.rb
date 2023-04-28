class Protopack::Repository < Aduki::Initializable
  attr_accessor :name
  attr_accessor :repo
  attr_accessor :home

  def update path, logger
    local  = File.join(path, name)
    exists = File.exists? local

    cmd = if exists
      "cd #{local} ; git pull ; git checkout master"
    else
      "cd #{path} ; git clone #{repo} ; cd #{name} ; git checkout master"
    end

    logger.info cmd
    logger.info `#{cmd}`
  end

  def status path, logger
    local  = File.join(path, name)
    exists = File.exist? local

    if exists
      logger.info "repo exists : #{local}"
      logger.info `cd #{local} ; git status --porcelain`
    else
      logger.info "***** no such repo : #{local} *****"
    end
  end
end
