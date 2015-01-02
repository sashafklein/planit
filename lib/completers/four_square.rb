require 'json'
require 'uri'

module Completers
  class FourSquare

    FS_AUTH_TOKEN = "MLVKPP02MXONRZ1AJO0XAXIE4WCWSKUOIFPPQCERTNTQBXZR&v=20140819"
    FS_URL = 'https://api.foursquare.com/v2/venues/explore'

    delegate :name, :phone, :street_address, :lat, :lon, :country, :region, :locality, 
             :category, :meal, :lodging, :coordinate,
             to: :pip

    attr_accessor :pip, :venues, :venue, :geocoded, :photos, :alternate_nearby, :response
    def initialize(pip, alternate_nearby=nil)
      @pip = pip
      @alternate_nearby = alternate_nearby
      @photos = []
    end

    def complete!
      return place_with_photos unless nearby_info_present? && query? && !pip.place.complete?

      explore
      place_with_photos
    end

    private

    def sufficient_to_fetch?
      name && (nearby || (lat && lon))
    end

    def explore
      get_venues!
      pick_venue
      merge!
      getPhotos
    end

    def nearby
      @nearby ||= pip.nearby || alternate_nearby
    end

    def get_venues!
      @response = HTTParty.get(full_fs_url)
      @venues = @response.deep_val(['response', 'groups', 0, 'items']).map do |item|
        FourSquareVenue.new(item)
      end
    end

    def pick_venue
      @venue = venues.find do |v| 
        if pip.name.present?
          v.acceptably_close_lat_lon_and_name?(pip)
        else
          v.address == pip.street_address
        end
      end
    end
    
    def merge!
      return unless venue

      pip.set_val( :names, venue.name, self.class )
      pip.set_val( :phones, { default: venue.phone }, self.class ) if venue.phone
      pip.set_val( :street_addresses, venue.address, self.class )
      pip.set_val( :website, venue.website, self.class )
      pip.set_val( :categories, venue.category, self.class )
      pip.set_val( :locality, venue.locality ,  self.class )
      pip.set_val( :country, venue.country , self.class )
      pip.set_val( :region, venue.region , self.class )
      pip.set_val( :flags, "Took information from identically named, distant FourSquare data with LatLon: #{lat}, #{lon}. Old lat lon: #{pip.coordinate(', ')}", self.class) if venue.name_stringency(pip) == 0.99 
      pip.set_val( :lat, venue.lat, self.class )
      pip.set_val( :lon, venue.lon, self.class )
      pip.set_val( :completion_steps, self.class.to_s.demodulize, self.class )
      pip.set_val( :extra, { menu_url: venue.menu_url }, self.class )
      pip.set_val( :extra, { mobile_menu_url: venue.mobile_menu_url }, self.class )
      pip.set_val( :extra, { four_square_id: venue.four_square_id }, self.class )
    end

    def getPhotos
      return place_with_photos unless venue
      venue.photos.each do |photo|
        @photos << Image.where(url: photo).first_or_initialize(source: 'FourSquare')
      end
    end

    def place_with_photos
      { place: pip, photos: photos }
    end

    def nearby_info_present?
      @nearby_info_present ||= nearby || (lat && lon) || alternate_nearby
    end

    def query?
      @query = name.present? || street_address.present?
    end
    
    def nearby_parameter
      URI.escape( nearby ? "near=#{nearby}" : "ll=#{coordinate(',')}" )
    end

    def query
      URI.escape( name || street_address )
    end

    def full_fs_url
      "#{ FS_URL }?#{ nearby_parameter }&query=#{ query }&oauth_token=#{ FS_AUTH_TOKEN }&venuePhotos=1"
    end
  end
end