module RegexLibrary

    # REGEX COMPONENTS REMEMBER DOUBLE ALL BACKSLASH

    def lowercase_destination_class
      destinations = [
        "library",
        "bookstore",
        "restaurant",
        "cafe",
        "café",
        "gallery",
        "museum",
        "lounge",
        "hotel",
        "spa",
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

    def any_spaces
      "(?:\\s*?)"
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

    def optional_strong_or_hnum_within_breakline_optional(string)
      threads = [
        "(?:",
        "#{breakline_thread}",
        "#{any_spaces}",
        "(?:",
        "#{b_or_strong_open_thread}?",
        "|",
        "#{hnum_open_thread}?",
        ")",
        "#{any_spaces}",
        "#{string}",
        "#{any_spaces}",
        "(?:",
        "#{b_or_strong_close_thread}?",
        "|",
        "#{hnum_close_thread}?",
        ")",
        "#{any_spaces}",
        "#{breakline_thread}",
        ")",
      ]
      threads.join
    end

    def optional_strong_within_breakline(string)
      "(?:#{breakline_thread}#{b_or_strong_open_in_space_thread}?\\s*?#{string}\\s*?#{b_or_strong_close_in_space_thread}?#{breakline_thread})"
    end

    def hnum_open_thread
      "(?:\\<h\\d(?:\\s[^>]*?)?\\>)" 
    end

    def hnum_close_thread
      "(?:\\<\\/h\\d\\>)" 
    end

    def b_or_strong_open_thread
      "(?:\\<(?:b|strong)(?:\\s[^>]*?)?\\>)" 
    end

    def b_or_strong_close_thread
      "(?:\\<\\/(?:b|strong)\\>)" 
    end

    def b_or_strong_open_in_space_thread
      within_whitespace( "(?:\\<(?:b|strong)(?:\\s[^>]*?)?\\>)(?=(?:.|\\n)*?(?:\\<\\/(?:b|strong)\\>))") 
      # within_whitespace( "(?:\\<(?:b|strong)(?:\\s[^>]*?)?\\>)(?=(?:.|\\n)*?(?:\\<\\/(?:b|strong)\\>))") 
    end

    def b_or_strong_close_in_space_thread
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
      regex_string = [
        "#{breakline_thread}",
        "#{tag_free_whitespace}",
        "#{ok_tags}",
        "#{tag_free_whitespace}",
        "(?:#{time_thread}|Noon)",
        "#{tag_free_whitespace}",
        "#{ok_tags}",
        "#{tag_free_whitespace}",
        "#{breakline_thread}",
      ]
      %r!#{regex_string.join}!
    end

    def time_on_own_line_regex_find_time
      regex_string = [
        "#{breakline_thread}",
        "#{tag_free_whitespace}",
        "#{ok_tags}",
        "#{tag_free_whitespace}",
        "((?:#{time_thread}|Noon))",
        "#{tag_free_whitespace}",
        "#{ok_tags}",
        "#{tag_free_whitespace}",
        "#{breakline_thread}",
      ]
      %r!#{regex_string.join}!
    end

    def index_and_title_regex
      regex_string = [
        "#{breakline_thread}",
        "#{tag_free_whitespace}",
        "#{ok_tags}",
        "#{tag_free_whitespace}",
        "#{ok_tags}",
        "\\d+\\)",
        "#{ok_tags_space}",
        "#{ok_tags}",
        "#{no_tags}",
        "#{ok_tags}",
        "\\s*",
        "#{breakline_thread}",
      ]
      %r!#{regex_string.join}!
    end

    def index_and_title_regex_find_title
      regex_string = [
        "#{breakline_thread}",
        "#{tag_free_whitespace}",
        "#{ok_tags}",
        "#{tag_free_whitespace}",
        "#{ok_tags}",
        "\\d+\\)",
        "#{ok_tags_space}",
        "#{ok_tags}",
        "\\s*",
        "(#{no_tags})",
        "#{ok_tags}",
        "\\s*",
        "#{breakline_thread}",
      ]
      %r!#{regex_string.join}!
    end

    def index_and_title_regex_find_index
      regex_string = [
        "#{breakline_thread}",
        "#{tag_free_whitespace}",
        "#{ok_tags}",
        "#{tag_free_whitespace}",
        "#{ok_tags}",
        "(\\d+)\\)",
        "#{ok_tags_space}",
        "#{ok_tags}",
        "#{no_tags}",
        "#{ok_tags}",
        "\\s*",
        "#{breakline_thread}",
      ]
      %r!#{regex_string.join}!
    end

    def strong_index_title_and_time_then_linebreak_regex
      regex_string = [
        "#{breakline_thread}?",
        "#{b_or_strong_open_in_space_thread}?",
        "\\d+",
        "#{ok_tags}",
        "\\.",
        "#{ok_tags_space}",
        "#{no_tags}",
        "#{ok_tags_space}",
        "[|]",
        "#{ok_tags_space}",
        "(?:#{time_thread}|Noon)",
        "#{ok_tags_space}",
        "#{breakline_thread}",
      ]
      %r!#{regex_string.join}!
    end

    def strong_index_title_and_time_then_linebreak_regex_find_title
      regex_string = [
        "#{breakline_thread}?",
        "#{b_or_strong_open_in_space_thread}?",
        "\\d+",
        "#{ok_tags}",
        "\\.",
        "#{ok_tags_space}",
        "\\s*",
        "(#{no_tags})",
        "#{ok_tags_space}",
        "[|]",
        "#{ok_tags_space}",
        "(?:#{time_thread}|Noon)",
        "#{ok_tags_space}",
        "#{breakline_thread}",
      ]
      %r!#{regex_string.join}!
    end

    def strong_index_title_and_time_then_linebreak_regex_find_time
      regex_string = [
        "#{breakline_thread}?",
        "#{b_or_strong_open_in_space_thread}?",
        "\\d+",
        "#{ok_tags}",
        "\\.",
        "#{ok_tags_space}",
        "#{no_tags}",
        "#{ok_tags_space}",
        "[|]",
        "#{ok_tags_space}",
        "((?:#{time_thread}|Noon))",
        "#{ok_tags_space}",
        "#{breakline_thread}",
      ]
      %r!#{regex_string.join}!
    end

    def strong_index_title_and_time_then_linebreak_regex_find_index
      regex_string = [
        "#{breakline_thread}?",
        "#{b_or_strong_open_in_space_thread}?",
        "(\\d+)",
        "#{ok_tags}",
        "\\.",
        "#{ok_tags_space}",
        "#{no_tags}",
        "#{ok_tags_space}",
        "[|]",
        "#{ok_tags_space}",
        "(?:#{time_thread}|Noon)",
        "#{ok_tags_space}",
        "#{breakline_thread}",
      ]
      %r!#{regex_string.join}!
    end

    def titlecase_before_parens_with_details_regex
      regex_string = [
        "#{ok_tags}",
        "#{title_or_upper_cased_thread}",
        "\\s?",
        "#{ok_tags}",
        "\\s?",
        "#{lowercase_destination_class}?",
        "#{ok_tags}",
        "\\s\\s?\\(",
        "#{details_in_parens_thread}",
        "\\)|\\(",
        "#{details_in_parens_thread}",
        "\\)",
      ]
      %r!#{regex_string.join}!
    end

    def p_strong_details_regex
      regex_string = [
        "#{breakline_thread}",
        "#{b_or_strong_open_in_space_thread}",
        "#{ok_tags}",
        "\\d+",
        "(?:",
        "#{ok_tags}",
        "\\.",
        "#{ok_tags_space}",
        "and",
        "#{ok_tags_space}",
        "\\d+",
        ")?",
        "#{ok_tags}",
        "\\.",
        "#{ok_tags}",
        "\\s",
        "#{ok_tags}",
        "#{no_tags}",
        "[,;|]",
        "#{no_tags}",
        "#{b_or_strong_close_in_space_thread}",
        ".*?",
        "#{breakline_thread}",
      ]
      %r!#{regex_string.join}!
    end

    def p_strong_details_regex_find_index #first of 2
      regex_string = [
        "#{breakline_thread}",
        "#{b_or_strong_open_in_space_thread}",
        "#{ok_tags}",
        "(\\d+)",
        "(?:",
        "#{ok_tags}",
        "\\.",
        "#{ok_tags_space}",
        "and",
        "#{ok_tags_space}",
        "\\d+",
        ")?",
        "#{ok_tags}",
        "\\.",
        "#{ok_tags}",
        "\\s",
        "#{ok_tags}",
        "#{no_tags}",
        "[,;]",
        "#{no_tags}",
        "#{b_or_strong_close_in_space_thread}",
        ".*?",
        "#{breakline_thread}",
      ]
      %r!#{regex_string.join}!
    end

    def strong_details_regex_find_activity
      regex_string = [
        "(?:",
        "#{b_or_strong_open_in_space_thread}",
        "#{ok_tags}",
        "\\d+",
        "(?:",
        "#{ok_tags}",
        "\\.",
        "#{ok_tags_space}",
        "and",
        "#{ok_tags_space}",
        "\\d+",
        ")?",
        "#{ok_tags}",
        "\\.",
        "#{ok_tags}",
        "\\s",
        "#{ok_tags}",
        "|",
        "#{b_or_strong_open_in_space_thread}",
        ")?",
        "(",
        "[^<>]*?",
        "#{b_or_strong_close_in_space_thread}",
        "[^<>]*",
        "#{a_href_thread}?",
        ")",
        "\\.",
      ]
      %r!#{regex_string.join}!
    end

    def strong_details_regex_find_address_phone
      regex_string = [
        "(?:",
        "#{b_or_strong_open_in_space_thread}",
        "#{ok_tags}",
        "\\d+",
        "(?:",
        "#{ok_tags}",
        "\\.",
        "#{ok_tags_space}",
        "and",
        "#{ok_tags_space}",
        "\\d+",
        ")?",
        "#{ok_tags}",
        "\\.",
        "#{ok_tags}",
        "\\s",
        "#{ok_tags}",
        ")?",
        "[^<>]*?",
        "[,;]",
        "#{b_or_strong_close_in_space_thread}",
        "([^<>;]*)",
        "[;]?",
        "[^<>]*",
        "#{a_href_thread}?",
      ]
      %r!#{regex_string.join}!
    end

    def strong_details_regex_find_name
      regex_string = [
        "(?:",
        "#{b_or_strong_open_in_space_thread}",
        "#{ok_tags}",
        "\\d+",
        "(?:",
        "#{ok_tags}",
        "\\.",
        "#{ok_tags_space}",
        "and",
        "#{ok_tags_space}",
        "\\d+",
        ")?",
        "#{ok_tags}",
        "\\.",
        "#{ok_tags}",
        "\\s",
        "#{ok_tags}",
        ")?",
        "(?:",
        "\\s*?",
        "([^<>]*)",
        "\\s*?",
        ")",
        "[,;]",
        "#{b_or_strong_close_in_space_thread}",
        "[^<>]*",
        "#{a_href_thread}?",
      ]
      %r!#{regex_string.join}!
    end

    def a_regex_find_href
      %r!#{a_find_href_thread}!
    end

    def find_website_after_n
<<<<<<< Updated upstream
      regex_string = [
        "\\n",
        "(",
        "(?:",
        "http[s]?:\\/\\/",
        ")?",
        ".*[a-z]\\.[a-z].*",
        ")",
        "(?:\\n|\\z)", #end of line or string
      ] 
      %r!#{regex_string.join}!
    end

    def find_phone_after_n
      regex_string = [
        "\\n",
        "(",
        "(?:",
        "(?:",
        "\\d|\\-|\\(|\\)",
        "){9}",
        "(?:",
        "\\d|\\-|\\(|\\)",
        ")+",
        ")",
        "(?:\\n|\\z)", #end of line or string
      ]
      %r!#{regex_string.join}!
    end

    def find_address_after_n
      regex_string = [
        "\\n",
        "(",
        "(?:",
        "[a-z]|[A-z]|[0-9]| |[.,'-()]",
        ")+",
        "(?:",
        "[ ][a-z|A-Z]|[a-z|A-Z][ ]",
        ")",
        "(?:",
        "[a-z]|[A-z]|[0-9]| |[.,'-()]",
        ")+?",
        ")",
        "(?:\\n|\\z)", #end of line or string
      ]
      %r!#{regex_string.join}!
=======
      %r!\nhttp:\/\/(.*)!
>>>>>>> Stashed changes
    end

    def day_section_start_regex(list)
      insert = case_desensitize_array(Array(list))
      %r!#{optional_strong_or_hnum_within_breakline_optional("(?:#{insert})")}.*!
    end

    def day_section_cut_regex(list)
      insert = case_desensitize_array(Array(list))
      %r!#{optional_strong_or_hnum_within_breakline_optional("(?:#{insert})")}!
    end

    def day_section_cut_regex_find_section
      %r!#{optional_strong_or_hnum_within_breakline_optional("(?:.*?)")}(.*)!
    end

    def nytimes_map_data_regex
      %r!var NYTG_MAP_DATA = ({.*})!
    end

end