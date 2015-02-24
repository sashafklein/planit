module Completers
  class ApiCompleter::GoogleMaps < ApiCompleter

    attr_reader :pip, :atts, :venues, :venue
    def initialize(pip, atts, take: nil)
      @pip, @atts, @venues = pip, atts, []
    end

    def complete
      find
      merge!
      
      { place: pip, photos: photos, success: @success }.to_sh
    end

    def get_venues(url, text=nil)
      json_text = open( url ).read[/{.+}/]
      json = eval( json_text ).to_sh
      markers = json.super_fetch(:overlays, :markers) || []
      markers.map do |marker|
        ApiVenue::GoogleMapsVenue.new( marker, json_text, json.except(:overlays, :panel, :page_conf, :dopts), text )
      end.select do |venue|
        venue.marker.present? && venue.marker.id.length == 1
      end
    end

    private

    def find
      flag_query(url)
      @venues = get_venues(url)
      @venue = venues.first

      @success = venue.present? && ( triangulate_from_previous! || good_lat_lon? )
    end

    def atts_to_merge
      [:names, :full_address, :locality, :region, :postal_code, :country, :street_addresses, :website, :phones, :lat, :lon, :extra]
    end

    def merge!
      return unless @success
      super
    end

    def photos
      venue ? venue.photos.map{ |i| Image.new( source: i.credit, source_url: i.source, url: i.url ) } : []
    end

    def url
      URI.parse("https://www.google.com/maps?q=#{query}&output=json").to_s
    end

    def query
      if nearby 
        ["#{pip.name.to_s.gsub(" ", '+')}", nearby].map(&:no_accents).join("&near=")
      elsif ll.present?
        "#{pip.name.to_s.gsub(" ", '+')}+loc:#{ll}"
      elsif pip.full_address
        "#{pip.name.to_s.gsub(" ", '+')}, #{ pip.full_address.to_s.gsub(/\#.*,/, ',').gsub(" ", '+') }".no_accents
      end
    end

    def ll
      [atts.lat, atts.lon].reject(&:blank?).join(",")
    end

    def nearby
      return atts.nearby if atts.nearby
      
      vals = [atts.locality, atts.region, atts.country].compact
      vals.any? ? vals.join(", ") : nil
    end

    def good_lat_lon?
      answer = venue.venue_match?(pip, overwrite_nil: true)
      flag_failure(query: url, response: venue.json, error: 'Unacceptable LatLon/Name', extra: { pip: pip.clean_attrs }) unless answer
      answer
    end
  end
end