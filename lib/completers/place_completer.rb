module Completers
  class PlaceCompleter

    attr_accessor :attrs, :place, :photos, :pip, :url
    def initialize(attrs, url=nil)
      @photos = set_photos(attrs)
      @attrs = attrs.symbolize_keys.to_sh
      normalize_attrs!
      @url = url
    end

    def complete!
      @pip = PlaceInProgress.new attrs.merge({scrape_url: url})
      api_complete! unless @pip.completion_steps.include?("FoursquareRefine")

      merge_and_save_with_photos!
    end

    private

    def api_complete!
      
      load_region_info_from_nearby!
      narrow_with_geocoder!
      foursquare_explore!
      foursquare_refine_venue!
      translate_with_geocoder!
    end

    def load_region_info_from_nearby!
      pip.flag( name: 'State', details: 'Before nearby', info: pip.clean_attrs)
      @pip = Nearby.new(pip, attrs).complete if attrs[:nearby]
    end

    def narrow_with_geocoder!
      pip.flag( name: 'State', details: 'Before narrow', info: pip.clean_attrs)
      @pip = Narrow.new(pip, attrs).complete if pip.pinnable
    end

    def foursquare_explore!
      pip.flag( name: 'State', details: 'Before foursquare explore', info: pip.clean_attrs)
      response = FoursquareExplore.new(pip, @attrs[:nearby]).complete!
      @pip = response[:place]
      @photos += response[:photos]
    end

    def foursquare_refine_venue!
      pip.flag( name: 'State', details: 'Before refine', info: pip.clean_attrs)
      unless pip.foursquare_id.blank?
        response = FoursquareRefine.new(pip).complete 
        @pip = response[:place]
        @photos += response[:photos]
      end
    end

    def translate_with_geocoder!
      pip.flag( name: 'State', details: 'Before translate', info: pip.clean_attrs)
      @pip = Translate.new(pip, attrs).complete
    end

    def normalize_attrs!
      [:name, :street_address, :category].each do |singular|
        plural = singular.to_s.pluralize.to_sym
        attrs[plural] = Array( attrs.delete(plural) ).flatten + Array( attrs.delete(singular)).flatten
      end

      attrs[:names] = attrs[:names].select(&:latinate?) + attrs[:names].select(&:non_latinate?)
      
      [:lat, :lon].each{ |att| attrs[att] = attrs.delete(att).try(:to_f) }

      attrs[:phones] = normalize_phones
      attrs[:hours] = normalized_hours(attrs[:hours])
      attrs[:extra] = normalize_extra

      found = Services::PlaceFinder.new(attrs).find!
      @attrs = attrs.merge( found.attributes.symbolize_keys.reject{ |k,v| v.nil? }.to_sh ) if found.persisted?
    end

    def normalize_phones
      array = []
      [:phones, :phone].each do |sym|
        val = attrs.delete(sym)
        array += val.values if val.is_a?(Hash)
        array += Array(val) if val.is_a?(String) || val.is_a?(Array)
      end
      attrs[:phones] = array.flatten
    end

    def normalize_extra
      attrs[:extra] ||= {}.to_sh
      if !attrs[:extra].is_a? Hash
        attrs[:extra] = { misc: attrs[:extra] }.to_sh
      end

      extra_attrs.each { |k, _| attrs[:extra][k] = attrs.delete(k) }
      attrs[:extra]
    end

    def normalized_hours(hours)
      normalized = {}
      (hours || {}).each do |k, v|
        normalized[k.to_s.downcase] = v.stringify_keys
      end
      Services::TimeConverter.convert_hours(normalized)
    end

    def set_photos(attrs)
      photo_array = Array( attrs.delete(:images) )
      @photos = photo_array.map{ |a| Image.new({ url: a[:url], source_url: a[:source], source: a[:credit] }) }
    end

    def extra_attrs
      attrs.except(*Place.attribute_keys + [:nearby, :images])
    end

    def merge_and_save_with_photos!
      pip.flag( name: 'State', details: 'Before save', info: pip.clean_attrs)
      @place = pip.place.find_and_merge
      if @place.valid? 
        @place.validate_and_save!( @photos.uniq{ |p| p.url }, pip.flags ) 
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