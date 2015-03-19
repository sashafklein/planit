module Completers
  class ApiCompleter::GoogleMaps < ApiCompleter

    attr_reader :pip, :atts, :venues, :venue, :last_url
    def initialize(pip, atts, take: nil)
      @pip, @atts, @venues = pip, atts, []
    end

    def complete
      find
      merge!
      
      { place: pip, images: images, success: @success }.to_sh
    end

    def get_venues(given_url=nil, text=nil)
      json_text = open( given_url || url ).read[/{.+}/]
      json = eval( json_text ).to_sh
<<<<<<< HEAD
      
=======
>>>>>>> GoogleMaps only double-searches (with reduced query) if first query doesn't work; Translate won't override if it's foreign
      markers = json.super_fetch(:overlays, :markers) || []

      markers.map do |marker|
        ApiVenue::GoogleMapsVenue.new( marker, json_text, json.except(:overlays, :panel, :page_conf, :dopts), text )
      end.select do |venue|
        venue.marker.present? && venue.marker.id.length == 1
      end
    end

    def find
      find_from_query
      find_from_query( reduce_nearby( query ) ) if !@venue && query_can_be_reduced?
    end

    private

    def find_from_query(q=nil)
      flag_query url(q)
      @venues = get_venues url(q)
      
      if @venue = venues.first
        @last_url = url(q)
      end

      @success = venue.present? && ( triangulate_from_previous! || good_lat_lon? )
    end

    def atts_to_merge
      [:names, :full_address, :locality, :region, :postal_code, :country, :street_addresses, :website, :phones, :lat, :lon, :extra]
    end

    def merge!
      return unless @success
      super
    end

    def images
      venue ? venue.images.map{ |i| Image.new( source: i.credit, source_url: i.source, url: i.url ) } : []
    end

<<<<<<< HEAD
    def url
      URI.escape("https://maps.google.com/maps?q=#{query}&ie=UTF8&hq=&hnear=&output=json").to_s
=======
    def url(q=nil)
      URI.escape("https://www.google.com/maps?q=#{q || query}&output=json").to_s
>>>>>>> GoogleMaps only double-searches (with reduced query) if first query doesn't work; Translate won't override if it's foreign
    end

    def query
      if nearby 
        @searching_with_nearby = ["#{pip.name.to_s.gsub(" ", '+')}", nearby].map(&:no_accents).join("&near=")
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

    def location_blacklist
      list = %w( county city town prefecture province region ) 
      list.concat( list.map(&:capitalize) )
    end

    def reduce_nearby(n)
      n.split(", ").map{ |v| v.cut_words(*location_blacklist).strip }.select(&:present?).join(", ")
    end

    def query_can_be_reduced?
      return false unless (q = query) && @searching_with_nearby
      reduce_nearby(q) != q
    end
  end
end