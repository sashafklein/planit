module Scrapers
  module NytimesMod

    # PAGE SETUP

    class IncorporatedThirtySixDetails < Nytimes
      def initialize(url, page)
        super(url, page)
        @scrape_target = %w(#area-main #article article)
      end

      def data
        global = { 
          scraper_url: @url, 
          plan: {
            name: remove_plan_name_fluff( page.css("title").text ),
          }
        }

        wrapper.to_html.scan(titlecase_before_parens_with_details_regex).reject(&:blank?)
          .map{ |p| activity_data( p ).merge( global ) }
          .reject{ |h| !h[:place][:name] }.uniq{ |h|h[:place][:name] }
      end

      private

      def activity_data(activity)
        {
          place:{
            name: name(activity),
            street_address: activity.scan(after_parens_regex_find_address).flatten.first,
            phone: activity.scan(after_separator_regex_find_phone).flatten.first,
            website: activity.scan(a_regex_find_href).flatten.first,
            notes: clean_note( notes_for( name(activity) ) ),
            nearby: nearby
          }
        }
      end

      # OPERATIONS

      def name(activity_or_general)
        trim( de_tag( activity_or_general.scan(before_parens_regex_find_name).flatten.first ) )
      end

      def nearby
        split_by('h1', [["36 Hours in ", 1], ["36 Hours at the ", 1], ["36 Hours on ", 1], ["36 Hours | ", 1]]).gsub(/<.*>/, '')
      end

      memoize :name, :nearby
    end
  end
end