module Completers
  class ApiVenue

    extend Memoist

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

    def name
      names.first
    end
    
    private

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
    
    def clean(n)
      n = n.to_s.without_common_symbols.downcase.without_articles
      if n.chars.select{ |c| c == c.no_accents }.count > n.chars.reject{ |c| c.no_accents }.count
        n.no_accents
      else
        n
      end
    end
  end
end