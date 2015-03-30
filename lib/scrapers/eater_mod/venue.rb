module Scrapers
  module EaterMod

    # PAGE SETUP

    class Venue < Eater

      def initialize(url, page)
        super(url, page)
      end

      def global_data
        { 
          scraper_url: @url,
        }
      end

      # PAGE 
      
      def data
        [{
          place:{
            name: name,
            full_address: full_address,
            website: website,
            # phone: phone,
            images: images,
            lat: lat,
            lon: lon,
          },
        }.merge(global_data)]
      end

      # OPERATIONS

      def name
        attempt = trim( page.css(".m-venue-hero").first.css('h1').first.text )
      rescue ; nil
      end

      def full_address
        attempt = trim( page.css(".m-venue-hero").first.css('h1').first.next_element.text )
      rescue ; nil
      end

      # Doesn't seem to be working
      # def phone
      #   attempt = trim( page.css(".m-venue-hero").first.css('h1').first.next_element.next_element.text )
      # rescue ; nil
      # end

      def website
        attempt = page.css(".m-venue-hero").first.css("a:contains('Visit Website')").first.attribute("href").value
      rescue ; nil
      end

      def site_name
        "Eater"
      end

      def map_string
        if map_area = page.css(".m-venue-hero").first.css(".m-chorus-simplemap")
          string = map_area.first.attribute("data-simplemap-latlong").value
        end
        if string.include?("[")
          string = string.split("[")[1]
          if string.include?("]")
            return string.split("]")[0]
          end
        end
      end

      def lat
        trim( map_string.split(",")[0] ) ; rescue ; nil
      end

      def lon
        trim( map_string.split(",")[1] ) ; rescue ; nil
      end

      def images
        image_list = []
        if container = first_css_match([".m-venue-hero__image"])
          string = container.attribute("style").value
          img_url = string.scan(find_background_image_url_regex).flatten.first
          if img_url
            image_list.push( { url: img_url, source: @url, credit: site_name } )
          end
        end
        if image_list.length > 0 
          return image_list
        else
          return nil
        end
      end

    end
  end
end