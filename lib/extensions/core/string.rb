class String

  include RegexLibrary
  require 'fuzzystringmatch'

  LONG_DASH = '–'
  
  def no_accents
    I18n.transliterate(self)
  end

  def cut(*substrings)
    base = dup
    subs = substrings.first.is_a?(Array) ? substrings.first : substrings
    
    subs.each do |substring|
      base = base.gsub(substring.to_s, '')
    end
    base
  end

  def match_distance(string)
    return nil if non_latinate? || string.nil? || string.non_latinate?
    algorithm = FuzzyStringMatch::JaroWinkler.create( :native )
    algorithm.getDistance( self.no_accents, string.no_accents )
  end

  def non_latinate?
    !latinate?
  end

  def latinate?
    !(%r!#{non_latinate_or_punctuation_or_space_thread}!.match(self))
  end

  def without_articles(articles=nil)
    articles ||= %w(the la el las les los le o os il gli o os der die de du ang da nan an)

    split(" ").reject{ |w| articles.include?(w.downcase) }.join(" ")
  end

  def without_common_symbols
    cut %w(& # * , ; . ' " * ^ % ! @ )
  end

  def capitalized?
    chars.first == chars.first.upcase
  end

  def nuanced_titleize
    articles = %w(the and to a an of if)
    all_caps = %(bbq)

    split(" ").each_with_index.map do |w, i| 
      w = w.downcase
      if all_caps.include?(w)
        w.upcase
      else
        !articles.include?(w) || i == 0 ? w.capitalize : w
      end
    end.join(" ")
  end
end
