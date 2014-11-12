module Scrapers
  module EaterMod

    # PAGE SETUP

    class Review < Eater

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
          full_address: full_address,
          street_address: street_address,
          locality: locality,
          region: region,
          country: country,
          website: website,
          phone: phone,
          price_note: price_note,
          images: images,
          # lat: lat,
          # lon: lon,
        }.merge(global_data)]
      end

      # OPERATIONS

      def name
        attempt = trim( page.css(".m-review-scratch__venue").first.css('h1').first.text )
      rescue ; nil
      end

      def full_address
        attempt = trim( page.css(".m-review-scratch__contact-group").first.text )
      rescue ; nil
      end

      def phone
        attempt = trim( page.css(".m-venue-hero").first.css('h1').first.next_element.next_element.text )
      rescue ; nil
      end

      def website
        #NEEDSFOLLOWUP
      end

      def street_address
        #NEEDSFOLLOWUP
      end

      def locality
        #NEEDSFOLLOWUP
      end

      def price_note
        attempt = trim( de_tag( page.css("dt:contains('Cost')").first.next_element.inner_html ) )
      rescue ; nil
      end

      def country
        find_country(full_address) ; rescue ; nil
      end

      def region
        find_region(full_address, country) ; rescue ; nil
      end

      def site_name
        "Eater"
      end

      # def map_string
      #   if map_area = page.css(".m-venue-hero").first.css(".m-chorus-simplemap")
      #     string = map_area.first.attribute("data-simplemap-latlong").value
      #   end
      #   if string.include?("[")
      #     string = string.split("[")[1]
      #     if string.include?("]")
      #       return string.split("]")[0]
      #     end
      #   end
      # end

      # def lat
      #   trim( map_string.split(",")[0] ) ; rescue ; nil
      # end

      # def lon
      #   trim( map_string.split(",")[1] ) ; rescue ; nil
      # end

      def images
        image_list = []
        cover = ".l-review-head__image-cover"
        if data = page.css(cover).attribute('data-original')
          img_url = data.value
          if img_url
            image_list.push( { url: img_url, source: @url, credit: site_name } )
          end
        end          
        container = first_css_match([".m-feature-body__center-col"])
        container.css("img").each do |img_in_container|
          if data = img_in_container.attribute('data-original')
            img_url = data.value
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