module Completers
  class ApiCompleter::GoogleMaps < ApiCompleter

    attr_reader :pip, :atts, :venue
    def initialize(pip, atts)
      @pip, @atts = pip, atts
    end

    def complete
      find
      merge!
      { place: pip, photos: photos, success: @success }.to_sh
    end

    private

    def find
      flag_query(url)
      @venue = ApiVenue::GoogleMapsVenue.new(url)
      @success = venue.marker.present? && good_lat_lon?
    end

    def merge!
      return unless @success
      set_vals(:names, :full_address, :locality, :region, :postal_code, :country, :street_addresses, :website, :phones, :lat, :lon)
      pip.set_val(:extra, { google_place_url: venue.google_place_url }, self.class)
    end

    def set_vals(*vals)
      vals.each{ |v| pip.set_val(v, venue.send(v), self.class ) }
    end

    def photos
      venue.images.map{ |i| Image.new( source: i.credit, source_url: i.source, url: i.url ) }
    end

    def url
      "https://www.google.com/maps?q=#{query}&output=json"
    end

    def query
      if nearby 
        "#{pip.name}, #{nearby}".no_accents
      elsif ll.present?
        "#{pip.name}&sll=#{ll}"
      elsif pip.full_address
        "#{pip.name}, #{ pip.full_address.gsub(/\#.*,/, ',') }".no_accents
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
      answer = venue.acceptably_close_lat_lon_and_name?(pip)
      flag_failure(query: url, response: venue.json, error: 'Unacceptable LatLon/Name', extra: { pip: pip.clean_attrs }) unless answer
      answer
    end
  end
end