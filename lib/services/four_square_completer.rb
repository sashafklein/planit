require 'json'
require 'uri'

module Services
  class FourSquareCompleter

    AUTH_TOKEN = "MLVKPP02MXONRZ1AJO0XAXIE4WCWSKUOIFPPQCERTNTQBXZR&v=20140819"
    BASE_URL = 'https://api.foursquare.com/v2/venues/explore'

    delegate :name, :phone, :street_address, :lat, :lon, :country, :region, :locality, 
             :category, :meal, :lodging, :nearby, :coordinate,
             to: :place

    attr_accessor :place, :venue
    def initialize(place)
      @place = place
    end

    def complete!
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
      @venue = HTTParty.get(full_url)['response']['groups'][0]['items'][0]['venue']
      merge!
      getPhoto
    rescue
      place
    end
    
    def merge!
      place.names << venue_name
      place.phones[:default] ||= venue_phone
      place.street_address = venue_address if street_address.blank? 
      place.lat = venue_lat if lat.blank? 
      place.lon = venue_lon if lon.blank? 
      place.country = venue_country if country.blank? 
      place.region = venue_region if region.blank? 
      place.locality = venue_locality if locality.blank? 
      place.category = venue_category if category.blank? 
      place.save!
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

    def full_url
      "#{BASE_URL}?#{locality}&query=#{query}&oauth_token=#{AUTH_TOKEN}&venuePhotos=1"
    end

    def venue_photo
      photo = venue['featuredPhotos']['items'][0]
      [photo['prefix'], photo['suffix']].join("200x200")
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