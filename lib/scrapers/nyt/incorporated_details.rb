module Scrapers
  module Nyt

    # PAGE SETUP

    class IncorporatedDetails < Nytimes
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

      def general_group
        if has_legend?
          general_container = scrape_content.scan(day_section_start_regex(["the basics", "the details", "if you go"])).flatten.first
          general_group = general_container.scan(titlecase_before_parens_with_details_regex)
        end
      end

      def general_data(general, general_index)
        {
          name: general.scan(before_parens_regex_find_name).flatten.first,
          street_address: general.scan(after_parens_regex_find_address).flatten.first,
          phone: general.scan(after_separator_regex_find_phone).flatten.first,
          website: general.scan(a_regex_find_href).flatten.first,
          general_title: trim( scrape_content.scan(day_section_start_regex(["the basics", "the details", "if you go"])).flatten.first.scan(day_section_cut_regex("(#{no_tags})")).flatten.first ),
          general_number: general_index + 1,
        }.merge(global_data)
      end

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
        regex_split_without_loss(day_to_split, time_on_own_line_regex)
      end

      def section_data(section, section_index)
        { 
          order: section.scan(index_and_title_regex_find_index).flatten.first,
          time: section.scan(time_on_own_line_regex_find_time).flatten.first, 
          section_title: trim( section.scan(index_and_title_regex_find_title).flatten.first ),
          content: trim( de_tag ( section.split(index_and_title_regex)[1] ) ),
        }
      end
      
      def activity_group(section)
        section.scan(titlecase_before_parens_with_details_regex).reject(&:blank?)
      end

      def activity_data(activity, activity_index)
        {
          name: activity.scan(before_parens_regex_find_name).flatten.first,
          street_address: activity.scan(after_parens_regex_find_address).flatten.first,
          phone: activity.scan(after_separator_regex_find_phone).flatten.first,
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
        return false unless ["the basics", "the details", "if you go"].any?{ |legend_group| downcased.include?(legend_group) }
        true
      end

    end
  end
end