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

  def is_a_or_h?
    is_a?(Array) || is_a?(Hash)
  end

  def to_class(classname)
    method = "to_#{classname.to_s.chars.first.downcase}"
    respond_to?(method) ? send(method) : self
  end

end