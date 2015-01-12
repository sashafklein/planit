module Scrapers
  module StayMod

    # PAGE SETUP

    class ItemReview < Stay

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
            phone: phone,
            category: category,
            images: images,
            lat: lat,
            lon: lon,
          },
        }.merge(global_data)]
      end

      # OPERATIONS

      def name
        trim( page.css(".venue-view").first.css("h1").first.text )
      rescue ; nil
      end

      def full_address
        trim( page.css(".venue-view").first.css(".address").first.text.gsub("(show map)", '') )
      rescue ; nil
      end

      def phone
        trim( page.css("strong:contains('Phone:')").first.next_element.text ) 
      rescue ; nil
      end

      def site_name
        "Stay"
      end

      def category
        category = []
        if @url.include?('/attractions/')
          category.push 'attraction'
        elsif @url.include?('/museum/')
          category.push 'museum'
        elsif @url.include?('/art-gallery/')
          category.push 'art gallery'
        elsif @url.include?('/shopping/')
          category.push 'shopping'
        elsif @url.include?('/health/')
          category.push 'health'
        elsif @url.include?('/entertainment/')
          category.push 'entertainment'
        elsif @url.include?('/cafe/')
          category.push 'cafe'
        elsif @url.include?('/bar-pub/')
          category.push 'bar-pub'
        elsif @url.include?('/nightclub/')
          category.push 'nightclub'
        elsif @url.include?('/restaurant/')
          category.push 'restaurant'
        elsif @url.include?('/hotel/')
          category.push 'hotel'
        end
      rescue ; nil
      end

      def images
        image_list = []
        container = first_css_match([".widget-gallery", ".gallery"])
        container.css("img").each do |img_in_container|
          if img_in_container.attribute('src')
            img_url = img_in_container.attribute('src').value
            if img_url
              image_list.push( { url: img_url, source: @url, credit: site_name } )
            end
          end
        end
        return image_list
      end

      def map_string
        container = first_css_match([".static-map"])
        if string = container.css("img").first.attribute("src").value
          return ( CGI.unescape( string ) ).scan(find_lat_lon_regex).flatten.first
        end
        return nil
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