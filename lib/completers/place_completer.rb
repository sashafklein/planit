Dir["./api_completer/*.rb"].each {|file| require_relative file }

module Completers
  class PlaceCompleter

    attr_accessor :attrs, :place, :photos, :pip, :url
    def initialize(attrs, url=nil)
      normalizer = PlaceAttrs.new(attrs.merge(scrape_url: url))
      @photos, @attrs, @flags = normalizer.set_photos, normalizer.normalize, normalizer.flags
      @pip = PlaceInProgress.new @attrs, @flags
      add_state("Start of PlaceCompleter")
    end

    def complete!
      api_complete! unless @pip.completed("FoursquareRefine")
      merge_and_save_with_photos!
    end

    private

    def api_complete!
      if area?
        google_maps unless pip.completed("GoogleMaps")
        narrow if !@google_success
      else
        nearby unless pip.coordinate
        foursquare
        google_maps if !pip.completed("FoursquareExplore")
        foursquare if retry_foursquare?
      end
      translate_and_refine
    end

    def foursquare
      foursquare_explore unless pip.completed("FoursquareExplore")
      foursquare_refine unless pip.completed("FoursquareRefine") || !pip.foursquare_id.present?
    end

    def google_maps
      add_api_response( ApiCompleter::GoogleMaps.new(pip, attrs).complete, "GoogleMaps" )
    end

    def narrow
      add_api_response( ApiCompleter::Narrow.new(pip, attrs, take: [:country, :region, :subregion, :locality]).complete, "Narrow" ) unless pip.completed("Narrow") || !pip.pinnable
    end

    def nearby
      add_api_response( ApiCompleter::Nearby.new(pip, attrs, take: [:country, :region, :subregion, :locality]).complete, "Nearby") unless pip.completed("Nearby") || !attrs.nearby
    end

    def foursquare_explore
      add_api_response( ApiCompleter::FoursquareExplore.new(pip, @attrs[:nearby]).complete, "FoursquareExplore" )
    end

    def foursquare_refine
      add_api_response( ApiCompleter::FoursquareRefine.new(pip).complete, "FoursquareRefine")
    end

    def translate_and_refine
      add_api_response( ApiCompleter::TranslateAndRefine.new(pip, attrs, take: [:country, :region, :subregion, :locality, :sublocality]).complete, "TranslateAndRefine" )
    end

    def add_state(name)
      pip.flag( name: "State", details: name, info: pip.clean_attrs )
    end

    def add_api_response(response, name)
      return unless instance_variable_set("@#{name.downcase}_success", response[:success])

      @pip = response[:place]
      @photos += Array(response[:photos]).flatten
      pip.set_val(:completion_steps, name, name)
      add_state("After #{name}")
    end

    def merge_and_save_with_photos!
      add_state("Before final merge")
      @place = pip.place.find_and_merge
      if @place.valid? 
        @place.validate_and_save!( @photos.uniq{ |p| p.url }, pip.flags ) 
      else
        nil
      end
    end

    def retry_foursquare?
      pip.flags.find{ |f| f.name == "Insufficient Atts for FoursquareExplore" } &&
        ApiCompleter::FoursquareExplore.new(pip).sufficient_to_fetch?
    end

    def area?
      false
    end
  end
end