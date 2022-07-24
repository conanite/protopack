class Protopack::Depends < Aduki::Initializable
  attr_accessor :package
  # override this to provide custom dependency management
  # true : the package is unconditionally allowed
  # falsy : the package is not allowed for unspecified reasons
  def allowed?
    true
  end

  # array of reasons why this dependency failed, if it failed
  def why_not?
    []
  end
end
