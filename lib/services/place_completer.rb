module Services
  class PlaceCompleter

    attr_accessor :attrs, :place, :photo
    def initialize(attrs)
      @attrs = normalize(attrs)
    end

    def complete!
      @place = Place.find_or_initialize(attrs)

      load_region_info_from_nearby!
      geocode!
      api_complete!
      translate!

      @place = @place.find_and_merge
      @place.save_with_photos!( Array(@photo) )
      @place
    end

    private

    def geocode!
      return unless @place.street_address || @place.full_address
      @place = Services::Geolocater.new(place, attrs).narrow
      @geocoded = true
    end

    def load_region_info_from_nearby!
      @place = Services::Geolocater.new(place, attrs).load_region_info_from_nearby if attrs[:nearby]
    end

    def translate!
      @place = Services::Geolocater.new(place, attrs).translate
    end

    def api_complete!
      if @place.complete?
        @place
      else
        response = Services::ApiCompleter.new(@place, @attrs[:nearby], @geocoded).complete!
        @place, @photo = response[:place], response[:photo]
        @place
      end
    end

    def normalize(attributes)
      attributes[:names] = Array( attributes.delete(:names) ) + Array( attributes.delete(:name) )
      attributes[:street_addresses] = Array( attributes.delete(:street_addresses) ) + Array( attributes.delete(:street_address) )
      attributes[:categories] = Array( attributes.delete(:categories) ) + Array( attributes.delete(:category) )
      attributes[:phones] = { default: attributes.delete(:phone) } if attributes[:phone] && ! attributes[:phones]
      
      attributes[:extra] ||= {}
      attributes.except(*Place.attribute_keys << :nearby).each do |key, value|
        attributes[:extra][key] = attributes.delete(key)
      end
      attributes
    end
  end
end