class String

  include RegexLibrary
  require 'fuzzystringmatch'

  def no_accents
    I18n.transliterate(self)
  end

  def cut(*substrings)
    base = self
    Array(substrings).each do |substring|
      base = base.gsub(substring.to_s, '')
    end
    base
  end

  def match_distance(string)
    return nil if string.non_latinate? || self.non_latinate?
    algorithm = FuzzyStringMatch::JaroWinkler.create( :native )
    algorithm.getDistance( self.no_accents, string.no_accents )
  end

  def non_latinate?
    %r!#{non_latinate_or_punctuation_or_space_thread}!.match(self)
  end
end
