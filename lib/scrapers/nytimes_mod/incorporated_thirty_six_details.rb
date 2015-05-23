module Scrapers
  module NytimesMod

    # PAGE SETUP

    class IncorporatedThirtySixDetails < Nytimes
      def initialize(url, page)
        super(url, page)
        @scrape_target = %w(#area-main #article article)
      end

      def global_data
        { 
          scraper_url: @url, 
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
          place:{
            name: name(general),
            street_address: general.scan(after_parens_regex_find_address).flatten.first,
            phone: general.scan(after_separator_regex_find_phone).flatten.first,
            website: general.scan(a_regex_find_href).flatten.first,
            notes: notes_for( name(general) ),
            # general_title: trim( scrape_content.scan(day_section_start_regex(["the basics", "the details", "if you go"])).flatten.first.scan(day_section_cut_regex("(#{no_tags})")).flatten.first ),
            # general_number: general_index + 1,
          },
        }
      end

      def itinerary_data(itinerary, itinerary_index)
        {
          place:{
            nearby: split_by('h1', [["36 Hours in ", 1], ["36 Hours at the ", 1], ["36 Hours on ", 1], ["36 Hours | ", 1]]).gsub(/<.*>/, ''),
          },
          plan:{
            name: remove_plan_name_fluff( page.css("title").text ),
          },
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
          day:{
            order: (day_index + 1).to_i,
          },
          item:{
            start_date: trim( day.scan(day_section_cut_regex("(#{no_tags})")).flatten.first ),
          },
        }
      end

      def section_group(day)
        day_to_split = day.split(day_section_cut_regex_find_section)[1]
        regex_split_without_loss(day_to_split, time_on_own_line_regex)
      end

      def section_data(section, section_index)
        { 
          item:{
            order: trim(section.scan(index_and_title_regex_find_index).flatten.first).to_i,
            start_time: section.scan(time_on_own_line_regex_find_time).flatten.first, 
          },
          place:{
            section_title: trim( section.scan(index_and_title_regex_find_title).flatten.first ),
            # content: trim( de_tag ( section.split(index_and_title_regex)[1] ) ),
          },
        }
      end
      
      def activity_group(section)
        section.scan(titlecase_before_parens_with_details_regex).reject(&:blank?)
      end

      def activity_data(activity, activity_index)
        {
          place:{
            name: name(activity),
            street_address: activity.scan(after_parens_regex_find_address).flatten.first,
            phone: activity.scan(after_separator_regex_find_phone).flatten.first,
            website: activity.scan(a_regex_find_href).flatten.first,
            notes: notes_for( name(activity) ),
          },
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

      def name(activity_or_general)
        trim( de_tag( activity_or_general.scan(before_parens_regex_find_name).flatten.first ) )
      end

      memoize :name
    end
  end
end