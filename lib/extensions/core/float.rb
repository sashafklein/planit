class Float
  def points_of_similarity(other)
    return 0 unless to_i == other.to_i
    dist, counter = "%1.12f" % (self - other).abs.round(10).to_s, 0
    decimal_string = dist.split('.')[1].ljust(10, '0')

    decimal_string.split('').each{ |char| if char == '0' then counter += 1 else break end }
    counter
  end

  def decimals
    to_s.split('.')[1].length
  end
end