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
          scraper_url: @url
        }
      end

      # PAGE 

      def activity_group_array
        if legend_header
          legend_header.parent.children.map(&:inner_html).select{ |e| e.scan(/\d+(?:<strong>)*\./).any? }
        else
          []
        end
      end        

      def activity_data(activity)
        {
          place:{
            name: name( activity ),
            street_address: street_address( activity ),
            website: website( activity ),
            notes: clean_note( notes_for( name( activity ) ) ),
            nearby: nearby
          }
        }
      end

      # NEEDS TO BE MORE STRINGENT
      def legend_header
        possible_headers = ["the basics", "the details", "if you go", "lodging"]

        css('p').find do |e| 
          possible_headers.find{ |h| e.inner_html.downcase.include?(h) }
        end
      end

      def name(activity)
        trim( de_tag( activity.scan(strong_details_regex_find_name).flatten.first ) ) || 
          Nokogiri.parse(activity).css('strong').first.text.split(/\d+\.\s*\W*/).last.try(:strip)
      end

      def street_address(activity)
        first_guess = trim( activity.scan(strong_details_regex_find_address_phone).flatten.first )
        return first_guess if first_guess
        activity.split(/<\/strong>(?:\W|\D)*/).last.split("<a").first.gsub(/[;|,|.]\s*$/, '')
      rescue
        nil
      end

      def website( activity )
        activity.scan(a_regex_find_href).flatten.first
      end

      def nearby
        split_by('h1', [["36 Hours in ", 1], ["36 Hours at the ", 1], ["36 Hours on ", 1], ["36 Hours | ", 1]])
      end

      memoize :name, :nearby, :legend_header, :activity_group_array
    end
  end
end

