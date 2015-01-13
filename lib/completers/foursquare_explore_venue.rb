module Completers
  class FoursquareExploreVenue

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
      @points_similarity = ((pip.lat.points_of_similarity(lat) + pip.lon.points_of_similarity(lon)) / 2.0).floor
    end

    def similar_name?(pip)
      if pip.names.all?(&:non_latinate?)
        return pip.names.any?{ |n| n == name } && name_stringency(pip) != 2
      end
      
      venue_name = clean(name)

      pip.names.reject(&:non_latinate?).any? do |pip_name|
        pip_name = clean(pip_name)
        distance = pip_name.match_distance( venue_name ) || 2
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

    def clean(n)
      n = n.to_s.without_common_symbols.downcase.without_articles
      if n.chars.select{ |c| c == c.no_accents }.count > n.chars.reject{ |c| c.no_accents }.count
        n.no_accents
      else
        n
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

    def full_address
      json.super_fetch %w( location formattedAddress )
    end

    def menu
      json.super_fetch %w( menu url )
    end

    def mobile_menu
      json.super_fetch %w( menu mobileUrl )
    end

    def foursquare_id
      json['id']
    end
  end
end