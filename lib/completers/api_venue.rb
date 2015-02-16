module Completers
  class ApiVenue

    extend Memoist

    def serialize
      Place.attribute_keys.inject({}) do |hash, k| 
        hash[k] = respond_to?(k) ? send(k) : nil
        hash
      end.compact
    end

    def self.venue_name
      to_s.demodulize.split("Venue").first
    end

    def acceptably_close_lat_lon_and_name?(pip, overwrite_nil: true)
      pip.names.any? do |pip_name|
        match_percent = Services::StringMatch.new(pip_name, name).value
        match_percent > name_stringency(pip, overwrite_nil: overwrite_nil)
      end
    end

    def name_stringency(pip, overwrite_nil: true)
      return 2 if (polls = points_ll_similarity(pip, overwrite_nil: overwrite_nil)) < 1 # Reject distant, even if name matches
      case polls
        when 1 then 0.99
        when 2 then 0.85
        when 3 then 0.75
        else 0.65
      end 
    end

    def points_ll_similarity(pip, overwrite_nil: true)
      return 0 unless lat && lon
      return ( overwrite_nil ? 6 : 0 ) if pip.lat.nil? || pip.lon.nil?
      ((pip.lat.points_of_similarity(lat) + pip.lon.points_of_similarity(lon)) / 2.0).floor
    end

    def name
      names.first
    end

    def street_address
      street_addresses.first
    end

    def matching_ll_and_name_or_address(pip)
      pip.name.present? ? acceptably_close_lat_lon_and_name?(pip) : street_address == pip.street_address
    end
  end
end