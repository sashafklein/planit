module Scrapers
  module EaterMod

    # PAGE SETUP

    class Heatmap < Eater

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
        current_tab
        [{
          name: name,
          full_address: full_address,
          street_address: street_address,
          locality: locality,
          region: region,
          country: country,
          website: website,
          phone: phone,
          images: images,
          lat: lat,
          lon: lon,
        }.merge(global_data)]
      end

      # OPERATIONS

      def current_tab
        if @current_tab && @current_tab.length > 0
          return @current_tab
        end
        url_name = url.scan(/.*\/(.*?)\z/).flatten.first.gsub("-", ' ')
        name_matches = page.css(".m-map-point-title")
        name_matches.each do |match|
          if no_accents( (match.inner_html) ).downcase.include?(url_name)
            return @current_tab = match.parent.parent.parent
          end
        end
      end

      def name
        attempt = @current_tab.attribute("data-name").value
      rescue ; nil
      end

      def full_address
        address_string = []
        @current_tab.css(".address-text").each do |address_line|
          address_string.push address_line
        end
        address_string.join(", ")
      rescue ; nil
      end

      def phone
        @current_tab.css(".phone").first.text
      rescue ; nil
      end

      def website
        @current_tab.css(".url:contains('Visit website')").first.css("a").first.attribute("href").value
      rescue ; nil
      end

      def street_address
        #NEEDSFOLLOWUP
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
        "Eater"
      end

      def lat
        attempt = trim( @current_tab.attribute("data-coordinates").value.split(",")[0] )
      rescue ; nil
      end

      def lon
        attempt = trim( @current_tab.attribute("data-coordinates").value.split(",")[1] )
      rescue ; nil
      end

      def images
        image_list = []
        binding.pry
        string = @current_tab.css(".m-map-point-image").first.attribute("style").value
        img_url = string.scan(find_background_image_url_regex).flatten.first
        if img_url
          image_list.push( { url: img_url, source: @url, credit: site_name } )
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