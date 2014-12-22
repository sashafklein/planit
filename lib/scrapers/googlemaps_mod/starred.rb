module Scrapers
  module GooglemapsMod

    # PAGE SETUP

    class Starred < Googlemaps

      def initialize(url, page)
        super(url, page)
      end

      # OPERATIONS

      def global_data
        {
        }
      end

      def activity_group(section)
        json_list = []
        page.css("a").each_with_index do |link, index|
          if link.attribute("href") && link.attribute("href").value
            if link.attribute("href").value.include?("maps.google.com/?cid=")
              link_text = link.text
              raw_href = link.attribute("href").value
              link_query = raw_href + "&output=json"
              json_list << [link_text, link_query]
            end
          end
        end       
        return json_list
      end

      def activity_data(activity, activity_index)

        uri = URI.parse(activity.last.gsub("http://", "https://"))

        file = open(uri)
        json = file.read

        name = json.scan(/infoWindow\:\{title:\"(.*?)\"/).flatten.first
        address_lines = json.scan(/infoWindow\:\{.*addressLines\:\[(.*?)\]/).flatten.first
        if address_lines
          full_address = address_lines.gsub('","', ', ').gsub('"', '')
        end
        locality = json.scan(/sxct\:\"(.*?)\"/).flatten.first
        region = json.scan(/sxpr\:\"(.*?)\"/).flatten.first
        postal_code = json.scan(/sxpo\:\"(.*?)\"/).flatten.first
        country_code = json.scan(/sxcn\:\"(.*?)\"/).flatten.first
        country = find_country_by_code(country_code)
        street_address = trim_full_to_street_address(full_address, country, postal_code, region, locality, name)
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
        {
          place:{
            name: unhex( trim( name ) ),
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

    end
  end
end