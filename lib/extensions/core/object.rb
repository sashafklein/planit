class Object
  
  def to_super
    if self.is_a?(Hash)
      self.to_sh
    elsif self.is_a?(Array)
      self.to_sa
    else
      self
    end
  end

  def is_defined?
    self == false || self.present?
  end

end