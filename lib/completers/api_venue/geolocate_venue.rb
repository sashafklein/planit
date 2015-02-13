module Completers
  class ApiVenue::GeolocateVenue < ApiVenue

    attr_reader :json
    def initialize(json)
      @json = json
    end

    def found?
      json.any?
    end

    def subregion
      get_value(json, "administrative_area_level_2")
    end

    def region
      get_value(json, 'administrative_area_level_1')
    end

    def short_region
      get_value(json, 'administrative_area_level_1', 'short_name')
    end

    def country
      get_value(json, 'country')
    end

    def short_country
      get_value(json, 'country', 'short_name')
    end

    def lat
      json.super_fetch(:geometry, :location, :lat)
    end

    def lon
      json.super_fetch(:geometry, :location, :lng)
    end

    def locality
      no_parens get_value(json, "locality")
    end

    def sublocality
      get_value(json, 'sublocality_level_1')
    end

    def postal_code
      get_value(json, "postal_code", 'short_name')
    end

    def full_address
      json.formatted_address
    end

    def get_value(json, type, length='long_name')
      component = json['address_components'].find{ |c| c['types'].include?(type) }
      component ? component[length] : nil
    end

    def location_type
      json.geometry.location_type
    end

    def seems_accurate?(pip, points_similarity: 1)
      return false if location_type == "APPROXIMATE"
      return true unless pip.lat && pip.lon

      points_ll_similarity(pip) > points_similarity
    end

    def no_parens(val)
      val.to_s.gsub(/\(.*\)/, '').strip
    end

    memoize :subregion, :region, :short_region, :country, :short_country, :lat, :lon, :locality, :sublocality, :postal_code, :full_address, :seems_accurate?
  end
end