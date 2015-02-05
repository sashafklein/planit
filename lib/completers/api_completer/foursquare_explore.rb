module Completers
  class ApiCompleter::FoursquareExplore < ApiCompleter

    FS_AUTH_TOKEN = "MLVKPP02MXONRZ1AJO0XAXIE4WCWSKUOIFPPQCERTNTQBXZR&v=20140819"
    FS_URL = 'https://api.foursquare.com/v2/venues'

    delegate :name, :phone, :street_address, :lat, :lon, :country, :region, :locality, 
             :category, :meal, :lodging, :coordinate,
             to: :pip

    attr_accessor :pip, :venues, :venue, :geocoded, :photos, :alternate_nearby, :response
    def initialize(pip, alternate_nearby=nil)
      @pip = pip
      @alternate_nearby = alternate_nearby
      @photos = []
    end

    def self.auth_token
      FS_AUTH_TOKEN
    end

    def complete
      return place_with_photos unless nearby_info_present? && query? && !pip.place.complete?

      explore
      place_with_photos(success: venue.present?)
    end

    private

    def sufficient_to_fetch?
      name && (nearby || (lat && lon))
    end

    def explore
      get_venues!
      pick_venue
      
      return unless venue

      merge!
      getPhotos
    end

    def nearby
      @nearby ||= pip.nearby || alternate_nearby
    end

    def get_venues!
      @response = HTTParty.get(full_fs_url).to_sh

      @venues = @response.super_fetch( :response, :groups, 0, :items ).map do |item|
        ApiVenue::FoursquareExploreVenue.new(item)
      end.sort{ |a, b| b.points_of_lat_lon_similarity(pip) <=> a.points_of_lat_lon_similarity(pip) }

      pip.flag( name: "Foursquare Explore Results", info: @venues.map(&:foursquare_id) )
    rescue => e
      flag_failure(query: full_fs_url, response: @response, error: e)
    end

    def pick_venue
      @venue = venues.find do |v| 
        if pip.name.present?
          v.acceptably_close_lat_lon_and_name?(pip)
        else
          v.address == pip.street_address
        end
      end
    rescue => e
      pip.flag( name: "Foursquare Pick Venue Failure", details: "Couldn't pick an acceptable venue", info: { pip: pip.clean_attrs, venues: @venues } )
    end
    
    def merge!
      set_vals( :website, :locality, :country, :region, :lat, :lon, :menu, :mobile_menu, :foursquare_id, :names, :street_addresses, :phones )
      pip.flag( name: "Name-Lat/Lon Clash", details: "Took information from identically named, distant FoursquareExplore data.", info: { name: venue.name, venue: { lat: venue.lat, lon: venue.lon }, place: { lat: pip.lat, lon: pip.lon } } ) if venue.name_stringency(pip) == 0.99 
    end

    def set_vals(*vals)
      vals.each{ |v| pip.set_val(v, venue.send(v), self.class) }
    end

    def getPhotos
      return place_with_photos unless venue
      venue.photos.each do |photo|
        @photos << Image.where(url: photo).first_or_initialize(source: 'Foursquare')
      end
    end

    def place_with_photos(success: true)
      { place: pip, photos: photos, success: success }.to_sh
    end

    def nearby_info_present?
      @nearby_info_present ||= nearby || (lat && lon) || alternate_nearby
    end

    def query?
      @query = name.present? || street_address.present?
    end
    
    def nearby_parameter
      URI.escape( coordinate ? "ll=#{coordinate(',')}" : "near=#{nearby}" )
    end

    def query
      URI.escape( name || street_address )
    end

    def full_fs_url
      url = "#{ FS_URL }/explore?#{ nearby_parameter }&query=#{ query }&oauth_token=#{ FS_AUTH_TOKEN }&venuePhotos=1"
      flag_query(url)
      url
    end
  end
end