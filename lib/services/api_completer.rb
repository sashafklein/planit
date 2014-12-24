require 'json'
require 'uri'

module Services
  class ApiCompleter

    FS_AUTH_TOKEN = "MLVKPP02MXONRZ1AJO0XAXIE4WCWSKUOIFPPQCERTNTQBXZR&v=20140819"
    FS_URL = 'https://api.foursquare.com/v2/venues/explore'

    delegate :name, :phone, :street_address, :lat, :lon, :country, :region, :locality, 
             :category, :meal, :lodging, :coordinate,
             to: :place

    attr_accessor :place, :venue, :geocoded, :photos, :alternate_nearby, :response
    def initialize(place, alternate_nearby=nil, geocoded=false)
      @place = place
      @alternate_nearby = alternate_nearby
      @geocoded = geocoded
      @photos = []
    end

    def complete!
      return place_with_photos unless nearby_info_present? && query? && !place.complete?

      explore
      place_with_photos
    end

    private

    def sufficient_to_fetch?
      name && (nearby || (lat && lon))
    end

    def explore
      @venue = get_venue!
      merge!
      getPhotos
    end

    def nearby
      @nearby ||= place.nearby || alternate_nearby
    end

    def get_venue!
      @response = HTTParty.get(full_fs_url)
      @response.deep_val ['response', 'groups', 0, 'items', 0, 'venue']
    end
    
    def merge!
      return unless venue && acceptably_close_lat_lon_and_name?
      
      place.names << venue_name
      place.phones[:default] = venue_phone if venue_phone
      place.street_addresses << venue_address
      place.website = venue_website if place.website.blank?
      place.categories << venue_category
      place.locality = venue_locality unless place.locality.present? && geocoded
      place.set_country(venue_country) unless place.country.present? && geocoded
      place.set_region(venue_region) unless place.region.present? && geocoded

      place.add_flag("Took information from identically named, distant FourSquare data with LatLon: #{lat}, #{lon}.") if name_stringency == 0.99 
      place.lat = venue_lat unless place.lat.present? && geocoded
      place.lon = venue_lon unless place.lon.present? && geocoded
    end

    def acceptably_close_lat_lon_and_name?
      similar_name?
    end

    def name_stringency
      if points_of_lat_lon_similarity >= 4
        0.6
      else
        case points_of_lat_lon_similarity
        when 3 then 0.7
        when 2 then 0.85
        when 1 then 0.99
        else 2 # Reject, even if name matches
        end
      end 
    end

    def points_of_lat_lon_similarity
      return @points_similarity if @points_similarity
      return 0 unless venue_lat && venue_lon
      return 6 if lat.nil? || lon.nil?
      @points_similarity = [lat.points_of_similarity(venue_lat), lon.points_of_similarity(venue_lon)].min
    end

    def similar_name?
      return true if name.to_s.without_common_symbols.non_latinate? || venue_name.to_s.without_common_symbols.non_latinate?

      place.names.any? do |name|
        distance = name.without_articles.without_common_symbols.match_distance( venue_name.without_articles.without_common_symbols ) || 2
        matches = (distance > name_stringency)
        notify_of_bad_name_distance(distance) if !matches
        matches
      end
    end

    def notify_of_bad_name_distance(distance)
      return if ENV["RAILS_ENV"] == 'test' || true

      PlaceMailer.notify_of_bad_name_distance(name, distance, venue_name)
    end

    def getPhotos
      return place_with_photos unless venue
      venue_photos.each do |photo|
        @photos << place.images.where(url: photo).first_or_initialize(source: 'FourSquare')
      end
    end

    def place_with_photos
      { place: place, photos: photos }
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

    def venue_photos
      return [] unless photos = venue.deep_val( ['featuredPhotos', 'items'] )

      photos.map do |photo|
        [photo['prefix'], photo['suffix']].join("200x200")
      end
    end   
    
    def venue_website
      venue['url']
    end

    def venue_name
      venue['name']
    end

    def venue_phone
      venue.deep_val %w(contact phone)
    end

    def venue_address
      venue.deep_val %w(location address)
    end

    def venue_lat
      venue.deep_val %w(location lat)
    end

    def venue_lon
      venue.deep_val %w(location lng)
    end

    def venue_country
      venue.deep_val %w(location country)
    end

    def venue_region
      venue.deep_val %w(location state)
    end

    def venue_locality
      venue.deep_val %w(location city)
    end

    def venue_category
      venue.deep_val ['categories', 0, 'name']
    end
  end
end