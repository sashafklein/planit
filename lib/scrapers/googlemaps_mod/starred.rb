module Scrapers
  module GooglemapsMod

    # PAGE SETUP

    class Starred < Googlemaps

      delegate :names, :full_address, :street_address, :locality, :region, :country, :country_code,
               :postal_code, :website, :phone, :images, :lat, :lon, to: :bsjson

      attr_reader :bsjson
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
        return link_array
      end

      def processed_links(link_array)
        processed_array = []
        link_array.each do |each_link|
          if each_link[:text].include?("El Coro Lounge Bar")
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
        end
        return processed_array.compact
      end

      # 

      def google_clear_cid_hash(each_link)
        json = get_json_output(each_link)
        return nil unless json
        if lat && lon && ( locality || region || postal_code || country_code || street_address.present? || website || phone )
          # REJECT IF GOOGLE RETURNS A BULLSHIT RESPONSE (NO DATA)
          return {
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
            scraper_url: @url,
            # USERNAME
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
          scraper_url: @url,
          # USERNAME
        }
      end

      def get_json_output(each_link)
        @json_request += 1
        if @json_request == 50
          # sleep(15)
          @json_request = 0
        end

        if each_link[:href]
          @bsjson = g_map.get_venues( each_link[:href].gsub("http://", "https://"), each_link[:text] ).first
        else
          @bsjson = SuperHash.new
        end
      end

      def g_map
        Completers::ApiCompleter::GoogleMaps.new({}, {})
      end

    end
  end
end