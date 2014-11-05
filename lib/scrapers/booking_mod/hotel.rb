module Scrapers
  module BookingMod

    # PAGE SETUP

    class Hotel < Booking

      def initialize(url, page)
        super(url, page)
      end

      def global_data
        { 
          site_name: site_name,
          source_url: @url,
          ratings_base: 10,
        }
      end

      # PAGE 
      
      def data
        [{
          name: trim( de_tag( name ) ),
          full_address: trim( full_address ),
          street_address: street_address,
          locality: locality,
          region: region,
          neighborhood: neighborhood,
          country: country,
          category: category,
          rating: rating,
          images: images,
          lat: lat,
          lon: lon,
        }.merge(global_data)]
      end

      # OPERATIONS

      def name
        page.css("#hp_hotel_name").first.text ; rescue ; nil
      end

      def rating
        page.css("span.rating").css("span.average").first.text ; rescue ; nil
      end

      def star_rating
        page.css(".b-sprite.stars").first.attribute("title").value ; rescue ; nil
      end

      def full_address
        trim( page.css("#hp_address_subtitle").first.text )   ; rescue ; nil
      end

      def full_address_geocoded
        if @full_address_geocoded
          return @full_address_geocoded
        end
        @full_address_geocoded = Geocoder.search(full_address).first.data
      end

      def street_address
        if ( street_number && street_number.length > 0 ) || ( route && route.length > 0 )
          street_info = [street_number, route].join(" ")
          if ( subpremise && subpremise.length > 0 ) 
            apt_no = subpremise
            return [apt_no, street_info].join(", ")
          end
          return street_info
        end
        return nil
      end

      def subpremise
        full_address_geocoded['address_components'].find{ |h| h["types"].include? 'subpremise' }['long_name'] ; rescue ; nil
      end

      def street_number
        full_address_geocoded['address_components'].find{ |h| h["types"].include? 'street_number' }['long_name'] ; rescue ; nil
      end

      def route
        full_address_geocoded['address_components'].find{ |h| h["types"].include? 'route' }['long_name'] ; rescue ; nil
      end

      def neighborhood
        full_address_geocoded['address_components'].find{ |h| h["types"].include? 'sublocality_level_1' }['long_name'] ; rescue ; nil
      end

      def locality
        full_address_geocoded['address_components'].find{ |h| h["types"].include? 'locality' }['long_name'] ; rescue ; nil
      end

      def region
        full_address_geocoded['address_components'].find{ |h| h["types"].include? 'administrative_area_level_1' }['long_name'] ; rescue ; nil
      end

      def country
        full_address_geocoded['address_components'].find{ |h| h["types"].include? 'country' }['long_name'] ; rescue ; nil
      end

      def site_name
        "Booking.com"
      end

      def category
        "lodging"
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