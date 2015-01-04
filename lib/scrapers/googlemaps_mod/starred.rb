module Scrapers
  module GooglemapsMod

    # PAGE SETUP

    class Starred < Googlemaps

      def initialize(url, page)
        super(url, page)
      end

      def data
        @data = processed_links(text_query_array)
      end

      # OPERATIONS

      def text_query_array
        link_array = []
        page.css("a").each_with_index do |link, index|
          if link.attribute("href") && link.attribute("href").value
            if link.attribute("href").value.include?("maps.google.com/?")
              link_array << [
                link.text, 
                URI.escape( link.attribute("href").value ) + "&output=json", 
              ]
            end
          end
        end       
        return link_array
      end

      def processed_links(link_array)
        @data = []
        link_array.each do |each_link|
          if each_link[1].include?("?cid=")
            # IF GOOGLE PROVIDES CLEAR CID LINK
            json = open( URI.parse( each_link[1].gsub("http://", "https://") ) ).read if each_link[1]
            return {} unless json
            link_name = each_link.first unless each_link.first.scan(/[-.,0-9 ]*/).flatten.first
            names = [unhex( trim( json.scan(/infoWindow\:\{title:\"(.*?)\"/).flatten.first ) ), unhex( trim( each_link.first ) )].compact.uniq
            address_lines = json.scan(/infoWindow\:\{.*addressLines\:\[(.*?)\]/).flatten.first
            full_address = address_lines.gsub('","', ', ').gsub('"', '') if address_lines
            locality = json.scan(/sxct\:\"(.*?)\"/).flatten.first
            region = json.scan(/sxpr\:\"(.*?)\"/).flatten.first
            postal_code = json.scan(/sxpo\:\"(.*?)\"/).flatten.first
            country_code = json.scan(/sxcn\:\"(.*?)\"/).flatten.first
            country = find_country_by_code(country_code) if country_code
            street_address = trim_full_to_street_address(full_address, country, postal_code, region, locality, names.first)
            website = json.scan(/actual_url\:\"(.*?)\"/).flatten.first
            phone = json.scan(/infoWindow\:\{.*phones\:\[\{number\:\"(.*?)\"\}\]/).flatten.first
            lat = json.scan(/viewport\:{center:{lat\:([-]?\d+\.\d+),/).flatten.first
            lon = json.scan(/viewport\:{center:{lat\:[-]?\d+\.\d+,lng\:([-]?\d+\.\d+)/).flatten.first
            images = nil
            original_photo = json.scan(/photoUrl\:\"(.*?)\"/).flatten.first
            if original_photo 
              if original_photo.scan("logo.").flatten.first != "logo."
                photo = unhex( original_photo )
                # EDIT UP SIZE BY ONE ZERO
                photo = photo.gsub(/\/s(\d\d)\//, "/s\\1"+"0/") unless !photo
                photo = photo.gsub(/\&w\=(\d\d)\&/, "&w=\\1"+"0&") unless !photo
                photo = photo.gsub(/\&h\=(\d\d)\&/, "&h=\\1"+"0&") unless !photo
                photo = photo.gsub(/\&zoom\=0/, "&zoom=3") unless !photo
                images = [{ url: photo, source: 'Google', credit: 'Google' }]
              end
            end
            if lat.present? && lon.present? && ( locality.present? || region.present? || postal_code.present? || country_code.present? || street_address.present? || website.present? || phone.present? )
              # REJECT IF GOOGLE RETURNS A BULLSHIT RESPONSE (NO DATA)
              @data << {
                place:{
                  names: names,
                  full_address: unhex( trim( full_address ) ),
                  street_address: unhex( street_address ),
                  locality: unhex( locality ),
                  region: unhex( region ),
                  country: unhex( country ),
                  postal_code: unhex( postal_code ),
                  website: unhex( website ),
                  phone: trim( phone ),
                  images: images,
                  lat: lat,
                  lon: lon,
                },
              }
            end
          elsif latlon = each_link[1].scan(/(?:\/\?q=|maps\?q=)([-]?\d+\.\d+[,][-]?\d+\.\d+)(?:[&]|\Z)/).flatten.first
            # IF GOOGLE LINK PROVIDES LAT/LON AS IS
            if !each_link.first.scan(/[-.,0-9 ]*/).flatten.first # no result if only lat/lon
              name = unhex( trim( each_link.first ) ) 
              lat = latlon.split(",")[0]
              lon = latlon.split(",")[1]
              data << {
                place:{
                  name: name,
                  lat: lat,
                  lon: lon,
                },
              }
            end
          # elsif each_link[1].include?("ftid=")
          #   FEATURE / FTID MEANS NOT A POINT BUT AN AREA
          # else
          #   IF 'LINK TEXT' REPRESENTS NAME AND FULL ADDRESS, LINK Q= MAY ALSO -- REVISIT POST-BETA
          #   string = unhex( trim( each_link.first ) )
          #   country = find_country_at_end_of_string( string )
          #   region = find_region_at_end_of_string( trim( string.gsub(/(?:\s*[,.;]?\s*#{generous_postal_code_regex})?\s*[,.;]?\s*#{country}/, '') ), country) if country
          #   locality = find_locality_at_end_of_string( trim( string.gsub(/\s*[,.;]?\s*#{region}/, '') ) ) if region
          #   locality ||= find_locality( string )
          #   name = nil
          #   {
          #     place:{
          #       name: name,
          #       locality: locality,
          #       region: region,
          #       country: country,
          #     },
          #   }
          end
        end
        return @data

      end

    end
  end
end