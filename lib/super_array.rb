class SuperArray < Array

  include SuperBase

  def initialize(array=[])
    array.each_with_index do |v, i|
      self[i] = v.is_a_or_h? ? v.to_super : v
    end

    self
  end

  def to_a
    super.map do |e|
      e.is_a_or_h? ? e.try(:to_normal) || e : e
    end
  end
end