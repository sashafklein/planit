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
      pip.flag( name: 'State', details: 'Start of PlaceCompleter', info: pip.clean_attrs)
      locate_best_guess_with_google_maps!
      foursquare_explore!
      foursquare_refine_venue!
      translate_with_geocoder!
    end

    def locate_best_guess_with_google_maps!
      return if pip.lat && pip.lon
      response = GoogleMaps.new(pip, attrs).complete
      @pip = response[:place]
      @photos += response[:photos]
      pip.flag( name: 'State', details: 'After GoogleMaps', info: pip.clean_attrs)
    end

    def load_region_info_from_nearby!
      return unless attrs[:nearby]
      @pip = Nearby.new(pip, attrs).complete if attrs[:nearby]
      pip.flag( name: 'State', details: 'After Nearby', info: pip.clean_attrs)
    end

    def narrow_with_geocoder!
      return unless pip.pinnable
      @pip = Narrow.new(pip, attrs).complete 
      pip.flag( name: 'State', details: 'After Narrow', info: pip.clean_attrs)
    end

    def foursquare_explore!
      response = FoursquareExplore.new(pip, @attrs[:nearby]).complete!
      return unless response[:success]
      
      @pip = response[:place]
      @photos += response[:photos]
      pip.flag( name: 'State', details: 'After FoursquareExplore', info: pip.clean_attrs)
    end

    def foursquare_refine_venue!
      return if pip.foursquare_id.blank?
      response = FoursquareRefine.new(pip).complete 
      @pip = response[:place]
      @photos += response[:photos]
      pip.flag( name: 'State', details: 'After FoursquareRefine', info: pip.clean_attrs)
    end

    def translate_with_geocoder!
      location_vals = [pip.locality, pip.region, pip.country, pip.subregion].reject(&:blank?)
      return unless location_vals.any?(&:non_latinate?)
      @pip = Translate.new(pip, attrs).complete
      pip.flag( name: 'State', details: 'After Translate', info: pip.clean_attrs)
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
      pip.flag( name: 'State', details: 'After translate', info: pip.clean_attrs)
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