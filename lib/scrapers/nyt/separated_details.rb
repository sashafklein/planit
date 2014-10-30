module Scrapers
  module Nyt

    # PAGE SETUP

    class SeparatedDetails < Nytimes
      def initialize(url, page)
        super(url, page)
        @scrape_target = %w(#area-main #article article)
      end

      def global_data
        { 
          locality: split_by('h1', [["36 Hours in ", 1], ["36 Hours at the ", 1], ["36 Hours on ", 1], ["36 Hours | ", 1]]),
        }
      end

      # PAGE 

      def itinerary_data(itinerary, itinerary_index)
        {
          trip_name: page.css("title").text,
        }
      end

      def day_group(leg)
        if scrape_content
          return [scrape_content] unless has_days? && has_legend?
          days = [ scrape_content.scan(day_section_start_regex("friday")).flatten.first.split(day_section_cut_regex("saturday"))[0] ]
          days << scrape_content.scan(day_section_start_regex("saturday")).flatten.first.split(day_section_cut_regex("sunday"))[0]
          days << scrape_content.scan(day_section_start_regex("sunday")).flatten.first.split(day_section_cut_regex(["the basics", "the details", "if you go"]))[0]
        end
      end

      def day_data(day, day_index)
        { 
          day_number: day_index + 1,
          day_title: trim( day.scan(day_section_cut_regex("(#{no_tags})")).flatten.first ),
        }
      end

      def section_group(day)
        day_to_split = day.split(day_section_cut_regex_find_section)[1]
        test = regex_split_without_loss(day_to_split, strong_index_title_and_time_on_own_line_regex)
      end

      def section_data(section, section_index)
        { 
          order: section.scan(strong_index_title_and_time_on_own_line_regex_find_index).flatten.first,
          time: section.scan(strong_index_title_and_time_on_own_line_regex_find_time).flatten.first,
          section_title: trim( section.scan(strong_index_title_and_time_on_own_line_regex_find_title).flatten.first ),
          content: trim( de_tag ( section.split(strong_index_title_and_time_on_own_line_regex)[1] ) ),
        }
      end
      
      def activity_group(section)
        section_relevant_index = section.scan(strong_index_title_and_time_on_own_line_regex_find_index).flatten.first
        if has_legend?
          activity_details_container = scrape_content.scan(day_section_start_regex(["the basics", "the details", "if you go"])).flatten.first
          activity_group_array = activity_details_container.scan(p_strong_details_regex)
          for group_to_test in activity_group_array
            group_index = group_to_test.scan(p_strong_details_regex_find_index).flatten.first
            if group_index == section_relevant_index
              return group_to_test.scan(strong_details_regex_find_activity).flatten
            end
          end
          return []
        end
      end

      def activity_data(activity, activity_index)
        # name = trim( de_tag( activity.scan(strong_details_regex_find_name).flatten.first ) )
        # street_address = trim( activity.scan(strong_details_regex_find_address_phone).flatten.first )
        # website = activity.scan(a_regex_find_href).flatten.first
        # binding.pry
        {
          name: trim( de_tag( activity.scan(strong_details_regex_find_name).flatten.first ) ),
          street_address: trim( activity.scan(strong_details_regex_find_address_phone).flatten.first ),
          website: activity.scan(a_regex_find_href).flatten.first,
        }
      end

      # OPERATIONS

      def has_days?
        downcased = scrape_content.downcase
        return false unless %w(Friday Saturday Sunday).all?{ |weekend_day| downcased.include?(weekend_day.downcase) }
        true
      end

      def has_legend?
        downcased = scrape_content.downcase
        return false unless (["the basics", "the details", "if you go"]).any?{ |legend_group| downcased.include?(legend_group) }
        true
      end

      def has_map_data?
        if page.css("script").include?("NYTG_MAP_DATA")
          true
        else
          false
        end
      end

    end
  end
end