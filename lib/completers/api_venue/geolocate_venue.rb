module Completers
  class ApiVenue::GeolocateVenue < ApiVenue

    attr_reader :response
    def initialize(response)
      @response = response
    end

    def found?
      response.any?
    end

    def subregion
      get_value(response, "administrative_area_level_2")
    end

    def region
      get_value(response, 'administrative_area_level_1')
    end

    def short_region
      get_value(response, 'administrative_area_level_1', 'short_name')
    end

    def country
      get_value(response, 'country')
    end

    def short_country
      get_value(response, 'country', 'short_name')
    end

    def lat
      response.super_fetch(:geometry, :location, :lat)
    end

    def lon
      response.super_fetch(:geometry, :location, :lng)
    end

    def locality
      no_parens get_value(response, "locality")
    end

    def sublocality
      get_value(response, 'sublocality_level_1')
    end

    def postal_code
      get_value(response, "postal_code", 'short_name')
    end

    def full_address
      response.formatted_address
    end

    def get_value(response, type, length='long_name')
      component = response['address_components'].find{ |c| c['types'].include?(type) }
      component ? component[length] : nil
    end

    def location_type
      response.geometry.location_type
    end

    def seems_accurate?
      return @sa if @sa

      return @sa = false if location_type == "APPROXIMATE"
      return @sa = true unless pip.lat && pip.lon
      @sa = lat.points_of_similarity(pip.lat) > 1 && lon.points_of_similarity(pip.lon) > 1
    end

    def no_parens(val)
      val.to_s.gsub(/\(.*\)/, '').strip
    end

    memoize :subregion, :region, :short_region, :country, :short_country, :lat, :lon, :locality, :sublocality, :postal_code, :full_address
  end
end