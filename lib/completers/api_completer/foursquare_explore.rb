module Completers
  class ApiCompleter::FoursquareExplore < ApiCompleter

    FS_AUTH_TOKEN = "MLVKPP02MXONRZ1AJO0XAXIE4WCWSKUOIFPPQCERTNTQBXZR&v=20140819"
    FS_URL = 'https://api.foursquare.com/v2/venues'

    delegate :name, :phone, :street_address, :lat, :lon, :country, :region, :locality, 
             :category, :meal, :lodging, :coordinate,
             to: :pip

    attr_accessor :pip, :venues, :venue, :geocoded, :photos, :alternate_nearby, :response
    def initialize(pip, attrs={}, take: nil)
      @pip = pip
      @alternate_nearby = attrs[:nearby]
      @photos = []
      @success = false
    end

    def self.auth_token
      FS_AUTH_TOKEN
    end

    def complete
      unless sufficient_to_fetch?
        pip.flag(name: "Insufficient Atts for FoursquareExplore", info: { missing: pip.attrs.slice(:lat, :lon, :locality, :region, :country).select_val(&:blank?).map{ |k, v| k } } )
        return place_with_photos
      end

      explore
      place_with_photos
    end

    def sufficient_to_fetch?
      (name.present? || street_address.present?) && (nearby || (lat && lon))
    end

    private

    def explore
      get_venues!
      pick_venue

      pip.question!(class_name) unless @success = ( venue.present? && !pip.unsure.include?(class_name) )

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
      end
    rescue => e
      @venues ||= []
      flag_failure(query: full_fs_url, response: @response, error: e)
    end

    def sort_venues
      @venues.sort!{ |a, b| b.points_ll_similarity(pip) <=> a.points_ll_similarity(pip) }
      pip.flag( name: "Foursquare Explore Results", info: @venues.map{ |v| { name: v.name, fsid: v.foursquare_id } } )
    end
    
    def atts_to_merge
      [:website, :locality, :country, :region, :lat, :lon, :menu, :mobile_menu, :foursquare_id, :names, :street_addresses, :phones, :full_address, :sublocality]
    end

    def merge!
      pip.flag( name: "Name-Lat/Lon Clash", details: "Taking information from identically named, distant FoursquareExplore data.", info: { name: venue.name, venue: { lat: venue.lat, lon: venue.lon }, place: { lat: pip.lat, lon: pip.lon } } ) if venue && venue.name_stringency(pip) == 0.99
      super
    end

    def getPhotos
      return place_with_photos unless venue
      venue.photos.each do |photo|
        @photos << Image.where(url: photo).first_or_initialize(source: 'Foursquare')
      end
    end

    def place_with_photos
      { place: pip, photos: photos, success: @success }.to_sh
    end
    
    def nearby_parameter
      URI.escape( coordinate ? "ll=#{coordinate(',')}" : "near=#{nearby}" )
    end

    def query
      URI.escape( name || street_address )
    end

    def full_fs_url
      return @full_fs_url if @full_fs_url
      url = "#{ FS_URL }/explore?#{ nearby_parameter }&query=#{ query }&oauth_token=#{ FS_AUTH_TOKEN }&venuePhotos=1"
      flag_query(url)
      url
    end
  end
end