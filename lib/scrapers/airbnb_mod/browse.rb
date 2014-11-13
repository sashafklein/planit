module Scrapers
  module AirbnbMod

    # PAGE SETUP

    class Browse < Airbnb

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
          place: {
            name: trim( de_tag( name ) ) + " (Airbnb)",
            nearby: nearby,
            category: category,
            lat: lat,
            lon: lon,
            images: images,
          }
        }.merge(global_data)]
      end

      # OPERATIONS

      def name
        page.css("h1#listing_name").first.text ; rescue ; nil
      end

      def nearby
        trim( page.css("#display-address").first.css("a[@href='#neighborhood']").first.text ) ; rescue ; nil
      end

      def images
        image_list = []
        container = first_css_match([".slideshow-images"])
        container.css("img").each do |img_in_container|
          if img_in_container.attribute('src')
            img_url = img_in_container.attribute('src').value
          elsif img_in_container.attribute('id')          
            img_url = lazy_load_find_by_id(img_in_container.attribute('id').value, '\\"id\\":\\"', '\\".*?\\"data\\":\\"([^"]*)\\"')
          end
          if img_url
            image_list.push( { url: img_url, source: @url, credit: site_name } )
          end
        end
        return image_list
      end

      def site_name
        "Airbnb"
      end

      def category
        ["lodging"]
      end

      def map_container
        page.css('.location-panel').css('#map').first ; rescue ; nil
      end

      def lat
        map_container.attribute('data-lat').value ; rescue ; nil
      end

      def lon
        map_container.attribute('data-lng').value ; rescue ; nil
      end

    end
  end
end