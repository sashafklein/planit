module JsonFunctions

  def get_parseable_hash(from_first_bracket)
    @open = 0
    from_first_bracket[0] = '' # remove first bracket
    inside = from_first_bracket.split("").select{ |letter| in_hash?(letter) }.join()
    "{" + inside + "}"
  end

  def in_hash?(letter)
    @open = @open + 1 if letter.include?("{") && @open >= 0
    @open = @open - 1 if letter.include?("}") && @open >= 0
    return letter if @open >= 0
    return nil
  end

end