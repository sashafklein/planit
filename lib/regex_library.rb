module RegexLibrary

    # LISTS

    def list_of_null_page_titles
      null_titles = [
        "home",
        "homepage",
        "home page",
        "main",
        "main page",
        "pages",
        "redirect",
        "redirect page",
        "page",
        "webpage",
        "website",
        "web site",
      ]
    end

    def accepted_articles 
      list = [
        "the", #english
        "la", #french, spanish, italian
        "el", #spanish
        "los", #spanish
        "las", #french, spanish, italian
        "le", #french
        "les", #french
        "il", #italian
        "gli", #italian
        "as", #portuguese
        "a", #portuguese, english
        "o", #portuguese, greek
        "os", #portuguese
        "der", #german
        "die", #german, afrikaans
        "de", #dutch
        "du", #basque
        "ang", #filipino
        "da", #hausa
        "nan", #haitian
        "an", #irish, english
      ].join("|")
    end

    def list_of_common_destination_types
      st = [
        "library",
        "bookstore",
        "restaurant",
        "cafe",
        "café",
        "gallery",
        "museum",
        "lounge",
        "hotel",
        "hostel",
        "bed & breakfast",
        "spa",
        "guide",
        "tour",
      ]
    end

    def abbrev_streets_list
      streets_list_hash.keys
    end

    def full_streets_list
      streets_list_hash.values
    end

    def streets_list_hash
      {
        "Aly" => "Alley",
        "Av" => "Avenue",
        "Ave" => "Avenue",
        "Blvd" => "Boulevard",
        "Br" => "Bridge",
        "Byp" => "Bypass",
        "Cir" => "Circle",
        "Cres" => "Crescent",
        "Cswy" => "Causeway",
        "Ct" => "Court",
        "Ctr" => "Center",
        "Dr" => "Drive",
        "Expwy" => "Expressway",
        "Expy" => "Expressway",
        "Ext" => "Extension",
        "Fwy" => "Freeway",
        "Gdn" => "Garden",
        "Gdns" => "Gardens",
        "Grv" => "Grove",
        "Hts" => "Heights",
        "Hwy" => "Highway",
        "Ln" => "Lane",
        "Mnr" => "Manor",
        "Pkwy" => "Parkway",
        "Plc" => "Place",
        "Plz" => "Plaza",
        "Pt" => "Point",
        "R" => "Rural",
        "Rd" => "Road",
        "Rte" => "Route",
        "Sq" => "Square",
        "St" => "Street",
        "Ter" => "Terrace",
        "Tpke" => "Turnpike",
        "Trl" => "Trail",
        "Via" => "Viaduct",
        "Vis" => "Vista"
      }
    end

    def cardinal_directions_list
      cardinal_directions_hash.keys
    end

    def cardinal_directions_hash
      {
        "N" => "North",
        "S" => "South",
        "E" => "East",
        "W" => "West",
        "NE" => "Northeast",
        "NW" => "Northwest",
        "SE" => "Southeast",
        "SW" => "Southwest"
      }
    end

    # REGEX COMPONENTS REMEMBER DOUBLE ALL BACKSLASH

    def streets_or_cardinals_thread
      items = streets_list + cardinal_directions_list
      "(?:" + items.join("\\.|") + "\\.)"
    end

    def lowercase_destination_class
      insert = list_of_common_destination_types.join("|")
      "(?:#{insert})"
    end

    def lowercase_destinations_plural_class
      insert = list_of_common_destination_types.join("s|") + "s"
      "(?:#{insert})"
    end

    def exceptions
      excepts = [
        "!",
        "\\?",
        "¿",
        "¡",
        " \\.\\.\\.",
        " …",
        "…",
        "\\.\\.\\.",
      ]
      insert = excepts.join("|")
      "(?:#{insert})"
    end

    def latinate_or_number_thread
      "(?:[0-9A-Z#{upcase_latinate_thread}a-z#{downcase_latinate_thread}])"
    end

    def non_latinate_thread
      "(?:[^A-Z#{upcase_latinate_thread}a-z#{downcase_latinate_thread}])"
    end

    def non_latinate_or_punctuation_thread
      "(?:[^#{normal_punctuation_thread}A-Z#{upcase_latinate_thread}a-z#{downcase_latinate_thread}])"
    end

    def non_latinate_or_punctuation_or_space_thread
      "(?:[^#{normal_punctuation_thread}A-Z#{upcase_latinate_thread}a-z#{downcase_latinate_thread}0-9 ])"
    end

    def upcase_latinate_thread
      upcase_latinate_vowel_thread + upcase_latinate_consonant_thread
    end

    def downcase_latinate_thread
      downcase_latinate_vowel_thread + downcase_latinate_consonant_thread
    end

    def upcase_latinate_vowel_thread
      "ÀÁÂÄÆÃAĀÈÉÊËĒĖĘÌĪĮÎÏÍÖÔŒØŌÕÒÓÜÛÙÚŪ"
    end

    def downcase_latinate_vowel_thread
      "àáâäæãaāèéêëēėęìīįîïíöôœøōõòóüûùúū"
    end

    def upcase_latinate_consonant_thread
      "ŸSSŚŠŁŽŹŻÑŃÇĆČ"
    end

    def downcase_latinate_consonant_thread
      "ÿßśšłžźżñńçćč"
    end

    def normal_punctuation_thread
      "-#{quote_thread}'’!?.,:;\(\)_`\\/"
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
      "(?:[A-Z#{upcase_latinate_thread}][A-Z#{upcase_latinate_thread}a-z#{downcase_latinate_thread}'’]+)"
      # "(?:[A-ZÄÀÁÇÈÉëÌÍÖÒÓ][A-ZÄÀÁÇÈÉëÌÍÖÒÓa-zäàáçèéëìíöòó'’]+)"
    end

    def title_or_upper_case_word_or_num
      "(?:[A-ZÄÀÁÇÈÉëÌÍÖÒÓ0-9][A-ZÄÀÁÇÈÉëÌÍÖÒÓa-zäàáçèéëìíöòó'’0-9-]+)"
      # "(?:[A-ZÄÀÁÇÈÉëÌÍÖÒÓ][A-ZÄÀÁÇÈÉëÌÍÖÒÓa-zäàáçèéëìíöòó'’]+)"
    end

    def title_case_word
      "(?:[A-Z#{upcase_latinate_thread}][a-z#{downcase_latinate_thread}'’]+)"
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

    def title_or_upper_cased_or_exceptions_thread
      "(?:(?:#{exceptions}?#{title_case_st_sta}#{title_or_upper_case_word_or_num}#{exceptions}?|#{exceptions}?#{title_or_upper_case_word_or_num}#{exceptions}?)(?:#{comma_space_or_dash}(?:#{exceptions}?#{title_case_st_sta}#{title_or_upper_case_word_or_num}#{exceptions}?|#{exceptions}?#{title_or_upper_case_word_or_num}#{exceptions}?))*)"
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

    def is_website_link?
      threads = [
        "(?:",
        "(?:",
        "http[s]?:\\/\\/",
        ")?",
        "[a-z0-9]+?\\.(?:[a-z0-9]+\\.)*[a-z]{2}[^ \\\\<>()'",
        quote_thread,
        "]*",
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

    def a_href_thread_find_text
      "(?:#{a_link_open_thread}\\s*(.*?)\\s*#{a_link_close_thread})"
    end

    def a_find_href_thread
      "(?:\\<a.*?href\\=['#{quote_thread}]([^'#{quote_thread}]*?)['#{quote_thread}]\\s*[^>]*?\\>.*?#{a_link_close_thread})"
    end

    def email_thread
      "(?:[#{latinate_or_number_thread}]+\\@[#{latinate_or_number_thread}]+\.[A-Za-z][A-Za-z]+(?:\\.[A-Za-z][A-Za-z]+)+)"
    end

    def phone_number_thread
      # old "(?:(?:[+(]*\\d+[(\\\-\/. )]?)+(?:[-(). 0-9]\\d\\d+)+)"
      [
        "(?:",

        "(?:", # COUNTRY CODE -- OPTIONAL
        "(?:\\+|\\+ )?", # start with optional + or +_
        "\\d\\d?", # country code -- 1-2 numbers
        "[-.\\\\\/ ]?", # optional dash or period or slashes or space
        ")?",

        "(?:", # AREA CODE -- OPTIONAL
        "[()]\\d\\d?\\d?[)]?", # optional area code, 1 up to 3, with 1 follow-up
        "[-.\\\\\/ ]?", # optional dash or period or slashes or space
        ")?",

        # CORE NUMBER
        "(?:", # option of lots of small numbers broken up insist minimum 7 numbers total
        "(?:\\d\\d?\\d?\\d?)", # at least one (1+)
        "[-.\\\\\/ ]?", # optional dash or period or slashes or space
        "(?:\\d\\d\\d?\\d?)", # at least two (3+)
        "[-.\\\\\/ ]?", # optional dash or period or slashes or space
        "(?:\\d\\d\\d?\\d?)", # at least two (5+)
        "[-.\\\\\/ ]?", # optional dash or period or slashes or space
        "(?:\\d\\d\\d?\\d?)", # at least two (7+)
        "[-.\\\\\/ ]?", # optional dash or period or slashes or space
        "(?:\\d\\d\\d?\\d?)?", # optional final 2-4 numbers
        "[-.\\\\\/ ]?", # optional dash or period or slashes or space
        "(?:\\d\\d\\d?\\d?)?", # optional final 2-4 numbers
        "|", # option of bigger set of numbers
        "(?:\\d\\d\\d?\\d?)", # at least two (2+)
        "[-.\\\\\/ ]?", # optional dash or period or slashes or space
        "(?:\\d\\d\\d?\\d?)", # at least two (4+)
        "[-.\\\\\/ ]?", # optional dash or period or slashes or space
        "(?:\\d\\d\\d\\d?)", # at least three (7+)
        "[-.\\\\\/ ]?", # optional dash or period or slashes or space
        "(?:\\d\\d\\d?\\d?)?", # optional final 2-4 numbers
        "[-.\\\\\/ ]?", # optional dash or period or slashes or space
        "(?:\\d\\d\\d?\\d?)?", # optional final 2-4 numbers
        ")",

        ")",
      ].join
    end

    def find_phone_number_between_comma_or_semicolon_or_parens
      "(?:[;,(]\\s\\s*(#{phone_number_thread})\\s*[;,)])"
    end

    # REGEX SAFETY <- CANNOT BE REPEATED * OR + OR ?

    def case_desensitize(string)
      if string && string.length > 0
        '(?:' + string + '|' + string.upcase + '|' + string.downcase + '|' + string.capitalize + '|' + string.titleize + ')'
      end
    end

    def case_desensitize_array(list)
      item_array = []
      joiner = '|'
      list.each do |item|
        if item.length > 0
          string = item + joiner + item.upcase + joiner + item.downcase + joiner + item.capitalize + joiner + item.titleize
          item_array << string
        end
      end
      insert = "(?:" + item_array.join(joiner) + ")"
    end

    def case_desensitize_and_pluralize_array(list)
      item_array = []
      joiner = '[Ss]?|'
      list.each do |item|
        if item.length > 0
          string = item + joiner + item.upcase + joiner + item.downcase + joiner + item.capitalize + joiner + item.titleize
          item_array << string
        end
      end
      insert = "(?:" + item_array.join(joiner) + ")"
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
      %r!\(.*?[,;]\s(((#{phone_number_thread}).*?))(?:[;,]|\))!
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
        "#{title_or_upper_cased_or_exceptions_thread}",
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
        is_website_link?,
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
      %r!#{phone_number_thread}!
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
        "\\s*",
        "(?:#{title_or_upper_cased_or_exceptions_thread})",
        "\\s*",
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

    def find_website_by_name_multiple_attempts_regex(name)
      # option 1 mandatory parens before name
      # option 2 mandatory parens after name
      # option 3 in sentence/phrase no periods
      regex_string = [
        "(?:",
        "[(]",
        name,
        "(?:[^)]*[(][^)]*?[)][^)]*?|[^)]*?)",
        "(#{is_website_link?})",
        ".*?",
        "[)]",
        "|",
        name,
        "\\s*",
        "[(]",
        "(?:[^)]*[(][^)]*?[)][^)]*?|[^)]*?)",
        "(#{is_website_link?})",
        ".*?",
        "[)]",
        "|",
        name,
        "(?:",
        "[^.]*",
        streets_or_cardinals_thread,
        "[^.]*",
        ")*?",
        "(#{is_website_link?})",
        ")",
      ]
      %r!#{regex_string.join}!      
    end

    def find_phone_by_name_multiple_attempts_regex(name)
      # option 1 mandatory parens before name
      # option 2 mandatory parens after name
      # option 3 in sentence/phrase no periods
      regex_string = [
        "(?:",
        "[(]",
        name,
        "(?:[^)]*[(][^)]*?[)][^)]*?|[^)]*?)",
        "(#{phone_number_thread})",
        ".*?",
        "[)]",
        "|",
        name,
        "\\s*",
        "[(]",
        "(?:[^)]*[(][^)]*?[)][^)]*?|[^)]*?)",
        "(#{phone_number_thread})",
        ".*?",
        "[)]",
        "|",
        name,
        "(?:",
          "[^.]*",
          streets_or_cardinals_thread,
          "[^.]*",
        ")*?",
        "(#{phone_number_thread})",
        ")",
      ]
      %r!#{regex_string.join}!      
    end

    def find_address_by_name_multiple_attempts_regex(name)
      # option 1 mandatory parens before name
      # option 2 mandatory parens after name
      # option 3 in sentence/phrase no periods
      regex_string = [
        "(?:",
          "[(]",
          name,
          "[,: ]*",
          "((?:[^)]*[(][^)]*?[)][^)]*?|[^)]*?))",
          "(?:",
            "#{phone_number_thread}",
            "|",
            "#{is_website_link?}",
          ")",
          ".*?",
          "[)]",
        "|",
          name,
          "\\s*",
          "[(]",
          "((?:[^)]*[(][^)]*?[)][^)]*?|[^)]*?))",
          "(?:",
            "#{phone_number_thread}",
            "|",
            "#{is_website_link?}",
          ")",
          ".*?",
          "[)]",
        "|",
          name,
          "[,: ]*",
          "(",
            "(?:",
              "[^.]*",
              streets_or_cardinals_thread,
              "[^.]*",
            ")*?",
          ")",
          "(?:",
            "#{phone_number_thread}",
            "|",
            "#{is_website_link?}",
            "|",
            "\\Z",
          ")",
        ")",
      ]
      %r!#{regex_string.join}!      
    end

    def remove_final_punctuation_regex
      %r/(.*)[,;:.?!]?\Z/
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

    def generous_postal_code_regex
      %r![A-Z0-9][A-Z0-9][- ]?[A-Z0-9]?[- ]?[A-Z0-9]?[- ]?[A-Z0-9]?[- ]?[A-Z0-9]?[- ]?[A-Z0-9]?[- ]?[A-Z0-9]?[A-Z0-9][A-Z0-9]!
    end
    
end