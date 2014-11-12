module Scrapers
  module AfarMod

    # PAGE SETUP

    class SingleItem < Afar

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
        binding.pry
        [{
          name: name,
          street_address: street_address,
          locality: locality,
          region: region,
          country: country,
          website: website,
          images: images,
          lat: lat,
          lon: lon,
        }.merge(global_data)]
      end

      # OPERATIONS

      def name
        attempt = trim( page.css("h1").first.text )
        attempt ||= trim( page.css("#detail-place").first.css(".place-title").first.text )
      rescue ; nil
      end

      def full_address
        attempt = trim( page.css(".place-address").first.text )
        attempt ||= trim( page.css(".address").first.text )
      rescue ; nil
      end

      def website
        attempt = page.css("a[data-google-action='Clicked external URL']").first.attribute("href").value
        attempt ||= page.css("div.title:contains('Website')").next_element.css("a").first.attribute("href").value
      rescue ; nil
      end

      def street_address
        #NEEDSFOLLOWUP
      end

      def phone
        trim( page.css("div.title:contains('Phone')").first.next_element.inner_html ) ; rescue ; nil
      end

      def hours
        trim( page.css("dt:contains('Opening hours')").first.next_element.text ) ; rescue ; nil
      end

      def locality
        #NEEDSFOLLOWUP
      end

      def country
        find_country(full_address) ; rescue ; nil
      end

      def region
        find_region(full_address, country) ; rescue ; nil
      end

      def site_name
        "AFAR"
      end

      def map_string
        if map_area = page.css(".map")
          string = map_area.first.css("a").first.attribute("href").value
        elsif map_area = page.css(".map-details")
          string = map_area.first.css("a").first.attribute("href").value
        end
        if string.include?("&q=")
          return string.split("&q=")[1]
        end
      end

      def lat
        map_string.split(",")[0] ; rescue ; nil
      end

      def lon
        map_string.split(",")[1] ; rescue ; nil
      end

      def images
        image_list = []
        if container = first_css_match([".super-slick-container", ".slick-slide", "ul.slides"])
          container.css("img").each do |img_in_container|
            if img_in_container.attribute('src')
              unless img_in_container.attribute('src').value.include?("maps")
                img_url = img_in_container.attribute('src').value
              end
            end
            if img_url
              image_list.push( { url: img_url, source: @url, credit: site_name } )
            end
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