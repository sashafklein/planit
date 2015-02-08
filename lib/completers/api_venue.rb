module Completers
  class ApiVenue

    extend Memoist

    def acceptably_close_lat_lon_and_name?(pip)
      if pip.names.all?(&:non_latinate?)
        return pip.names.any?{ |n| n == name } && name_stringency(pip) != 2
      end

      pip.names.reject(&:non_latinate?).any? do |pip_name|
        match_percent = Services::StringMatch.new(pip_name, name).value
        match_percent > name_stringency(pip)
      end
    end

    def name_stringency(pip)
      if points_of_lat_lon_similarity(pip) >= 4
        0.65
      else
        case points_of_lat_lon_similarity(pip)
        when 3 then 0.75
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
  end
end