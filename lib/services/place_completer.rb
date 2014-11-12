module Services
  class PlaceCompleter

    attr_accessor :attrs, :place
    def initialize(attrs)
      @attrs = normalize(attrs)
    end

    def complete!
      @place = PlaceFinder.new(attrs).find!

      load_region_info_from_nearby! if attrs[:nearby]
      geocode!
      api_complete!

      @place.save! unless @place.persisted?
      @place
    end

    private

    def load_region_info_from_nearby!
      response = Geocoder.search(attrs.delete(:nearby)).first.data

      @place.country = fetch_address_value(response, "country")
      @place.region = fetch_address_value(response, "administrative_area_level_1")
      @place.subregion = fetch_address_value(response, "administrative_area_level_2", '')
      @place.locality = fetch_address_value(response, "locality")
    end

    def geocode!
      response = Geocoder.search( [@place.street_address, @place.locality, @place.subregion, @place.region, @place.country].compact.join(", ") ).first.data

      @place.lat = response['geometry']['location']['lat']
      @place.lon = response['geometry']['location']['lng']

      @place.subregion ||= fetch_address_value(response, "administrative_area_level_2")
      @place.locality ||= fetch_address_value(response, "locality")
      @place.postal_code = fetch_address_value(response, "postal_code", 'short_name')
      @place.full_address ||= response['formatted_address']
    end

    def api_complete!
      if @place.complete?
        @place
      else
        @place = Services::ApiCompleter.new(@place).complete!
        @place
      end
    end

    def fetch_address_value(response, type, length='long_name')
      component = response['address_components'].find{ |c| c['types'].include?(type) }
      component ? component[length] : nil
    end

    def normalize(attributes)
      attributes[:names] = Array( attributes.delete(:names) ) + Array( attributes.delete(:name) )
      attributes[:street_addresses] = Array( attributes.delete(:street_addresses) ) + Array( attributes.delete(:street_address) )
      attributes[:phones] = { default: attributes.delete(:phone) } if attributes[:phone] && ! attributes[:phones]
      attributes[:extra] ||= {}
      attributes.except(*Place.attribute_keys << :nearby).each do |key, value|
        attributes[:extra][key.to_sym] = attributes.delete(key)
      end
      attributes
    end
  end
end