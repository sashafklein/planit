module Services
  class StringMatch

    attr_accessor :main, :target
    def initialize(main_string, target_string, parentheses=false)
      @main, @target = [main_string, target_string].map{ |s| parentheses ? s : cut_parentheses(s) }
      @main, @target = [main, target].map{ |s| clean(s) }
    end

    def value
      (word_match * word_match_weight) + (string_match * string_match_weight)
    end

    private

    def string_match
      main.match_distance( target )
    end

    def word_match
      return 1 if words( target ).length == 1
      matched_words.count / words( target ).count.to_f
    end

    def string_match_weight
      1 - word_match_weight
    end

    def word_match_weight
      case words( target ).length
      when 1 then 0
      when 2 then 0.4
      when 3 then 0.5
      else 0.6
      end
    end

    def cut_parentheses(string)
      string.gsub(/\(.*\)/, '').strip
    end

    def one_word?(string)
      words( string ).length == 1
    end

    def words(string)
      string.split(" ")
    end

    def clean(string)
      string.to_s.downcase.without_articles.without_common_symbols
        .chars.select{ |c| c.no_accents(replacement: 'failed') != 'failed' }.join("").gsub(/\s\s+/, ' ')
    end

    def matched_words
      words( target ) & words( main )
    end
  end
end