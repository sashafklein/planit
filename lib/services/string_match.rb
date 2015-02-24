module Services
  class StringMatch

    attr_accessor :main, :target, :main_foreign, :target_foreign
    def initialize(main_string, target_string, parentheses=false)
      target_string = target_string.decode_characters
      @main, @target = [main_string, target_string].map{ |s| parentheses ? s : cut_parentheses(s) }
      @main, @target = [main, target].map{ |s| clean(s) }
      @main_foreign, @target_foreign = [main_string, target_string].map{ |s| foreign_characters(s) }
    end

    def value
      (word_match * word_match_weight) + (string_match * string_match_weight)
    end

    def bidirectional_value
      [value, self.class.new(target, main).value].sum / 2.0      
    end

    private

    def string_match
      if mixed?(main, main_foreign)
        ( non_char_match * percent_non_foreign ) + ( char_match * percent_foreign )
      elsif all_foreign?(main, main_foreign)
        char_match
      else # no foreign
        non_char_match
      end
    end

    def char_match
      return 0 unless target_foreign.present?
      (main_foreign.chars & target_foreign.chars).length / target_foreign.length.to_f
    end

    def non_char_match
      (main.match_distance( target ) )
    end

    def percent_non_foreign
      total = (target.length + target_foreign.length)
      return 0 unless total
      target.length / total.to_f
    end

    def percent_foreign
      1.0 - percent_non_foreign
    end

    def word_match
      return 1.0 if words( target ).length <= 1
      matched_words.count / words( target ).count.to_f
    end

    def string_match_weight
      1 - word_match_weight
    end

    def word_match_weight
      case words( target ).length
      when 0 then 0
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
        .chars.select{ |c| c.no_accents(replacement: 'failed') != 'failed' }.join("").no_accents.gsub(/\s\s+/, ' ').strip
    end

    def matched_words
      words( target ) & words( main )
    end

    def foreign_characters(string)
      string.chars.select{ |c| c.no_accents(replacement: 'foreign') == 'foreign' }.join("")
    end

    def mixed?(string, chars)
      chars.length > 0 && string.length > 0
    end

    def all_foreign?(string, chars)
      string.length == 0 && chars.length > 0
    end
  end
end