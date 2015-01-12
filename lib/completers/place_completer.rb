module Completers
  class PlaceCompleter

    attr_accessor :attrs, :place, :photos, :pip, :url
    def initialize(attrs, url=nil)
      @photos = set_photos(attrs)
      @attrs = normalize(attrs)
      @url = url
    end

    def complete!
      @pip = PlaceInProgress.new(attrs.merge(scrape_url: url))
      
      load_region_info_from_nearby!
      narrow_with_geocoder!
      foursquare_explore!
      foursquare_refine_venue!
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

    def foursquare_refine_venue!
      unless pip.foursquare_id.blank?
        response = FoursquareRefine.new(pip).complete 
        @pip = response[:place]
        @photos += response[:photos]
      end
    end

    def foursquare_explore!
      response = FoursquareExplore.new(pip, @attrs[:nearby]).complete!
      @pip = response[:place]
      @photos += response[:photos]
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
      if @place.valid? 
        @place.validate_and_save!( @photos.uniq{ |p| p.url } ) 
      else
        
        nil
      end
    end

    def notify_of_invalid_place!
      if Rails.environment.test? || Rails.environment.development?
        raise
      else
        # PlaceMailer.notify_of_invalid_place(place).deliver
      end
    end
  end
end