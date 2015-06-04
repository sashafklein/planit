class String

  include RegexLibrary
  require 'fuzzystringmatch'

  LONG_DASH = '–'
  
  def eq(string_or_sym)
    self == string_or_sym.to_s
  end

  def no_accents(replacement: '')
    I18n.transliterate(self, replacement: replacement)
  end

  def cut(*substrings)
    base = dup
    subs = substrings.first.is_a?(Array) ? substrings.first : substrings
    
    subs.each do |substring|
      base = base.gsub(substring.to_s, '')
    end
    base
  end

  def cut_words(*words)
    base = dup
    words = words.first.is_a?(Array) ? words.first : words

    words.each{ |w| base = base.gsub(%r{(\s|^)+#{w}(\s|$)}) { ($1.length > 0 && $2.length > 0) ? ' ' : '' } }
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

  def without_articles(articles: nil, keep_first_word: false)
    articles ||= %w(the la el las les los le o os il gli o os der die de du ang da nan an a)

    split(" ").each_with_index.reject do |w, i| 
      articles.include?(w.downcase) && !(keep_first_word && i == 0)
    end.map(&:first).join(" ")
  end

  def without_common_symbols
    cut( %w( & # * , ; . - ' " * ^ % ¡ ! ¿ ? @ | + / \ $ = _ [ ] ′ ″ ‴ ° ` ~ ‘ ) + ['(', ')'] )
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

  def encoded_characters?
    include?("&#")
  end

  def decode_characters
    gsub(/[&][#](\d*)[;]/) { |s| $1.to_i.chr }
  end
end
