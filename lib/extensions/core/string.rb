class String

  include RegexLibrary
  require 'fuzzystringmatch'

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
    return nil if self.non_latinate? || string.non_latinate?
    algorithm = FuzzyStringMatch::JaroWinkler.create( :native )
    algorithm.getDistance( self.no_accents, string.no_accents )
  end

  def non_latinate?
    %r!#{non_latinate_or_punctuation_or_space_thread}!.match(self)
  end

  def without_articles(articles= %w(the an a) )
    split(" ").reject{ |w| articles.include?(w.downcase) }.join(" ")
  end

  def without_common_symbols
    cut %w(& # * , ; . ' " * ^ % ! @  )
  end

  def capitalized?
    chars.first == chars.first.upcase
  end
end
