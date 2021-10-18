class Protopack::Depends < Aduki::Initializable
  attr_accessor :package
  # override this to provide custom dependency management
  # true : the package is unconditionally allowed
  # falsy : the package is not allowed for unspecified reasons
  # String or [String, ...] : the package is not allowed for the given reason(s)
  def allowed?
    true
  end
end
