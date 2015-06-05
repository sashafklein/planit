module Scrapers
  module NytimesMod

    # PAGE SETUP

    class SeparatedThirtySixDetails < Nytimes
      
      def initialize(url, page)
        super(url, page)
        @scrape_target = %w(#area-main #article article)
      end

      def data
        global = global_data.dup

        activity_group_array.map{ |e| activity_data(e).merge( global ) }
          .reject{ |e| e[:place][:name].blank? }.uniq{ |e| e[:place][:name] }
      end

      private

      def global_data
        { 
          plan:{
            name: remove_plan_name_fluff( page.css("title").text ),
          },
          scraper_url: @url, 
        }
      end

      # PAGE 

      def activity_group_array
        return @activity_group_array if @activity_group_array
        array_in_activity_group_array = []
        if has_legend?
          activity_details_container = scrape_content.scan(day_section_start_regex(["the basics", "the details", "if you go", "lodging"])).flatten.first
          return @activity_array_group = activity_details_container.scan(p_strong_details_regex)
        end        
      end        

      def activity_data(activity)
        {
          place:{
            name: name( activity ),
            street_address: trim( activity.scan(strong_details_regex_find_address_phone).flatten.first ),
            website: activity.scan(a_regex_find_href).flatten.first,
            notes: clean_note( notes_for( name( activity ) ) ),
            nearby: nearby
          }
        }
      end

      # NEEDS TO BE MORE STRINGENT
      def has_legend?
        downcased = scrape_content.downcase
        return false unless (["the basics", "the details", "if you go", "lodging"]).any?{ |legend_group| downcased.include?(legend_group) }
        true
      end

      def name(activity)
        trim( de_tag( activity.scan(strong_details_regex_find_name).flatten.first ) )
      end

      def nearby
        split_by('h1', [["36 Hours in ", 1], ["36 Hours at the ", 1], ["36 Hours on ", 1], ["36 Hours | ", 1]])
      end

      memoize :name, :nearby
    end
  end
end

