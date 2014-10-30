module RegexLibrary

    # REGEX COMPONENTS REMEMBER DOUBLE ALL BACKSLASH
    def lowercase_destination_class
      destinations = [
        "bookstore",
        "restaurant",
        "cafe",
        "café",
        "gallery",
        "lounge",
        "hotel",
      ]
      insert = destinations.join("|")
      "(?:#{insert})"
    end
    def quote_thread
      '"'
    end
    def breakline_thread
      "(?:\\<\\/?(?:p|br)(?:\\s[^>]*?)?\\>)"
    end
    def within_broken_whitespace(string)
      "(?:#{breakline_thread}\\s*?#{string}\\s*?#{breakline_thread})"
    end
    def within_whitespace(string)
      "(?:\\s*?#{string}\\s*?)"
    end
    def time_thread
      "(?:\\d?\\d?:?\\d?\\d\\s?[ap]\\.?[m]\\.?)"
    end
    def title_case_st_sta
      "(?:[S][t]\\a?\\.\\s)"
    end
    def title_or_upper_case_word
      "(?:[A-ZÄÀÁÇÈÉëÌÍÖÒÓ][A-ZÄÀÁÇÈÉëÌÍÖÒÓa-zäàáçèéëìíöòó'’]+)"
      # "(?:[A-ZÄÀÁÇÈÉëÌÍÖÒÓ][A-ZÄÀÁÇÈÉëÌÍÖÒÓa-zäàáçèéëìíöòó'’]+)"
    end
    def title_case_word
      "(?:[A-ZÄÀÁÇÈÉëÌÍÖÒÓ][a-zäàáçèéëìíöòó'’]+)"
      # "(?:[A-ZÄÀÁÇÈÉëÌÍÖÒÓ][a-zäàáçèéëìíöòó'’]+)"
    end
    def space_or_dash
      "(?:\\s|\\-\\-?\\-?)"
    end
    def comma_space_or_dash
      "(?:(?:\\,\\s)|\\s|\\-\\-?\\-?)"
    end
    def title_cased_thread
      "(?:(?:#{title_case_st_sta}#{title_case_word}|#{title_case_word})(?:(?:#{comma_space_or_dash}(?:#{title_case_st_sta}#{title_case_word}|#{title_case_word}))+)?)"
      # "(?:[S][t]\\a?\\.\\s)?[A-ZÄÀÁÇÈÉëÌÍÖÒÓ][a-zäàáçèéëìíöòó,']+(?=(?:\\s|\\-?)[A-ZÄÀÁÇÈÉëÌÍÖÒÓ])(?:(?:\\s|\\-?)(?:[S][t]\\a?\.\\s)?[A-ZÄÀÁÇÈÉëÌÍÖÒÓ][a-zäàáçèéëìíöòó',]+)+"
    end
    def title_or_upper_cased_thread
      "(?:(?:#{title_case_st_sta}#{title_or_upper_case_word}|#{title_or_upper_case_word})(?:#{comma_space_or_dash}(?:#{title_case_st_sta}#{title_or_upper_case_word}|#{title_or_upper_case_word}))*)"
      # "(?:(?:#{title_case_st_sta}#{title_or_upper_case_word}|#{title_or_upper_case_word})(?:(?:#{comma_space_or_dash}(?:#{title_case_st_sta}#{title_or_upper_case_word}|#{title_or_upper_case_word}))+)?)"
      # "(?:[S][t]\\a?\\.\\s)?[A-ZÄÀÁÇÈÉëÌÍÖÒÓ][A-ZÄÀÁÇÈÉëÌÍÖÒÓa-zäàáçèéëìíöòó,']+(?=(?:\\s|\\-?)[A-ZÄÀÁÇÈÉëÌÍÖÒÓ])(?:(?:\\s|\\-?)(?:[S][t]\\a?\.\\s)?[A-ZÄÀÁÇÈÉëÌÍÖÒÓ][A-ZÄÀÁÇÈÉëÌÍÖÒÓa-zäàáçèéëìíöòó',]+)+"
    end
    def details_in_parens_thread
      "(?:[^$><#{quote_thread};,]+?(?:[;,]\\s[^;),><#{quote_thread}]+?)?[;,]\\s\\d+[^)]+?)"
    end
    def strong_or_not_thread(string)
      "(?:(?:\\<(?:b|strong)(\\s[^>]*?)?\\>)?\\s*?#{string}\\s*?(?:\\<\\/(?:b|strong)\\>|#{string}))"
    end
    def within_broken_strong_optional(string)
      "(?:#{breakline_thread}#{strong_open_thread}?\\s*?#{string}\\s*?#{strong_close_thread}?#{breakline_thread})"
    end
    def strong_open_thread
      within_whitespace( "(?:\\<(?:b|strong)(?:\\s[^>]*?)?\\>)(?=(?:.|\\n)*?(?:\\<\\/(?:b|strong)\\>))") 
    end
    def strong_close_thread
      within_whitespace( "(?:\\<\\/(?:b|strong)\\>)") 
    end
    def a_href_thread
      "(?:\\<a.*?href\\=\\'[^'#{quote_thread}]*?\\'[^>]*?\\>[^<]*\\<\\/a\\>)"
    end
    def a_find_href_thread
      "(?:\\<a.*?href\\=\\'([^'#{quote_thread}]*?)\\'[^>]*?\\>[^<]*\\<\\/a\\>)"
    end

    # REGEX SAFETY <- CANNOT BE REPEATED * OR + OR ?
    def case_desensitize(string)
      if string.length > 0
        '(?:' + string.upcase + '|' + string.downcase + '|' + string.capitalize + '|' + string.titleize + ')'
      end
    end
    def case_desensitize_array(list)
      item_array = []
      for item in list
        item_array << "#{case_desensitize(item)}"
      end
      insert = "(?:" + item_array.join("|") + ")"
    end
    def tag_free_whitespace
      "(?:(?:\\s*\\\\[n]\\s*)*|\\s*)"
    end
    def any_tags
      "(?:\\<\\/?[^>]*?\\>)*?" 
    end
    def ok_tags
      "(?:\\<\\/?(?:b|strong|a)(?:\\s[^>]*?)?\\>)*?" 
    end
    def ok_tags_space
      "(?:\\s?(?:\\<\\/?(?:b|strong|a)(?:\\s[^>]*?)?\\>)*?\\s?|\\s)*?" 
    end
    def no_tags
      "(?:[^<>])*?" 
    end

    # COMPLETE REGEX DEFINITIONS
    def before_parens_regex_find_name
      %r!\s*(.*?)\s\s?\(!
    end
    def after_parens_regex_find_address
      %r!\((.*?)[,;]\s(?=\d+).*?\)!
    end
    def after_separator_regex_find_phone
      %r!\(.*?[,;]\s((?=\d+).*?)(?:[;,]|\))!
    end
    def time_on_own_line_regex
      %r!#{breakline_thread}#{tag_free_whitespace}#{ok_tags}#{tag_free_whitespace}(?:#{time_thread}|Noon)#{tag_free_whitespace}#{ok_tags}#{tag_free_whitespace}#{breakline_thread}!
    end
    def time_on_own_line_regex_find_time
      %r!#{breakline_thread}#{tag_free_whitespace}#{ok_tags}#{tag_free_whitespace}((?:#{time_thread}|Noon))#{tag_free_whitespace}#{ok_tags}#{tag_free_whitespace}#{breakline_thread}!
    end
    def index_and_title_regex
      %r!#{breakline_thread}#{tag_free_whitespace}#{ok_tags}#{tag_free_whitespace}#{ok_tags}\d+\)#{ok_tags_space}#{ok_tags}#{no_tags}#{ok_tags}\s*#{breakline_thread}!
    end
    def index_and_title_regex_find_title
      %r!#{breakline_thread}#{tag_free_whitespace}#{ok_tags}#{tag_free_whitespace}#{ok_tags}\d+\)#{ok_tags_space}#{ok_tags}\s*(#{no_tags})#{ok_tags}\s*#{breakline_thread}!
    end
    def index_and_title_regex_find_index
      %r!#{breakline_thread}#{tag_free_whitespace}#{ok_tags}#{tag_free_whitespace}#{ok_tags}(\d+)\)#{ok_tags_space}#{ok_tags}#{no_tags}#{ok_tags}\s*#{breakline_thread}!
    end
    def strong_index_title_and_time_on_own_line_regex
      %r!#{breakline_thread}#{strong_open_thread}?\d+#{ok_tags}\.#{ok_tags_space}#{no_tags}#{ok_tags_space}[|]#{ok_tags_space}(?:#{time_thread}|Noon)#{ok_tags_space}#{breakline_thread}!
    end
    def strong_index_title_and_time_on_own_line_regex_find_title
      %r!#{breakline_thread}#{strong_open_thread}?\d+#{ok_tags}\.#{ok_tags_space}\s*(#{no_tags})#{ok_tags_space}[|]#{ok_tags_space}(?:#{time_thread}|Noon)#{ok_tags_space}#{breakline_thread}!
    end
    def strong_index_title_and_time_on_own_line_regex_find_time
      %r!#{breakline_thread}#{strong_open_thread}?\d+#{ok_tags}\.#{ok_tags_space}#{no_tags}#{ok_tags_space}[|]#{ok_tags_space}((?:#{time_thread}|Noon))#{ok_tags_space}#{breakline_thread}!
    end
    def strong_index_title_and_time_on_own_line_regex_find_index
      %r!#{breakline_thread}#{strong_open_thread}?(\d+)#{ok_tags}\.#{ok_tags_space}#{no_tags}#{ok_tags_space}[|]#{ok_tags_space}(?:#{time_thread}|Noon)#{ok_tags_space}#{breakline_thread}!
    end
    def titlecase_before_parens_with_details_regex
      %r!#{ok_tags}#{title_or_upper_cased_thread}\s?#{ok_tags}\s?#{lowercase_destination_class}?#{ok_tags}\s\s?\(#{details_in_parens_thread}\)|\(#{details_in_parens_thread}\)!
    end
    def p_strong_details_regex
      %r!#{breakline_thread}#{strong_open_thread}#{ok_tags}\d+(?:#{ok_tags}\.#{ok_tags_space}and#{ok_tags_space}\d+)?#{ok_tags}\.#{ok_tags}\s#{ok_tags}#{no_tags}[,;|]#{no_tags}#{strong_close_thread}.*?#{breakline_thread}!
    end
    def p_strong_details_double_index_regex
      %r!#{breakline_thread}#{strong_open_thread}#{ok_tags}\d+#{ok_tags}\.#{ok_tags_space}and#{ok_tags_space}\d+#{ok_tags}\.#{ok_tags}\s!
    end
    # def p_strong_details_double_index_regex_find_first
    #   %r!#{breakline_thread}#{strong_open_thread}#{ok_tags}(\d+)#{ok_tags}\.#{ok_tags_space}and#{ok_tags_space}\d+#{ok_tags}\.#{ok_tags}\s!
    # end
    # def p_strong_details_double_index_regex_find_second
    #   %r!#{breakline_thread}#{strong_open_thread}#{ok_tags}\d+#{ok_tags}\.#{ok_tags_space}and#{ok_tags_space}(\d+)#{ok_tags}\.#{ok_tags}\s!
    # end
    def p_strong_details_regex_find_index #first of 2
      %r!#{breakline_thread}#{strong_open_thread}#{ok_tags}(\d+)(?:#{ok_tags}\.#{ok_tags_space}and#{ok_tags_space}\d+)?#{ok_tags}\.#{ok_tags}\s#{ok_tags}#{no_tags}[,;]#{no_tags}#{strong_close_thread}.*?#{breakline_thread}!
    end
    def strong_details_regex_find_activity
      %r!(?:#{strong_open_thread}#{ok_tags}\d+(?:#{ok_tags}\.#{ok_tags_space}and#{ok_tags_space}\d+)?#{ok_tags}\.#{ok_tags}\s#{ok_tags}|#{strong_open_thread})?([^<>]*?#{strong_close_thread}[^<>]*#{a_href_thread}?)\.! #(?:#{strong_open_thread}|#{breakline_thread})
    end
    def strong_details_regex_find_address_phone
      %r!(?:#{strong_open_thread}#{ok_tags}\d+(?:#{ok_tags}\.#{ok_tags_space}and#{ok_tags_space}\d+)?#{ok_tags}\.#{ok_tags}\s#{ok_tags})?[^<>]*?[,;]#{strong_close_thread}([^<>;]*)[;]?[^<>]*#{a_href_thread}?! #(?:#{strong_open_thread}|#{breakline_thread})
    end
    def strong_details_regex_find_name
      %r!(?:#{strong_open_thread}#{ok_tags}\d+(?:#{ok_tags}\.#{ok_tags_space}and#{ok_tags_space}\d+)?#{ok_tags}\.#{ok_tags}\s#{ok_tags})?(?:\s*?([^<>]*)\s*?)[,;]#{strong_close_thread}[^<>]*#{a_href_thread}?! #(?:#{strong_open_thread}|#{breakline_thread})
    end
    def a_regex_find_href
      %r!#{a_find_href_thread}!
    end
    def day_section_start_regex(list)
      insert = case_desensitize_array(Array(list))
      %r!#{within_broken_strong_optional("(?:#{insert})")}.*!
    end
    def day_section_cut_regex(list)
      insert = case_desensitize_array(Array(list))
      %r!#{within_broken_strong_optional("(?:#{insert})")}!
    end
    def day_section_cut_regex_find_section
      %r!#{within_broken_strong_optional("(?:.*?)")}(.*)!
    end

    def regex_split_without_loss(string_or_array, split_term)
      add_back = string_or_array.scan(split_term).flatten
      add_to = string_or_array.split(split_term).reject(&:blank?)
      if add_back && add_to && add_back.length >0 && add_to.length > 0
        0.upto(add_to.length - 1).each do |i|
          add_to[i] = add_back[i] + add_to[i]
        end
        return add_to
      else
        return nil
      end
    end

end