require 'json'
require 'uri'

module Services
  class ApiCompleter

    FS_AUTH_TOKEN = "MLVKPP02MXONRZ1AJO0XAXIE4WCWSKUOIFPPQCERTNTQBXZR&v=20140819"
    FS_URL = 'https://api.foursquare.com/v2/venues/explore'

    delegate :name, :phone, :street_address, :lat, :lon, :country, :region, :locality, 
             :category, :meal, :lodging, :coordinate,
             to: :place

    attr_accessor :place, :venue, :geocoded, :photo, :alternate_nearby
    def initialize(place, alternate_nearby=nil, geocoded=false)
      @place = place
      @alternate_nearby = alternate_nearby
      @geocoded = geocoded
      @photo = nil
    end

    def complete!
      return place_with_photo if place.complete?
      return place_with_photo unless nearby_info_present? && query?

      explore
      place_with_photo
    ensure
      place_with_photo
    end

    private

    def sufficient_to_fetch?
      name && (nearby || (lat && lon))
    end

    def explore
      @venue = HTTParty.get(full_fs_url)['response']['groups'][0]['items'][0]['venue']
      merge!
      getPhoto
    rescue
      place_with_photo
    end

    def nearby
      @nearby ||= place.nearby || alternate_nearby
    end
    
    def merge!
      return unless similar_lat_lon? && similar_name?
      
      place.names << venue_name
      place.phones[:default] = venue_phone if venue_phone
      place.street_addresses << venue_address
      place.website = venue_website
      place.categories << venue_category
      place.locality = venue_locality unless place.locality.present? && geocoded
      place.set_country(venue_country) unless place.country.present? && geocoded
      place.set_region(venue_region) unless place.region.present? && geocoded
      place.lat = venue_lat unless place.lat.present? && geocoded
      place.lon = venue_lon unless place.lon.present? && geocoded
    end

    def similar_lat_lon?
      ( place.lat.nil? || place.lat.round(1) == venue_lat.round(1) ) && 
        (place.lon.nil? || place.lon.round(1) == venue_lon.round(1) )
    end

    def similar_name?
      return true if place.names.empty? || venue_name.non_latinate?
      place.names.any? do |name|
        matches = (name.match_distance(venue_name) > 0.7)
        notify_of_bad_name_distance if !matches
        matches
      end
    end

    def notify_of_bad_name_distance
      return binding.pry if ENV["RAILS_ENV"] == 'test'

      PlaceMailer.notify_of_bad_name_distance(name, distance, venue)
    end

    def getPhoto
      @photo = place.images.where(url: venue_photo).first_or_initialize(source: 'FourSquare')
    end

    def place_with_photo
      { place: place, photo: photo }
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

    def venue_photo
      photo = venue['featuredPhotos']['items'][0]
      [photo['prefix'], photo['suffix']].join("200x200")
    end   
    
    def venue_website
      venue['url']
    end

    def venue_name
      venue['name']
    end

    def venue_phone
      venue['contact']['phone']
    end

    def venue_address
      venue['location']['address']
    end

    def venue_lat
      venue['location']['lat']
    end

    def venue_lon
      venue['location']['lng']
    end

    def venue_country
      venue['location']['country']
    end

    def venue_region
      venue['location']['state']
    end

    def venue_locality
      venue['location']['city']
    end

    def venue_category
      venue['categories'][0]['name']
    end
  end
end