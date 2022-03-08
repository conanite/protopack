class Protopack::Repository < Aduki::Initializable
  attr_accessor :name
  attr_accessor :repo
  attr_accessor :home

  def update path, logger
    local  = File.join(path, name)
    exists = File.exists? local

    if exists
      logger.info "repo exists : #{local} : pull+checkout in #{local}"
      `cd #{local} ; git pull ; git checkout master`
    else
      logger.info "new repo : #{local} : cloning under #{path}"
      `cd #{path} ; git clone #{repo} ; cd #{name} ; git checkout master`
    end
  end

  def status path, logger
    local  = File.join(path, name)
    exists = File.exists? local

    if exists
      logger.info "repo exists : #{local}"
      `cd #{local} ; git status --porcelain`
    else
      logger.info "***** no such repo : #{local} *****"
    end
  end
end
