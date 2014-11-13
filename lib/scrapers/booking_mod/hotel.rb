module Scrapers
  module BookingMod

    # PAGE SETUP

    class Hotel < Booking

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
            name: trim( de_tag( name ) ),
            full_address: trim( full_address ),
            category: category,
            ratings: [{ 
              rating: rating,
              site_name: site_name,
            }],
            images: images,
            lat: lat,
            lon: lon,
          }
        }.merge(global_data)]
      end

      # OPERATIONS

      def name
        page.css("#hp_hotel_name").first.text ; rescue ; nil
      end

      def rating
        calculate_rating( page.css("span.rating").css("span.average").first.text , 10 )
      rescue ; nil
      end

      def star_rating
        page.css(".b-sprite.stars").first.attribute("title").value ; rescue ; nil
      end

      def full_address
        trim( page.css("#hp_address_subtitle").first.text )   ; rescue ; nil
      end

      def site_name
        "Booking.com"
      end

      def category
        ["lodging"]
      end

      def map_string
        container = page.css('.map_static_zoom').first
        container.css('.static_map_one').attribute('src').value
      end

      def lat
        map_string.split("center=")[1].split("&")[0].split(",")[0] ; rescue ; nil
      end

      def lon
        map_string.split("center=")[1].split("&")[0].split(",")[1] ; rescue ; nil
      end

      def images
        image_list = []
        container = page.css('script:contains("slideshow_photos")').first.inner_html
        imgs_in_container = container.scan(photos_with_image_folder).flatten
        imgs_in_container.each do |img_url|
          image_list.push( { url: img_url, source: @url, credit: site_name } )
        end
        return image_list
      end

    end
  end
end