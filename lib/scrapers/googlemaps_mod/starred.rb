module Scrapers
  module GooglemapsMod

    # PAGE SETUP

    class Starred < Googlemaps

      def initialize(url, page)
        super(url, page)
      end

      def data
        @json_request = 0
        processed_links(text_query_array)
      end

      # OPERATIONS

      def text_query_array
        link_array = []
        page.css("a").each_with_index do |link, index|
          if link.attribute("href") && link.attribute("href").value
            if link.attribute("href").value.include?("maps.google.com/?")
              link_array << {
                text: link.text, 
                href: URI.escape( link.attribute("href").value ) + "&output=json", 
              }
            end
          end
        end
        # page.inner_html.scan(/([<]a href[=].*?[>].*?[<]\/a[>])/).flatten.each_with_index do |link, index|
        #   if gmaps_link = link.scan(/HREF[=]["](http[:]\/\/maps.google.com\/.*?)["]/).flatten.first
        #     link_array << {
        #       text: link.scan(/[<]A HREF[=].*?[>](.*?)[<]\/A[>]/).flatten.first,
        #       href: URI.escape( gmaps_link ) + "&output=json",
        #     }
        #   end
        # end
        # binding.pry
        return link_array
      end

      def processed_links(link_array)
        processed_array = []
        link_array.each do |each_link|
          if each_link[:text].include?("El Coro Lounge Bar")
            binding.pry
          end
          if each_link[:href].include?("?cid=")
            processed_array << google_clear_cid_hash(each_link)
          elsif latlon = each_link[:href].scan(/(?:\/\?q=|maps\?q=)([-]?\d+\.\d+[,][-]?\d+\.\d+)(?:[&]|\Z)/).flatten.first
            # IF GOOGLE LINK PROVIDES LAT/LON AS IS
            if !each_link[:text].scan(/[-.,0-9 ]*/).flatten.first # no result if only lat/lon
              processed_array << google_clear_latlon_hash(each_link)
            end
          # elsif each_link[:href].include?("ftid=")
          #   FEATURE / FTID MEANS NOT A POINT BUT AN AREA
          # else
          #   IF 'LINK TEXT' REPRESENTS NAME AND FULL ADDRESS, LINK Q= MAY ALSO -- REVISIT POST-BETA
          end
          clear_instance_variables
        end
        return processed_array.compact
      end

      # 

      def google_clear_cid_hash(each_link)
        json = get_json_output(each_link)
        return nil unless json
        if lat(json).present? && lon(json).present? && ( locality(json).present? || region(json).present? || postal_code(json).present? || country_code(json).present? || street_address(json, each_link).present? || website(json).present? || phone(json).present? )
          # REJECT IF GOOGLE RETURNS A BULLSHIT RESPONSE (NO DATA)
          return {
            place:{
              names: names(json, each_link),
              full_address: unhex( trim( full_address(json) ) ),
              street_address: unhex( street_address(json, each_link) ),
              locality: unhex( locality(json) ),
              region: unhex( region(json) ),
              country: unhex( country(json) ),
              postal_code: unhex( postal_code(json) ),
              website: unhex( website(json) ),
              phone: trim( phone(json) ),
              images: images(json),
              lat: lat(json),
              lon: lon(json),
            },
          }
        end
        return nil
      end

      def google_clear_latlon_hash(each_link)
        {
          place:{
            name: unhex( trim( each_link[:text] ) ) ,
            lat: latlon.split(",")[0],
            lon: latlon.split(",")[1],
          },
        }
      end

      def get_json_output(each_link)
        @json_request += 1
        if @json_request == 50
          # sleep(15)
          @json_request = 0
        end
        open( URI.parse( each_link[:href].gsub("http://", "https://") ) ).read if each_link[:href]
      end

      def names(json, each_link)          
        @names ||= [ unhex( trim( json.scan(/infoWindow\:\{title:\"(.*?)\"/).flatten.first ) ), link_name(each_link) ].compact.uniq
      end

      def full_address(json)
        @full_address ||= address_lines(json).gsub('","', ', ').gsub('"', '') if address_lines(json)
      end

      def locality(json)          
        @locality ||= json.scan(/sxct\:\"(.*?)\"/).flatten.first
      end

      def region(json)          
        @region ||= json.scan(/sxpr\:\"(.*?)\"/).flatten.first
      end

      def postal_code(json)          
        @postal_code ||= json.scan(/sxpo\:\"(.*?)\"/).flatten.first
      end

      def country(json)          
        @country ||= find_country_by_code(country_code(json)) if country_code(json)
      end

      def street_address(json, each_link)          
        @street_address ||= trim_full_to_street_address(full_address(json), country(json), postal_code(json), region(json), locality(json), names(json, each_link).first)
      end

      def website(json)          
        @website ||= json.scan(/actual_url\:\"(.*?)\"/).flatten.first
      end

      def phone(json)          
        @phone ||= json.scan(/infoWindow\:\{.*phones\:\[\{number\:\"(.*?)\"\}\]/).flatten.first
      end

      def lat(json)          
        @lat ||= json.scan(/viewport\:{center:{lat\:([-]?\d+\.\d+),/).flatten.first
        @lat ||= json.scan(/https[:]\/\/.*?\.google\.com\/cbk\?output[=]thumbnail.*?ll=([-]?\d+\.\d+)\,[-]?\d+\.\d+/).flatten.first
      end

      def lon(json)            
        @lon ||= json.scan(/viewport\:{center:{lat\:[-]?\d+\.\d+,lng\:([-]?\d+\.\d+)/).flatten.first
        @lon ||= json.scan(/https[:]\/\/.*?\.google\.com\/cbk\?output[=]thumbnail.*?ll=[-]?\d+\.\d+\,([-]?\d+\.\d+)/).flatten.first
      end

      def images(json)
        if original_photo = original_photo(json)
          if original_photo.scan("logo.").flatten.first != "logo."
            photo = unhex( original_photo )
            # EDIT UP SIZE BY ONE ZERO
            photo = photo.gsub(/\/s(\d\d)\//, "/s\\1"+"0/") unless !photo
            photo = photo.gsub(/\&w\=(\d\d)\&/, "&w=\\1"+"0&") unless !photo
            photo = photo.gsub(/\&h\=(\d\d)\&/, "&h=\\1"+"0&") unless !photo
            photo = photo.gsub(/\&zoom\=0/, "&zoom=3") unless !photo
            [{ url: photo, source: unhex( original_photo ), credit: 'Google' }]
          end
        end
      end

      private

      def original_photo(json)          
        @original_photo ||= json.scan(/photoUrl\:\"(.*?)\"/).flatten.first
      end

      def link_name(each_link)
        @link_name ||= unhex( trim( each_link[:text] ) ) unless each_link[:text].scan(/\A[-.,0-9 ]*\Z/).flatten.first
      end

      def address_lines(json)            
        @address_lines ||= json.scan(/infoWindow\:\{.*addressLines\:\[(.*?)\]/).flatten.first
      end

      def country_code(json)          
        @country_code ||= json.scan(/sxcn\:\"(.*?)\"/).flatten.first
      end

      def clear_instance_variables
        @names, @full_address, @street_address, @locality, @region, @country, @postal_code, @website, @phone, @images, @lat, @lon, @country_code, @original_photo, @link_name, @address_lines = nil
      end

    end
  end
end