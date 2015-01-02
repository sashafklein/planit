module Completers
  class PlaceCompleter

    attr_accessor :attrs, :place, :photos, :pip
    def initialize(attrs)
      @photos = set_photos(attrs)
      @attrs = normalize(attrs)
    end

    def complete!
      @pip = PlaceInProgress.new(attrs)
      
      load_region_info_from_nearby!
      narrow_with_geocoder!
      foursquare_complete!
      translate_with_geocoder!
      merge_and_save_with_photos!
    end

    private

    def load_region_info_from_nearby!
      @pip = Nearby.new(pip, attrs).complete if attrs[:nearby]
    end

    def narrow_with_geocoder!
      @pip = Narrow.new(pip, attrs).complete unless !pip.pinnable
    end

    def translate_with_geocoder!
      @pip = Translate.new(pip, attrs).complete
    end

    def foursquare_complete!
      unless pip.place.complete?
        response = FourSquare.new(pip, @attrs[:nearby]).complete!
        @pip = response[:place]
        @photos += response[:photos]
      end
    end

    def normalize(attributes)
      [:name, :street_address, :category].each do |singular|
        plural = singular.to_s.pluralize.to_sym
        attributes[plural] = Array( attributes.delete(plural) ) + Array( attributes.delete(singular))
      end
      
      attributes[:lat] = attributes[:lat] ? attributes[:lat].to_f : nil
      attributes[:lon] = attributes[:lon] ? attributes[:lon].to_f : nil

      attributes[:hours] = normalized_hours(attributes[:hours])
      attributes[:extra] ||= {}
      attributes[:phones] = { default: attributes.delete(:phone) } if attributes[:phone] && ! attributes[:phones]

      attributes.except(*Place.attribute_keys + [:nearby, :images]).each do |key, value|
        attributes[:extra][key] = attributes.delete(key)
      end

      attributes
    end

    def normalized_hours(hours)
      normalized = {}
      (hours || {}).each do |k, v|
        normalized[k.to_s.downcase] = v.stringify_keys
      end
      normalized
    end

    def set_photos(attrs)
      photo_array = Array( attrs.delete(:images) )
      @photos = photo_array.map{ |a| Image.new({ url: a[:url], source_url: a[:source], source: a[:credit] }) }
    end

    def merge_and_save_with_photos!
      @place = pip.place.find_and_merge
      @place.save_with_photos!( @photos )
    end
  end
end