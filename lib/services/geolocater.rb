module Services
  class Geolocater

    include RegexLibrary

    attr_accessor :place, :atts, :response
    def initialize(place, atts={})
      @place, @atts = place, atts
    end

    def translate
      location_vals = [@place.locality, @place.region, @place.country, @place.subregion].reject(&:blank?)

      return @place unless location_vals.any?(&:non_latinate?)

      get_results( @place.coordinate(', ') )

      update_location_basics
      @place
    end

    def load_region_info_from_nearby
      return place unless atts[:nearby]

      get_results(atts[:nearby])

      update_location_basics(false)
      @place
    end

    def narrow
      return @place unless @place.street_address || @place.full_address 

      query = @place.street_address ? [@place.street_address, @place.locality, @place.subregion, @place.region, @place.country].reject(&:blank?).join(", ") : @place.full_address
      get_results(query)

      return @place unless is_specific?

      update_locale
      @place.lat = lat
      @place.lon = lon
      @place.postal_code = postal_code
      @place.full_address ||= full_address
      @place
    end

    private

    def update_location_basics(update_subregion=true)
      @place.set_country get_value(response, "country")
      @place.set_region get_value(response, "administrative_area_level_1") 
      update_locale(update_subregion)
    end

    def update_locale(update_subregion=true)
      @place.subregion = get_value(response, "administrative_area_level_2") if update_subregion
      @place.locality = get_value(response, "locality")
    end

    def is_specific?
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

    def postal_code
      @postal_code ||= get_value(response, "postal_code", 'short_name')
    end

    def full_address
      @full_address ||= response['formatted_address']
    end

    def get_results(query)
      @response = Geocoder.search( query ).first.data
    end

    def get_value(response, type, length='long_name')
      component = response['address_components'].find{ |c| c['types'].include?(type) }
      component ? component[length] : nil
    end
  end
end