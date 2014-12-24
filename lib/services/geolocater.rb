module Services
  class Geolocater

    include RegexLibrary

    attr_accessor :place, :atts, :response
    def initialize(place, atts={})
      @place, @atts = place, atts
    end

    def translate
      location_vals = [@place.locality, @place.region, @place.country, @place.subregion].reject(&:blank?)

      return success unless location_vals.any?(&:non_latinate?)

      @place.set_country get_value(response, "country") if should_translate?(place.country)
      @place.set_region get_value(response, "administrative_area_level_1") if should_translate?(place.region)
      update_locale should_translate?(place.subregion), should_translate?(place.locality)

      get_results( @place.coordinate(', ') )
      update_location_basics unless response.empty?
      success
    end

    def load_region_info_from_nearby
      return failure unless atts[:nearby]

      get_results(atts[:nearby])

      update_location_basics(false)
      success
    end

    def narrow
      return failure unless @place.pinnable

      get_results(get_query)

      return failure unless response_address_is_specific?

      if seems_accurate?
        update_location_basics
        @place.lat = lat
        @place.lon = lon
        @place.postal_code = postal_code
        @place.full_address ||= full_address
      else
        note_if_lat_lon_possibly_reversed
        update_location_basics(true, false) # Don't trust locality
      end

      notify_if_geolocation_data_missing

      success
    end

    private

    def seems_accurate?
      return @sa if @sa

      return @sa = false if location_type == "APPROXIMATE"
      return @sa = true unless place.lat && place.lon
      @sa = lat.points_of_similarity(place.lat) > 1 && lon.points_of_similarity(place.lon) > 1
    end

    def update_location_basics(update_subregion=true, update_locality=true, overwrite=false)
      @place.set_country get_value(response, "country") if place.country.blank? || overwrite
      @place.set_region get_value(response, "administrative_area_level_1") if place.region.blank? || overwrite
      update_locale(update_subregion, update_locality)
    end

    def update_locale(update_subregion=true, update_locality=true)
      @place.subregion = get_value(response, "administrative_area_level_2") if update_subregion
      @place.locality = get_value(response, "locality") if update_locality
      @place.extra[:sublocality] = sublocality if sublocality if update_locality
    end

    def response_address_is_specific?
      return false if response.blank?
      non_regional = full_address.cut(region, short_region, country, short_country, subregion, locality, postal_code, ',', ' ')
      non_regional.length > 2
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
      @response = response_data(query) || response_data(place.coordinate(', ')) || {}
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
      { place: @place, success: false }
    end

    def success
      { place: @place, success: true }
    end

    def notify_if_geolocation_data_missing
      place.flag("Failed to find geolocation data for locality") if !locality && !place.locality
      place.flag("Failed to find geolocation data for region") if !region && !place.region
      place.flag("Failed to find geolocation data for country") if !country && !place.country
    end

    def note_if_lat_lon_possibly_reversed
      return if [lat, lon, place.lat, place.lon].any?(&:nil?)
      total_lat_lon_similarity = lat.points_of_similarity(place.lat) + lon.points_of_similarity(place.lon)
      total_reversed_similarity = lat.points_of_similarity(place.lon) + lon.points_of_similarity(place.lat)
      if total_reversed_similarity > total_lat_lon_similarity
        place.flag("Possible Reversed Lat Lon. Place: #{place.coordinate}, Geocoder: #{[lat, lon].join(':') }")
      end
    end

    def get_query
      return @query if @query
      if place.lat && place.lon 
        @query = place.coordinate(", ")
      elsif place.street_address
        @query = [place.street_address, place.locality, place.subregion, place.region, place.country].reject(&:blank?).join(", ")
      else
        @query = place.full_address
      end
    end

    def should_translate?(place_attr)
      place_attr.blank? || place_attr.non_latinate?
    end
  end
end