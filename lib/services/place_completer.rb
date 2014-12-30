module Services
  class PlaceCompleter

    attr_accessor :attrs, :place, :photos
    def initialize(attrs)
      @photos = set_photos(attrs)
      @attrs = normalize(attrs)
    end

    def complete!
      @place = Place.find_or_initialize(attrs)

      unless @place.persisted?
        load_region_info_from_nearby!
        geocode!
        api_complete!
        translate!

        @place = @place.find_and_merge
      end

      save_with_photos!
      @place
    end

    private

    def geocode!
      return unless @place.pinnable
      geolocation = Services::Geolocater.new(place, attrs).narrow
      @place = geolocation[:place]
      @place.add_completion_step("Geocode") if @geocoded = geolocation[:success]
    end

    def load_region_info_from_nearby!
      if attrs[:nearby]
        region_geolocation = Services::Geolocater.new(place, attrs).load_region_info_from_nearby
        @place = region_geolocation[:place]
        @place.add_completion_step("Load Region Info From Nearby") if region_geolocation[:success]
      end
    end

    def translate!
      translation = Services::Geolocater.new(place, attrs).translate
      @place = translation[:place]
      @place.add_completion_step("Translate") if translation[:success]
    end

    def api_complete!
      if @place.complete?
        @place
      else
        response = Services::ApiCompleter.new(@place, @attrs[:nearby], @geocoded).complete!
        @place.add_completion_step("API")
        @place = response[:place]
        @photos += response[:photos]
        @place
      end
    end

    def normalize(attributes)
      attributes[:names] = Array( attributes.delete(:names) ) + Array( attributes.delete(:name) )
      attributes[:street_addresses] = Array( attributes.delete(:street_addresses) ) + Array( attributes.delete(:street_address) )
      attributes[:categories] = Array( attributes.delete(:categories) ) + Array( attributes.delete(:category) )
      attributes[:phones] = { default: attributes.delete(:phone) } if attributes[:phone] && ! attributes[:phones]
      attributes[:lat] = attributes[:lat] ? attributes[:lat].to_f : nil
      attributes[:lon] = attributes[:lon] ? attributes[:lon].to_f : nil
      attributes[:hours] = attributes[:hours] ? normalized_hours(attributes[:hours]) : {}

      if !attributes[:extra] || !attributes[:extra].is_a?(Hash)
        attributes[:extra] = attributes[:extra] ? { detail: attributes.delete(:extra) } : {}
      end

      attributes.except(*Place.attribute_keys + [:nearby, :images]).each do |key, value|
        attributes[:extra][key] = attributes.delete(key)
      end

      attributes
    end

    def normalized_hours(hours)
      normalized = {}
      hours.each do |k, v|
        normalized[k.to_s.downcase] = v.stringify_keys
      end
      normalized
    end

    def set_photos(attrs)
      photo_array = Array( attrs.delete(:images) )
      @photos = photo_array.map{ |a| Image.new({ url: a[:url], source_url: a[:source], source: a[:credit] }) }
    end

    def save_with_photos!
      @place = @place.save_with_photos!( @photos )
    end
  end
end