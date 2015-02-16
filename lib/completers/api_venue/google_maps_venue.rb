module Completers
  class ApiVenue::GoogleMapsVenue < ApiVenue

    include ScraperOperators
    include CssOperators
    include Services::GeoQueries

    attr_reader :json, :link, :text, :json_text, :success
    def initialize(link, text=nil)
      @link, @text = link, text
      @json_text = open( link ).read[/{.+}/]
      @json = eval( @json_text ).to_sh
      @json.overlays.try(:delete, :layers)
      @json.try(:delete, :panel)
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
          trim_full_to_street_address(full_address, country, postal_code, region, locality, names.first) 
      ).decode_characters
    end

    def street_addresses
      [street_address].flatten.compact
    end

    def website          
      marker.super_fetch(:infoWindow, :hp, :actual_url)
    end

    def google_place_url
      marker.super_fetch(:infoWindow, :place_url)
    end

    def phone
      phones.first          
    end

    def phones
      list = marker.super_fetch(:infoWindow, :phones)
      list ? list.map(&:number).compact : []
    end

    def lat
      fetched_lat = json.super_fetch(:viewport, :center, :lat)
      chosen_lat = (fetched_lat && fetched_lat != 0) ? fetched_lat : json_text.scan(/https[:]\/\/.*?\.google\.com\/cbk\?output[=]thumbnail.*?ll=([-]?\d+\.\d+)\,[-]?\d+\.\d+/).flatten.first
      chosen_lat.try(:to_f)
    end

    def lon
      fetched_lon = json.super_fetch(:viewport, :center, :lng)
      chosen_lon = (fetched_lon && fetched_lon != 0) ? fetched_lon : json_text.scan(/https[:]\/\/.*?\.google\.com\/cbk\?output[=]thumbnail.*?ll=[-]?\d+\.\d+\,([-]?\d+\.\d+)/).flatten.first
      chosen_lon.try(:to_f)
    end

    def images
      return [] unless original_photo && original_photo.scan("logo.").flatten.first != "logo."
      return [] unless photo = unhex( original_photo )

      # EDIT UP SIZE BY ONE ZERO
      photo = photo.gsub(/\/s(\d\d)\//, "/s\\1"+"0/").gsub(/\&w\=(\d\d)\&/, "&w=\\1"+"0&")
                   .gsub(/\&h\=(\d\d)\&/, "&h=\\1"+"0&").gsub(/\&zoom\=0/, "&zoom=3")
                   
      [{ url: photo, source: unhex( original_photo ), credit: 'Google' }].to_sa
    end

    def country_code          
      marker.sxcn
    end

    def extra
      { google_place_url: google_place_url }
    end

    def marker
      json.super_fetch(:overlays, :markers, 0) || {}.to_sh
    end

    private

    def original_photo          
      marker.super_fetch(:infoWindow, :photoUrl)
    end

    memoize :names, :full_address, :locality, :region, :postal_code, :country, :street_address, 
            :website, :lat, :lon, :images, :country_code, :original_photo, :google_place_url
  end
end