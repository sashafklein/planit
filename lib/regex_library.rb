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

    def details_semi_or_comma_separated_with_number_thread
      threads = [
        "(?:",
        "[^$)><;,]+?",
        "(?:",
        "[;,]",
        "\\s",
        "[^$)><;,]+?",
        ")?",
        "[;,]",
        "\\s",
        "\\d+",
        "[^)]+?",
        ")",
      ]
      threads.join
    end

    def details_semi_or_comma_separated_with_number_in_parens_thread
      threads = [
        "(?:",
        "\\(",
        details_semi_or_comma_separated_with_number_thread,
        "\\)",
        ")",
      ]
      threads.join
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

    def a_link_open_thread
      "(?:\\<a.*?href\\=['#{quote_thread}][^'#{quote_thread}]*?['#{quote_thread}]\\s*[^>]*?\\>)"
    end

    def a_link_close_thread
      "(?:\\<\\/a\\>)"
    end

    def a_href_thread
      "(?:#{a_link_open_thread}.*?#{a_link_close_thread})"
    end

    def a_find_href_thread
      "(?:\\<a.*?href\\=['#{quote_thread}]([^'#{quote_thread}]*?)['#{quote_thread}]\\s*[^>]*?\\>.*?#{a_link_close_thread})"
    end

    def find_phone_number_between_comma_or_semicolon_or_parens
      "(?:[;,(]\\s\\s*((?:[+(]*\\d+[)(-. ]?)+\\d\\d+))"
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
        "#{details_semi_or_comma_separated_with_number_thread}",
        "\\)|\\(",
        "#{details_semi_or_comma_separated_with_number_thread}",
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
    end

    def day_within_hnum_regex
      regex_string = [
        "#{hnum_open_thread}",
        "#{any_spaces}",
        "(?:d|D)ay \\d+",
        "#{any_spaces}",
        "#{hnum_close_thread}",
      ]
      %r!#{regex_string.join}!
    end

    def day_within_hnum_regex_find_day
      regex_string = [
        "#{hnum_open_thread}",
        "#{any_spaces}",
        "(?:d|D)ay (\\d+)",
        "#{any_spaces}",
        "#{hnum_close_thread}",
      ]
      %r!#{regex_string.join}!
    end

    def guide_item_regex
      regex_string = [
        "\\<",
        "div",
        "[^>]*?class\\=\\'[^>]*?",
        "guideItem listing",
        "[^>]*?\\'[^>]*?\\>",
      ]
      %r!#{regex_string.join}!
    end

    def find_guide_no_regex
      regex_string = [
        "\\<",
        "div",
        "[^>]*?id\\=\\'guide\\_(\\d*?)",
        "\\'",
        "[^>]*?\\>",
      ]
      %r!#{regex_string.join}!
    end

    def airbnb_rooms_link
      regex_string = [
        "\\<a[^>]*href\\=[#{quote_thread}']\\/rooms\\/",
        "\\d+",
        "[#{quote_thread}'][^>]*\\>",
        "[^<]+",
        "\\<\\/a\\>",
      ]
      %r!#{regex_string.join}!
    end

    def airbnb_rooms_link_find_room_no
      regex_string = [
        "\\<a[^>]*href\\=[#{quote_thread}']\\/rooms\\/",
        "(\\d+)",
        "[#{quote_thread}'][^>]*\\>",
        "[^<]+",
        "\\<\\/a\\>",
      ]
      %r!#{regex_string.join}!
    end

    def airbnb_host_link_find_user_id
      regex_string = [
        "\\<a[^>]*href\\=[#{quote_thread}']\\/users\\/show\\/",
        "(\\d+)",
        "[#{quote_thread}'][^>]*\\>",
        "[^<]+",
        "\\<\\/a\\>",
      ]
      %r!#{regex_string.join}!
    end

    def recognize_phone
      regex_string = [
        "(?:",
        "\\(?",
        "\\+?",
        "\\d+",
        "\\)?",
        "[ ]?",
        ")",
        "(?:",
        "[0-9() -]+",
        ")",
      ]
      %r!#{regex_string.join}!
    end

    def photos_with_image_folder
      regex_string = [
        "[#{quote_thread}']",
        "(http[s]?:\\/\\/",
        "[^#{quote_thread}']*?",
        "images",
        "[^#{quote_thread}']",
        "*?)[#{quote_thread}']",
      ]
      %r!#{regex_string.join}!
    end

    def find_lat_lon_regex
      regex_string = [
        "(?:",
        "http[s]?:\\/\\/",
        ")?",
        "(?:(?:[a-zA-Z0-9]|\-)+\\.)?(?:[a-zA-Z0-9]|\-)+\\.[a-zA-Z0-9]+",
        "\\/",
        ".*?",
        "(?:ll|center|marker)\\=",
        "((?:[0-9.,]|\-)+)"
      ]
      %r!#{regex_string.join}!
    end

    def trim_comma_semicolon_space_start_finish(string)
      string.scan(/\A[,; ]*(.*?)[,; ]*\Z/).flatten.first
    end

    def find_background_image_url_regex
      regex_string = [
        "url",
        "\\(",
        "[#{quote_thread}']?",
        "(",
        "http[s]?:\\/\\/",
        "(?:[a-zA-Z0-9-]+\\.)?[a-zA-Z0-9-]+\\.[a-zA-Z0-9]+",
        "\\/",
        "[^#{quote_thread}')]*?",
        ")",
        "[#{quote_thread}']?",
        "\\)",
      ]
      %r!#{regex_string.join}!      
    end

    def find_lat_lon_in_script_format_center_colon
      regex_string = [
        "center:",
        "[^.]*",
        "\\.maps\\.LatLng",
        "\\(",
        "(",
        "['#{quote_thread}]",
        "[-]?\\d+\\.\\d+",
        "['#{quote_thread}]",
        "\\,\\s?",
        "['#{quote_thread}]",
        "[-]?\\d+\\.\\d+",
        "['#{quote_thread}]",
        ")",
        "\\)",
      ]
      %r!#{regex_string.join}!      
    end

    def find_lat_by_script_id(id)
      regex_string = [
        "\{",
        "[^}]*",
        "['#{quote_thread}]",
        "id",
        "['#{quote_thread}]",
        "\:",
        id,
        "\,",
        "[^}]*",
        "['#{quote_thread}]",
        "lat",
        "['#{quote_thread}]",
        "\:",
        "['#{quote_thread}]?",
        "(",
        "[-]?\\d+\\.\\d+",
        ")",
        "['#{quote_thread}]?",
        "[^}]*",
        "\}",
      ]
      %r!#{regex_string.join}!      
    end

    def find_lng_by_script_id(id)
      regex_string = [
        "\{",
        "[^}]*",
        "['#{quote_thread}]",
        "id",
        "['#{quote_thread}]",
        "\:",
        id,
        "\,",
        "[^}]*",
        "['#{quote_thread}]",
        "lng",
        "['#{quote_thread}]",
        "\:",
        "['#{quote_thread}]?",
        "(",
        "[-]?\\d+\\.\\d+",
        ")",
        "['#{quote_thread}]?",
        "[^}]*",
        "\}",
      ]
      %r!#{regex_string.join}!      
    end

    def only_within_strong_strict_start_end
      regex_string = [
        "(?:",
        "\\A",
        b_or_strong_open_thread,
        "(.*?)",
        b_or_strong_close_thread,
        "\\Z",
        ")",
      ]
      %r!#{regex_string.join}!      
    end

    def capture_strong_phrase_accept_link
      regex_string = [
        "(",
        a_link_open_thread,
        "?",
        "[\\s]*",
        b_or_strong_open_thread,
        "(?:.*?)",
        b_or_strong_close_thread,
        "[\\s]*",
        a_link_close_thread,
        "?",
        ")",
      ]
      %r!#{regex_string.join}!      
    end

    def capture_strong_phrase_accept_link_followed_by_parens
      regex_string = [
        "(",
        a_link_open_thread,
        "?",
        "[\\s]*",
        b_or_strong_open_thread,
        "(?:.*?)",
        b_or_strong_close_thread,
        "[\\s]*",
        a_link_close_thread,
        "?",
        "[\\s]*",
        "\\(",
        ".*?",
        "\\)",
        ")",
      ]
      %r!#{regex_string.join}!      
    end

    def capture_phrase_accept_link_followed_by_detail_parens
      regex_string = [
        "(",
        a_link_open_thread,
        "?",
        "(?:.*?)",
        a_link_close_thread,
        "?",
        "\\s*",
        "\\(",
        details_semi_or_comma_separated_with_number_thread,
        "\\)",
        ")",
      ]
      %r!#{regex_string.join}!      
    end

    def remove_final_punctuation_regex
      %r/(.*)[,;:.?!]\z/
    end

    def static_map_src
      "[#{quote_thread}'](http[s]?:\\/\\/maps\\.googleapis\\.com\\/maps\\/api\\/staticmap\\?[^#{quote_thread}']*)[#{quote_thread}']"
    end

    def static_map_src
      "[#{quote_thread}'](http[s]?:\\/\\/maps\\.googleapis\\.com\\/maps\\/api\\/staticmap\\?[^#{quote_thread}']*)[#{quote_thread}']"
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