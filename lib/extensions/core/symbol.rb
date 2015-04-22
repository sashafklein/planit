class Symbol
  def eq(string_or_sym)
    self == string_or_sym.to_sym
  end
end