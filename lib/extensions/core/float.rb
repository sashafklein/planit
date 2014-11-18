class Float
  def points_of_similarity(other)
    [decimals, other.decimals].min.downto(0).each do |rounder|
      return rounder if round(rounder) == other.round(rounder)
    end
    0
  end

  def decimals
    to_s.split('.')[1].length
  end
end