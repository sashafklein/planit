require 'json'
require 'uri'

module Services
  class ApiCompleter

    FS_AUTH_TOKEN = "MLVKPP02MXONRZ1AJO0XAXIE4WCWSKUOIFPPQCERTNTQBXZR&v=20140819"
    FS_URL = 'https://api.foursquare.com/v2/venues/explore'

    delegate :name, :phone, :street_address, :lat, :lon, :country, :region, :locality, 
             :category, :meal, :lodging, :coordinate,
             to: :place

    attr_accessor :place, :venue
    def initialize(place)
      @place = Place.where(region: place.region, locality: place.locality).with_address(place.street_address).first || place
    end

    def complete!
      return place if place.complete?

      return place unless locality? && query?

      explore
      place
    rescue
      place
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
      place
    end

    def nearby
      @nearby || place.nearby
    end
    
    def merge!
      return unless gut_check

      place.names << venue_name
      place.phones[:default] = venue_phone if venue_phone
      place.street_addresses << venue_address
      place.website = venue_website
      place.category = venue_category
      place.save!
    end

    def gut_check
      place.lat.round(1) == venue_lat.round(1) && place.lon.round(1) == venue_lon.round(1)
    end

    def getPhoto
      ActiveRecord::Base.transaction do 
        place.images.where(url: venue_photo).first_or_create!(source: 'FourSquare')
      end
    end

    def locality?
      @locality ||= nearby || (lat && lon)
    end

    def query?
      @query = name.present? || street_address.present?
    end
    
    def locality
      URI.escape( nearby ? "near=#{nearby}" : "ll=#{coordinate(',')}" )
    end

    def query
      URI.escape( name || street_address )
    end

    def full_fs_url
      "#{FS_URL}?#{locality}&query=#{query}&oauth_token=#{FS_AUTH_TOKEN}&venuePhotos=1"
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