module Scrapers
  class Nytimes < Services::SiteScraper

    attr_accessor :group_array, :days
    def initialize(url, html)
      super
      @group_array, @days, @data_array = [], [], []
    end

    def data
      if no_detail_box
        @location_best = split_by('h1', [["36 Hours in ", 1], ["36 Hours at the ", 1], ["36 Hours on ", 1], ["36 Hours | ", 1]])
        if focus_area
          set_days
          
          days.each_with_index do |day, day_number|
            day_number += 1
            add_times_and_contents_to_group_array(day, day_number)
          end

          group_array.each do |group|
            activities = group[:content].scan(jamba_juice_regex) || ''
            activities.each do |activity|


            end
          end
        end
        

      elsif has_detail_box
      end
    end

    private

    def set_days
      if %w(Friday Saturday Sunday).all?{ |weekend_day| focus_area.include?(weekend_day) }
        @days << focus_area.split( within_whitespace("Friday") )[1].split( within_whitespace("Saturday") )[0]
        @days << focus_area.split( within_whitespace("Saturday") )[1].split( within_whitespace("Sunday") )[0]
        @days << focus_area.split( within_whitespace("Sunday") )[1].split(/\n\s*?THE\sBASICS\s*?\n|\n\s*?IF\sYOU\sGO\s*?\n/)[0]
      else
        @days << focus_area
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
      # Refactor out this regex
      group_time_array = day.scan(/\n\d?\d?:?\d?\d\s[ap]\.[m]\.|\n[N][o][o][n]/)
      group_section_array = day.split(/\n\d?\d?:?\d?\d\s[ap]\.[m]\.|\n[N][o][o][n]/).reject(&:blank?) # blank? returns false on '', so we're rejecting empty strings
      binding.pry # The numbers aren't equal this first time around
      if group_time_array.length == group_section_array.length
        0.upto(group_time_array.length).each do |i|
          time = trim( group_time_array[i] )
          content = group_section_array[i]
          @group_array << { 
            time: trim( group_time_array[i] ), 
            content: group_section_array[i],
            day_number: day_number 
          }
        end
      end
    end

    def jamba_juice_regex
      /(((?:[S][t]\a?\.\s)?[A-ZÄÀÁÇÈÉëÌÍÖÒÓ][a-zäàáçèéëìíöòó,']+(?=(?:\s|\-?)[A-ZÄÀÁÇÈÉëÌÍÖÒÓ]))?(?:(?:\s|\-?)(?:[S][t]\a?\.\s)?[A-ZÄÀÁÇÈÉëÌÍÖÒÓ][a-zäàáçèéëìíöòó',]+)+\s\([^$><";,]+?(?:[;,]\s[^;),]+?)?[;,]\s\d+[^)]+?\)|\s\([^$><";,]+?(?:[;,]\s[^;),><"]+?)?[;,]\s\d+[^)]+?\))/
    end

    def within_whitespace(string)
      /\n\s*?#{string}\s*?\n/
    end
  end
end