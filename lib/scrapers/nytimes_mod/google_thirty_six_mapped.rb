module Scrapers
  module NytimesMod

    # PAGE SETUP

    class GoogleThirtySixMapped < Nytimes
      
      def initialize(url, page)
        super(url, page)
        @scrape_target = %w(#story-body #area-main #article article)
      end

      def data
        activity_group_array.map do |element| 
          final = global_data.dup
          final[:place] = final[:place].merge(element).merge({ notes: notes_for( element[:name] )})
          final[:place][:notes] = notes_for( final[:place][:name] )
          final
        end.reject{ |e| e[:place][:name].blank? }
      end

      private

      def global_data
        { 
          plan:{
            name: remove_plan_name_fluff( page.css("title").text ),
          },
          place:{
            nearby: split_by('h1', [["What to Do in ", 1], ["36 Hours in ", 1], ["36 Hours at the ", 1], ["36 Hours on ", 1], ["36 Hours | ", 1]]),
          },
          scraper_url: @url
        }
      end

      # PAGE 

      def activity_group_array
        return nil unless has_map_data?

        map_hash[:symbols].map do |symbol|
          [:name, :website, :lat, :lon, :street_address, :phone].inject({}) do |hash, key|
            hash[key] = send("#{ key }_in_data_hash", symbol[:data])
            hash
          end
        end
      end

      # OPERATIONS

      def find_by_attr(hash, name_search, att=:name)
        hash.find{ |h| h[att] == name_search }
      end

      def has_map_data?
        find_scripts_inner_html(page).each do |script|
          if script.flatten.first.scan(nytimes_map_data_regex).length > 0
            @map_data = script.flatten.first.scan(nytimes_map_data_regex).flatten.first
            return true
          end
        end
        false
      end

      def name_in_data_hash(data)
        trim( breakline_to_space( find_by_attr(data, 'label')[:text] ) )
      end

      def website_in_data_hash(data)
        hash = find_by_attr(data, 'popup')
        hash ? hash[:body].strip.scan(find_website_after_n).flatten.first : nil
      end

      def lat_in_data_hash(data)
        hash = find_by_attr(data, 'root')
        hash ? hash[:location][:lat]: nil
      end

      def lon_in_data_hash(data)
        hash = find_by_attr(data, 'root')
        hash ? hash[:location][:lng]: nil
      end

      def phone_in_data_hash(data)
        hash = find_by_attr(data, 'popup')
        hash ? hash[:body].strip.scan(find_phone_after_n).flatten.first : nil
      end

      def order_in_data_hash(data)
        hash = find_by_attr(data, 'bubble_number')
        hash ? hash[:text]: nil
      end

      def street_address_in_data_hash(data)
        hash = find_by_attr(data, 'popup')
        hash ? hash[:body].strip.scan(find_address_after_n).flatten.first : nil
      end

      def notes_for(name)
        named_popup = map_popups.find{ |p| p.text.without_common_symbols.to_s.match_distance(name.without_common_symbols) > 0.95 }
        named_popup ? clean_note( named_popup.next.children.first.text.strip ) : nil
      rescue
        nil
      end

      def map_popups
        wrapper.css(".g-popup-title")
      end

      def map_hash
        @map_hash || JSON.parse(@map_data,:symbolize_names => true)
      end

      memoize :activity_group_array, :lat_in_data_hash, :lon_in_data_hash, :website_in_data_hash, :street_address_in_data_hash, :phone_in_data_hash, :order_in_data_hash, :name_in_data_hash, :global_data, :data, :map_popups, :notes_for
    end
  end
end

