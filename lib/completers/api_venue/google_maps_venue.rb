module Completers
  class ApiVenue::GoogleMapsVenue < ApiVenue

    include ScraperOperators
    include CssOperators
    include Services::GeoQueries

    attr_reader :json, :marker, :text, :json_text, :success
    def initialize(marker, json_text, json, text=nil)
      @marker, @json_text, @json, @text = marker, json_text, json, text 
    end

    def names
      return [] unless n = marker.name || marker.super_fetch(:infoWindow, :title)
      [n, text].compact.map{ |s| s.decode_characters.gsub(/<.*./, '') }.uniq
    end

    def full_address
      lines = marker.super_fetch(:infoWindow, :addressLines)
      lines ? lines.join(", ").decode_characters : nil
    end

    def locality          
      marker.sxct
    end

    def region          
      marker.sxpr
    end

    def postal_code          
      marker.sxpo
    end

    def country          
      find_country_by_code(country_code) if country_code
    end

    def street_address
      lines = marker.super_fetch(:infoWindow, :addressLines)
      ( lines.try(:first) ||
          trim_full_to_street_address(full_address: full_address, country: country, postal_code: postal_code, region: region, locality: locality, name: names.first) || ''
      ).decode_characters
    end

    def street_addresses
      [street_address].flatten.compact
    end

    def website          
      marker.super_fetch(:infoWindow, :hp, :actual_url)
    end

    def phone
      phones.first          
    end

    def phones
      list = marker.super_fetch(:infoWindow, :phones)
      list ? list.map(&:number).compact : []
    end

    def lat
      best_guess = marker.latlng.try(:lat)
      return best_guess.to_f if best_guess

      fetched_lat = json.super_fetch(:viewport, :center, :lat)
      chosen_lat = (fetched_lat && fetched_lat != 0) ? fetched_lat : json_text.scan(/https[:]\/\/.*?\.google\.com\/cbk\?output[=]thumbnail.*?ll=([-]?\d+\.\d+)\,[-]?\d+\.\d+/).flatten.first
      chosen_lat.try(:to_f)
    end

    def lon
      best_guess = marker.latlng.try(:lon)
      return best_guess.to_f if best_guess

      fetched_lon = json.super_fetch(:viewport, :center, :lng)
      chosen_lon = (fetched_lon && fetched_lon != 0) ? fetched_lon : json_text.scan(/https[:]\/\/.*?\.google\.com\/cbk\?output[=]thumbnail.*?ll=[-]?\d+\.\d+\,([-]?\d+\.\d+)/).flatten.first
      chosen_lon.try(:to_f)
    end

    def extra
      { google_place_url: google_place_url }
    end

    def images
      return [] unless original_image && original_image.scan("logo.").flatten.first != "logo."
      return [] unless image = unhex( original_image )

      # EDIT UP SIZE BY ONE ZERO
      image = image.gsub(/\/s(\d\d)\//, "/s\\1"+"0/").gsub(/\&w\=(\d\d)\&/, "&w=\\1"+"0&")
                   .gsub(/\&h\=(\d\d)\&/, "&h=\\1"+"0&").gsub(/\&zoom\=0/, "&zoom=3")
                   
      [{ url: image, source: unhex( original_image ), credit: 'Google' }].to_sa
    end

    def country_code          
      marker.sxcn
    end

    private

    def original_image          
      marker.super_fetch(:infoWindow, :photoUrl)
    end

    def google_place_url
      marker.super_fetch(:infoWindow, :place_url)
    end

    memoize :names, :full_address, :locality, :region, :postal_code, :country, :street_address, 
            :website, :lat, :lon, :images, :country_code, :original_image, :google_place_url
  end
end