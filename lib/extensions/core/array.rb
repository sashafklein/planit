class Array
  def to_sa
    SuperArray.new(self)
  end

  def avg
    sum / length.to_f
  end

end