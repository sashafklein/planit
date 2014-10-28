module Scrapers
  class Nytimes < Services::SiteScraper

    attr_accessor :group_array, :days
    def initialize(url, html)
      super
      @group_array, @days, @data_array = [], [], []
    end

    def data
      @location_best = split_by('h1', [["36 Hours in ", 1], ["36 Hours at the ", 1], ["36 Hours on ", 1], ["36 Hours | ", 1]])

      if no_detail_box
        get_no_detail_box_data
      elsif has_detail_box
        get_detail_box_data
      end
  
      @data_array
    end

    private

    def get_no_detail_box_data
      if focus_scrapable
        set_days

        days.each_with_index do |day, day_number|
          day_number += 1
          group_time_array = day.scan(time_on_own_line_regex_find_time).flatten
          group_section_array = day.split(time_on_own_line_regex).reject(&:blank?) # blank? returns false on '', so we're rejecting empty strings
          add_times_and_contents_to_group_array(day, day_number, group_time_array, group_section_array)
        end

        group_array.each do |group|
          activities = group[:content].scan(caps_before_parens_with_details_regex) || []
          add_activities_to_data_array(activities, group)
        end

        if set_basics.present?
          activities = set_basics.scan(caps_before_parens_with_details_regex) || []
          add_activities_to_data_array(activities)
        end

        binding.pry

      end
    end

    def get_detail_box_data
      if focus_scrapable
        set_days

        days.each_with_index do |day, day_number|
          day_number += 1
          group_time_array = day.scan(time_on_own_line_regex_find_time).flatten
          group_section_array = day.split(time_on_own_line_regex).reject(&:blank?) # blank? returns false on '', so we're rejecting empty strings
          add_times_and_contents_to_group_array(day, day_number, group_time_array, group_section_array)
        end

        binding.pry

        group_array.each do |group|
          activities = group[:content].scan(caps_before_parens_with_details_regex) || []
          add_activities_to_data_array(activities, group)
        end

        if set_basics.present?
          activities = set_basics.scan(caps_before_parens_with_details_regex) || []
          add_activities_to_data_array(activities)
        end
      end
    end

    def merge_group_defaults(hash, group)
      if group.any?
        {
          source_day: group[:day_number],
          source_time: group[:time],
          source_index: group[:index],
          source_group: group[:title]
        }.merge(hash)
      else
        { source_group: "Destination Details" }.merge(hash)
      end
    end

    def add_activities_to_data_array(activities, group={})
      activities.each do |activity|
        name = activity.scan(/\s*(.*?)\s\(/).flatten.first || ''
        street_address = activity.scan(/\((.*?)[,;]\s(?=\d+).*?\)/).flatten.first || ''
        phone = activity.scan(/\(.*?[,;]\s((?=\d+).*?)(?:[;,]|\))/).flatten.first || ''
        # website = || ''

        @data_array << merge_group_defaults({
          name: name,
          street_address: street_address,
          locality: @location_best,
          phone: phone
          # website: website
        }, group)
      end
    end

    def set_days
      if %w(Friday Saturday Sunday).all?{ |weekend_day| focus_scrapable.downcase.include?(weekend_day.downcase) }
        @days << focus_scrapable.split(day_section_split("friday"))[1].split(day_section_split("saturday"))[0]
        @days << focus_scrapable.split(day_section_split("saturday"))[1].split(day_section_split("sunday"))[0]
        # NEED TO CHECK IF AT LEAST ONE OF THE SEARCHES -- DETAILS/BASICS/IFYOUGO IS TRUE
        @days << focus_scrapable.split(day_section_split("sunday"))[1].split(day_section_split("the basics", "the details", "if you go"))[0]
      else
        @days << focus_scrapable
      end
    end
    
    def set_basics
      if focus_scrapable.include?("THE BASICS") || focus_scrapable.include?("IF YOU GO") || focus_scrapable.include?("THE DETAILS")
        focus_scrapable.split(day_section_split("the basics", "the details", "if you go"))[1]
      end
    end
    
    def focus_area
      return @focus_area if @focus_area
      %w(#area-main #article article).each do |selector|
        return @focus_area = css(selector) if css(selector).any?
      end
    end

    def focus_scrapable
      return @focus_scrapable if @focus_scrapable
      scrapable_start = focus_area.first.inner_html
      scrapable_start = CGI.unescape(scrapable_start)
      scrapable_start = scrapable_start.gsub(/\n/,'')
      scrapable_start = scrapable_start.gsub(/\"/,"'")
      scrapable_start = scrapable_start.gsub(/\<[^<>]*?data-description\=\'[^<>]*?\'[^<>]*?\>/,'')
      return @focus_scrapable = scrapable_start
    end

    def no_detail_box
      url.include?('/travel/') && ( url.include?('journeys-36-hours') || url.include?("hours.html") )
    end

    def has_detail_box
      url.include?('things-to-do-in-36-hours')
    end

    def add_times_and_contents_to_group_array(day, day_number, group_time_array, group_section_array)

      if group_time_array.length == group_section_array.length
        0.upto(group_time_array.length - 1).each do |i|

          time = group_time_array[i] || ''
          content = group_section_array[i] || ''
          title = content.scan(index_and_title_regex_find_title).flatten.first || ''
          index = content.scan(index_and_title_regex_find_index).flatten.first || ''

          @group_array << { 
            index: index,
            day_number: day_number,
            time: time, 
            title: trim( title ),
            content: content
          }
        end
      end
    end

    # REGEX COMPONENTS REMEMBER DOUBLE ALL BACKSLASH
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
    def title_cased_thread
      "(?:[S][t]\\a?\.\\s)?[A-ZÄÀÁÇÈÉëÌÍÖÒÓ][a-zäàáçèéëìíöòó,']+(?=(?:\\s|\\-?)[A-ZÄÀÁÇÈÉëÌÍÖÒÓ])(?:(?:\\s|\\-?)(?:[S][t]\\a?\.\\s)?[A-ZÄÀÁÇÈÉëÌÍÖÒÓ][a-zäàáçèéëìíöòó',]+)+"
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

    # REGEX SAFETY <- CANNOT BE REPEATED * OR + OR ?
    def case_desensitize(string)
      if string.length > 0
        '(?:' + string.upcase + '|' + string.downcase + '|' + string.capitalize + '|' + string.titleize + ')'
      end
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

    # REGEX DEFINITIONS
    def day_section_split(*list)
      item_array = []
      for item in list
        item_array << "#{case_desensitize(item)}"
      end
      insert = item_array.join("|")
      %r!#{within_broken_strong_optional("(?:#{insert})")}!
    end
    def time_on_own_line_regex_find_time
      %r!#{breakline_thread}#{tag_free_whitespace}#{ok_tags}#{tag_free_whitespace}((?:#{time_thread}|Noon))#{tag_free_whitespace}#{breakline_thread}!
    end
    def time_on_own_line_regex
      %r!#{breakline_thread}#{tag_free_whitespace}#{ok_tags}#{tag_free_whitespace}(?:#{time_thread}|Noon)#{tag_free_whitespace}#{breakline_thread}!
    end
    def index_and_title_regex
      %r!#{breakline_thread}#{tag_free_whitespace}#{ok_tags}#{tag_free_whitespace}\d+\)#{ok_tags_space}#{no_tags}\s*#{breakline_thread}!
    end
    def index_and_title_regex_find_title
      %r!#{breakline_thread}#{tag_free_whitespace}#{ok_tags}#{tag_free_whitespace}\d+\)#{ok_tags_space}(#{no_tags})\s*#{breakline_thread}!
    end
    def index_and_title_regex_find_index
      %r!#{breakline_thread}#{tag_free_whitespace}#{ok_tags}#{tag_free_whitespace}(\d+)\)#{ok_tags_space}#{no_tags}\s*#{breakline_thread}!
    end
    def strong_index_title_and_time_regex
      %r!#{breakline_thread}#{strong_open_thread}?\d+#{ok_tags}\.#{ok_tags_space}#{no_tags}#{ok_tags_space}[|]#{ok_tags_space}(?:#{time_thread}|Noon)#{ok_tags_space}#{breakline_thread}!
    end
    def caps_before_parens_with_details_regex
      %r!#{title_cased_thread}\s\(#{details_in_parens_thread}\)|\(#{details_in_parens_thread}\)!
    end
    def p_strong_details_regex
      %r!#{breakline_thread}#{strong_open_thread}#{ok_tags}\d+(?:#{ok_tags}\.#{ok_tags_space}and#{ok_tags_space}\d+)?#{ok_tags}\.#{ok_tags}\s#{ok_tags}#{no_tags}[,;]#{strong_close_thread}.*?#{breakline_thread}!
    end

  end
end