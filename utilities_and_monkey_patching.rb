# Adding `present?` instance method to classes
class NilClass
  def present?
    return false
  end
end

class String
  def present?
    empty? ? false : true
  end
end