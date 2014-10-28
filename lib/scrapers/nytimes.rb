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

        if focus_area
          set_days
          set_basics

          days.each_with_index do |day, day_number|
            day_number += 1
            add_times_and_contents_to_group_array(day, day_number)
          end

          group_array.each do |group|
            activities = group[:content].scan(caps_before_parens_with_details_regex) || ''
            if activities && activities.length && activities.kind_of?(Array)
              activities.each do |activity|

                name = activity.scan(/\s*(.*?)\s\(/).flatten.first || ''
                street_address = activity.scan(/\((.*?)[,;]\s(?=\d+).*?\)/).flatten.first || ''
                phone = activity.scan(/\(.*?[,;]\s((?=\d+).*?)(?:[;,]|\))/).flatten.first || ''

                @data_array << {
                  source_day: group[:day_number],
                  source_time: group[:time],
                  source_index: group[:index],
                  source_group: group[:title],
                  name: name,
                  street_address: street_address,
                  locality: @location_best,
                  phone: phone
                  # website: website
                }

              end
            end
          end
          if set_basics && set_basics.length
            activities = set_basics.scan(caps_before_parens_with_details_regex) || ''
            if activities && activities.length && activities.kind_of?(Array)
              activities.each do |activity|

                name = activity.scan(/\s*(.*?)\s\(/).flatten.first || ''
                street_address = activity.scan(/\((.*?)[,;]\s(?=\d+).*?\)/).flatten.first || ''
                phone = activity.scan(/\(.*?[,;]\s((?=\d+).*?)(?:[;,]|\))/).flatten.first || ''

                @data_array << {
                  source_group: 'Destination Details',
                  name: name,
                  street_address: street_address,
                  locality: @location_best,
                  phone: phone
                  # website: website
                }
              end
            end
          end
        end
        
      elsif has_detail_box
        binding.pry    

        if focus_area
          set_days
          set_detail_box
        end

      end
  
      @data_array
    end

    private

    def set_days
      if %w(Friday Saturday Sunday).all?{ |weekend_day| focus_area.include?(weekend_day) }
        @days << focus_area.split(/#{within_broken_whitespace("Friday")}/)[1].split(/#{within_whitespace("Saturday")}/)[0]
        @days << focus_area.split(/#{within_broken_whitespace("Saturday")}/)[1].split(/#{within_whitespace("Sunday")}/)[0]
        @days << focus_area.split(/#{within_broken_whitespace("Sunday")}/)[1].split(/#{within_whitespace("THE BASICS")}|#{within_whitespace("IF YOU GO")}/)[0]
      else
        @days << focus_area
      end
    end
    def set_basics
      if focus_area.include?("THE BASICS") || focus_area.include?("IF YOU GO")
        @endDetail = focus_area.split(/#{within_broken_whitespace("THE BASICS")}|#{within_whitespace("IF YOU GO")}/)[1]
      end
    end
    def set_detail_box
      if focus_area.include?("THE BASICS") || focus_area.include?("IF YOU GO")
        @endDetail = focus_area.split(/#{within_broken_whitespace("THE BASICS")}|#{within_whitespace("IF YOU GO")}/)[1]
      end
    end

    def focus_area
      # equivalent of if ___ then ___ else ____
      @focus_area ||= css('#area-main').any? ? text_selector('#area-main') : text_selector('#article')
    end

    def no_detail_box
      url.include?('/travel/') && ( url.include?('journeys-36-hours') || url.include?("hours.html") )
    end

    def has_detail_box
      url.include?('things-to-do-in-36-hours')
    end

    def add_times_and_contents_to_group_array(day, day_number)

      group_time_array = day.scan(time_on_own_line_regex).flatten
      group_section_array = day.split(time_on_own_line_split_regex).reject(&:blank?) # blank? returns false on '', so we're rejecting empty strings

      if group_time_array.length == group_section_array.length
        0.upto(group_time_array.length - 1).each do |i|

          time = group_time_array[i] || ''
          content = group_section_array[i] || ''
          title = content.scan(/\n\s*?\d+\)\s(.*?)\n/).flatten.first || ''
          index = content.scan(/\n\s*?(\d+)\)\s.*?\n/).flatten.first || ''

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
    def breakline_thread #incomplete thread
      "(?:\\n|\\<(?:\\/?[p]|br)(?:\\s[^>]*?)?\\>)"
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
      "(?:(?:\<(?:b|strong)(\\s[^>]*?)?\\>)?\\s*?#{string}\\s*?(?:\\<\\/(?:b|strong)\\>|#{string}))"
    end
    def strong_open_thread
      within_whitespace( "(?:\\<(?:b|strong)(?:\\s[^>]*?)?\\>)(?=(?:.|\\n)*?(?:\\<\\/(?:b|strong)\\>))") 
    end
    def strong_close_thread
      within_whitespace( "(?:\\<\\/(?:b|strong)\\>)") 
    end

    # REGEX DEFINITIONS
    def time_on_own_line_regex
      %r!#{breakline_thread}\s*?#{strong_open_thread}?(?:(#{time_thread}|Noon))!
    end
    def time_on_own_line_split_regex
      %r!#{breakline_thread}\s*?#{strong_open_thread}?(?:#{time_thread}|Noon)!
    end
    def index_and_time_regex
      %r!#{breakline_thread}#{strong_open_thread}?\d+#{strong_close_thread}?#{strong_open_thread}?\.#{strong_close_thread}?#{strong_open_thread}?[^<>]*?\s[|]#{strong_open_thread}?\s*?(?:#{time_thread}|Noon)!
    end
    def caps_before_parens_with_details_regex
      %r!#{title_cased_thread}\s\(#{details_in_parens_thread}\)|\(#{details_in_parens_thread}\)!
    end
    def strong_detail_box_details_regex
      %r!#{strong_open_thread}\d+#{strong_or_not_thread(".")}(?:\s)!
      # \<(?:b|strong)(\s[^>]*?)?\>\d+(?:\<(?:b|strong)(\s[^>]*?)?\>\.\<\/(?:b|strong)\>|.)(?:\sand\s\d+(?:\<(?:b|strong)(\s[^>]*?)?\>\.\<\/(?:b|strong)\>|.))?\s[^<]*?\<\/(?:b|strong)\>.*?\<\/p\>
    end

  end
end