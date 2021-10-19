class Protopack::Repository < Aduki::Initializable
  attr_accessor :name
  attr_accessor :repo
  attr_accessor :home

  def update path, logger
    repo   = File.join(path, name)
    exists = File.exists? repo

    if exists
      logger.info "repo exists : #{repo} : pull+checkout in #{repo}"
      `cd #{repo} ; git pull ; git checkout master`
    else
      logger.info "new repo : #{repo} : cloning under #{path}"
      `cd #{path} ; git clone #{repo} ; cd #{name} ; git checkout master`
    end
  end
end
