module Completers
  class Geolocate

    include RegexLibrary

    attr_accessor :pip, :atts, :response
    def initialize(pip, atts={})
      @pip, @atts = pip, atts
    end
    
    private

    def seems_accurate?
      return @sa if @sa

      return @sa = false if location_type == "APPROXIMATE"
      return @sa = true unless pip.lat && pip.lon
      @sa = lat.points_of_similarity(pip.lat) > 1 && lon.points_of_similarity(pip.lon) > 1
    end

    def update_location_basics(update_subregion=true, update_locality=true, overwrite=false)
      pip.set_val( :country, get_value(response, "country"), self.class, overwrite )
      pip.set_val( :region, get_value(response, "administrative_area_level_1"), self.class, overwrite )
      update_locale(update_subregion, update_locality)
    end

    def update_locale(update_subregion=true, update_locality=true)
      pip.set_val( :subregion, get_value(response, "administrative_area_level_2"), self.class, update_subregion )
      pip.set_val( :locality, get_value(response, "locality"), self.class, update_locality )
      pip.set_val( :sublocality, sublocality, self.class, update_locality )
    end

    def subregion
      @subregion ||= get_value(response, "administrative_area_level_2")
    end

    def region
      @region ||= get_value(response, 'administrative_area_level_1')
    end

    def short_region
      @short_region ||= get_value(response, 'administrative_area_level_1', 'short_name')
    end

    def country
      @country ||= get_value(response, 'country')
    end

    def short_country
      @short_country ||= get_value(response, 'country', 'short_name')
    end

    def lat
      @lat ||= response['geometry']['location']['lat']
    end

    def lon
      @lon ||= response['geometry']['location']['lng']
    end

    def locality
      @locality ||= get_value(response, "locality")
    end

    def sublocality
      @sublocality ||= get_value(response, 'sublocality_level_1')
    end

    def postal_code
      @postal_code ||= get_value(response, "postal_code", 'short_name')
    end

    def full_address
      @full_address ||= response['formatted_address']
    end

    def get_results(query)
      @response = response_data(query) || response_data(pip.coordinate(', ')) || {}
    end

    def location_type
      response['geometry']['location_type']
    end

    def response_data(query)
      Geocoder.search( query ).first.try(:data)
    end

    def get_value(response, type, length='long_name')
      return nil if response.blank?
      component = response['address_components'].find{ |c| c['types'].include?(type) }
      component ? component[length] : nil
    end

    def failure
      pip
    end

    def success
      pip.set_val(:completion_steps, self.class.to_s.demodulize, self.class)
      pip
    end

    def reverse_lat_lon_if_appropriate
      return if [lat, lon, pip.lat, pip.lon].any?(&:nil?)

      lat_possibly_reversed = pip.lat.points_of_similarity(lon) > 0
      lon_possibly_reversed = pip.lon.points_of_similarity(lat) > 0

      if lat_possibly_reversed && lon_possibly_reversed
        pip.set_val(:flags, "Reversing likely backwards LatLon. Pre-flip Place: #{pip.coordinate}, Geocoder: #{[lat, lon].join(':') }", self.class)
        pip.set_val(:lat, pip.lon, self.class)
        pip.set_val(:lon, pip.lat, self.class)
      end
    end

    def get_query
      return @query if @query
      if valid_lat_lon?
        @query = pip.coordinate(", ")
      elsif pip.street_address
        @query = [pip.street_address, pip.locality, pip.subregion, pip.region, pip.country].reject(&:blank?).join(", ")
      else
        @query = pip.full_address
      end
    end

    def valid_lat_lon?
      pip.lat && pip.lon && Timezone::Zone.new({latlon: [pip.lat, pip.lon]})
    rescue
      pip.set_val(:flags, "Invalid lat and lon being cleared: #{pip.lat}:#{pip.lon}", self.class)
      pip.set_val(:lat, nil, self.class, true)
      pip.set_val(:lon, nil, self.class, true)
      false
    end
  end
end