module Completers
  class FourSquareVenue

    attr_accessor :json
    def initialize(json)
      @json = json['venue']
    end

    def acceptably_close_lat_lon_and_name?(pip)
      similar_name?(pip)
    end

    def name_stringency(pip)
      if points_of_lat_lon_similarity(pip) >= 4
        0.6
      else
        case points_of_lat_lon_similarity(pip)
        when 3 then 0.7
        when 2 then 0.85
        when 1 then 0.99
        else 2 # Reject, even if name matches
        end
      end 
    end

    def points_of_lat_lon_similarity(pip)
      return @points_similarity if @points_similarity
      return 0 unless lat && lon
      return 6 if pip.lat.nil? || pip.lon.nil?
      @points_similarity = [pip.lat.points_of_similarity(lat), pip.lon.points_of_similarity(lon)].min
    end

    def similar_name?(pip)
      pip_name, venue_name = pip.name.to_s.without_common_symbols, name.to_s.without_common_symbols
      return true if pip_name.non_latinate? || venue_name.non_latinate?

      pip.names.any? do |name|
        distance = pip_name.without_articles.match_distance( venue_name.without_articles ) || 2
        matches = (distance > name_stringency(pip))
        matches
      end
    end

    def photos
      return [] unless photos = json.deep_val( ['featuredPhotos', 'items'] )

      photos.map do |photo|
        [photo['prefix'], photo['suffix']].join("200x200")
      end
    end   
    
    def website
      json['url']
    end

    def name
      json['name']
    end

    def phone
      json.deep_val %w(contact phone)
    end

    def address
      json.deep_val %w(location address)
    end

    def lat
      json.deep_val %w(location lat)
    end

    def lon
      json.deep_val %w(location lng)
    end

    def country
      json.deep_val %w(location country)
    end

    def region
      json.deep_val %w(location state)
    end

    def locality
      json.deep_val %w(location city)
    end

    def category
      json.deep_val ['categories', 0, 'name']
    end

    def full_address
      json.deep_val %w( location formattedAddress )
    end
  end
end