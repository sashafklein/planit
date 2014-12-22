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
        save_with_photos!
      end
      
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

      if !attributes[:extra] || !attributes[:extra].is_a?(Hash)
        attributes[:extra] = attributes[:extra] ? { detail: attributes.delete(:extra) } : {}
      end

      attributes.except(*Place.attribute_keys + [:nearby, :images]).each do |key, value|
        attributes[:extra][key] = attributes.delete(key)
      end
      attributes
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