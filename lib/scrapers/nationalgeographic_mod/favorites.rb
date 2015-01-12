module Scrapers
  module NationalgeographicMod

    # PAGE SETUP

    class Favorites < Nationalgeographic

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
            name: name,
            full_address: full_address,
            # images: images,
            lat: lat,
            lon: lon,
          },
          scraper_url: @url, 
        }.merge(global_data)]
      end

      # OPERATIONS

      def name
        attempt = trim( page.css("header").first.css('h1').first.text )
      rescue ; nil
      end

      def full_address
        attempt = trim( page.css("header").first.css("p.meta.location").first.text )
      rescue ; nil
      end

      def site_name
        "National Geographic"
      end

      def map_string
        script = page.css("script:contains('maps.LatLng')").first.inner_html
        string = script.scan(find_lat_lon_in_script_format_center_colon).flatten.first
        return string.gsub("'", '').gsub('"', '').gsub(" ", '')
      end

      def lat
        trim( map_string.split(",")[0] ) ; rescue ; nil
      end

      def lon
        trim( map_string.split(",")[1] ) ; rescue ; nil
      end

      # def images
      #   image_list = []
      #   if container = first_css_match(["article"])
      #     container.css("img").each do |img_in_container|
      #       if img_in_container.attribute('src')
      #         img_url = img_in_container.attribute('src').value
      #       end
      #       if img_url
      #         image_list.push( { url: img_url, source: @url, credit: site_name } )
      #       end
      #     end
      #   end
      #   if image_list.length > 0 
      #     return image_list
      #   else
      #     return nil
      #   end
      # end

    end
  end
end