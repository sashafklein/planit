module Scrapers
  module FodorsMod

    # PAGE SETUP

    class Review < Fodors

      def initialize(url, page)
        super(url, page)
      end

      def global_data
        { 
          site_name: site_name,
          source_url: @url,
        }
      end

      # PAGE 
      
      def data
        # binding.pry
        [{
          name: trim( name ),
          full_address: trim( full_address ),
          # street_address: street_address,
          # locality: locality,
          # hours: hours,
          # price_note: price_note,
          region: region,
          # postal_code: postal_code,
          country: country,
          phone: phone,
          website: website,
          category: category,
          ranking: ranking,
          lat: lat,
          lon: lon,
        }.merge(global_data)]
      end

      # OPERATIONS

      def name
        page.css("h1.poi-title").first.text ; rescue ; nil
      end

      def full_address
        trim( page.css("p.poi-info-title:contains('Address:')").first.next_element.text ) ; rescue ; nil
      end

      def phone
        trim( page.css("p.poi-info-title:contains('Phone')").first.next_element.text ) ; rescue ; nil
      end

      def website
        page.css('div.poi-info-website').first.css('a').first.attribute('href').value ; rescue ; nil
      end

      def country
        find_country(full_address)
      end

      def region
        find_region(city_and_country, country) ; rescue ; nil
      end

      # def street_address
      #   raw_address = full_address
      #   if region
      #     raw_address = raw_address.gsub(region, '')
      #   end
      #   if country
      #     raw_address = raw_address.gsub(country, '')
      #   end
      #   return raw_address
      # end

      # def locality
      #   raw_address = full_address
      #   if region
      #     raw_address = raw_address.gsub(region, '')
      #   end
      #   if country
      #     raw_address = raw_address.gsub(country, '')
      #   end
      #   return raw_address
      # end

      # def postal_code
      #   raw_address = full_address
      #   if region
      #     raw_address = raw_address.gsub(region, '')
      #   end
      #   if country
      #     raw_address = raw_address.gsub(country, '')
      #   end
      #   return raw_address
      # end

      def site_name
        "Fodor's"
      end

      def category
        category = []
        category = tags.delete_if {|i| i == "Fodor's Choice"}
      end

      def ranking
        tags.find{ |tag| tag.include?("Fodor's Choice") }
      end

      def tags
        tag_list = page.css('.poi-review-container').first.css('.poi-tag')
        tags = []
        if tag_list.length > 1
          tag_list.each do |tag|
            tags.push trim( tag.text )
          end
        else
          tags.push trim( page.css('.poi-review-container').first.css('.poi-tag').flatten.first.text )
        end
        return tags
      end

      def map_string        
        container = page.css("script:contains('://maps.google.com/maps')").first.inner_html
        find_lat_lon_string_in_script(container)
      end

      def lat
        map_string.split(",")[0] ; rescue ; nil
      end

      def lon
        map_string.split(",")[1] ; rescue ; nil
      end

    end
  end
end