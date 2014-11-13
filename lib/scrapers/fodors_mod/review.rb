module Scrapers
  module FodorsMod

    # PAGE SETUP

    class Review < Fodors

      def initialize(url, page)
        super(url, page)
      end

      def global_data
        { 
          # site_name: site_name,
          # source_url: @url,
        }
      end

      # PAGE 
      
      def data
        [{
            place:{
            name: trim( name ),
            full_address: trim( full_address ),
            phone: phone,
            website: website,
            category: category,
            hours_note: hours_note,
            price_note: price_note,
            ratings:{
              ranking: ranking,
              site_name: site_name,
            },
            lat: lat,
            lon: lon,
          }
        }.merge(global_data)]
      end

      # OPERATIONS

      def name
        page.css("h1.poi-title").first.text ; rescue ; nil
      end

      def full_address
        trim( page.css(".poi-info-title:contains('Address:')").first.next_element.text ) ; rescue ; nil
      end

      def phone
        trim( page.css(".poi-info-title:contains('Phone')").first.next_element.text ) ; rescue ; nil
      end

      def sight_details
        page.css(".poi-info-title:contains('Sight Details')").first.parent.next_element.children
      rescue ; nil
      end

      def hours_note
        if sight_details && sight_details.length > 0
          sight_details.each do |detail|
            if opening = detail.text.include?("Mon"||"Tue"||"Wed"||"Thu"||"Fri"||"Sat"||"Sun")
              return trim( detail.text )
            end
          end
        end
      rescue ; nil
      end

      def price_note
        if sight_details && sight_details.length > 0
          sight_details.each do |detail|
            if opening = detail.text.include?("Free"||"$"||"€")
              return trim( detail.text )
            end
          end
        end
      rescue ; nil
      end

      def website
        page.css('.poi-info-website').first.css('a').first.attribute('href').value ; rescue ; nil
      end

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