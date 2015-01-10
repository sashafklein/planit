module Completers
  class FourSquareVenue

    IMAGE_SIZE = '622x440'

    attr_accessor :json
    def initialize(json)
      @json = SuperHash.new json['venue']
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
      return [] unless photos = json.super_fetch( *['featuredPhotos', 'items'] )
      photos.map do |photo|
        [photo['prefix'], photo['suffix']].join(IMAGE_SIZE)
      end
    end   
    
    def website
      json['url']
    end

    def name
      json['name']
    end

    def phone
      json.super_fetch %w(contact phone)
    end

    def address
      json.super_fetch %w(location address)
    end

    def lat
      json.super_fetch %w(location lat)  
    end

    def lon
      json.super_fetch %w(location lng)
    end

    def country
      json.super_fetch %w(location country)
    end

    def region
      json.super_fetch %w(location state)
    end

    def locality
      json.super_fetch %w(location city)
    end

    def category
      json.super_fetch ['categories', 0, 'name']
    end

    def full_address
      json.super_fetch %w( location formattedAddress )
    end

    def menu_url
      json.super_fetch %w( menu url )
    end

    def mobile_menu_url
      json.super_fetch %w( menu mobileUrl )
    end

    def four_square_id
      json['id']
    end
  end
end