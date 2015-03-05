Dir["./api_completer/*.rb"].each {|file| require_relative file }

module Completers
  class PlaceCompleter

    attr_accessor :attrs, :place, :pip, :url
    def initialize(attrs, url=nil)
      normalizer = PlaceMod::Attrs.new(attrs.merge(scrape_url: url))
      @attrs, @flags, @url = normalizer.normalize, normalizer.flags, url
      @pip = PlaceInProgress.new @attrs, @flags, normalizer.set_photos
      add_state("Start of PlaceCompleter")
    end

    def complete!
      return nil unless @pip.names.any? && some_location_data?

      api_complete! unless @pip.completed("FoursquareRefine")
      merge_and_save_with_photos!
    end

    private

    def api_complete!
      if !pip.destination?
        google_maps unless pip.completed("GoogleMaps")
        narrow if !@google_maps_success
      else
        nearby unless pip.coordinate
        foursquare
        google_maps if (!pip.completed("FoursquareExplore") || pip.unsure.any?) || !pip.street_address
        foursquare if retry_foursquare?
        pin if (pip.completion_steps - ["Nearby"]).empty?
      end
      translate_and_refine
      flag_it_up
    end

    def foursquare
      foursquare_explore unless pip.completed("FoursquareExplore") || ( pip.complete("FoursquareExplore") if pip.foursquare_id.present? )
      foursquare_refine unless pip.completed("FoursquareRefine") || !pip.foursquare_id.present? || pip.unsure.include?("FoursquareExplore")
    end

    def google_maps
      add_api_response( "GoogleMaps" )
    end

    def narrow
      add_api_response( "Narrow", take: [:country, :region, :subregion, :locality] ) unless pip.completed("Narrow") || !pip.pinnable
    end

    def pin
      add_api_response( 'Pin', take: [:country, :region, :subregion, :locality, :sublocality, :lat, :lon ] ) unless pip.completed("Pin")
    end

    def nearby
      add_api_response( 'Nearby', take: [:country, :region, :subregion, :locality] ) unless pip.completed("Nearby") || !attrs.nearby
    end

    def foursquare_explore
      add_api_response( 'FoursquareExplore' )
    end

    def foursquare_refine
      add_api_response( 'FoursquareRefine' )
    end

    def translate_and_refine
      add_api_response( 'TranslateAndRefine', take: [:country, :region, :subregion, :locality, :sublocality] ) unless pip.completed("Pin")
    end

    def api_call(name, take=nil)
      "Completers::ApiCompleter::#{name}".constantize.new(pip, attrs, take: take).complete
    end

    def add_state(name)
      pip.flag( name: "State", details: name, info: pip.clean_attrs )
    end

    def add_api_response(name, take: nil)
      return unless !pip.completed(name) && response = api_call(name, take)
      return unless instance_variable_set("@#{name.underscore}_success", response[:success])

      @pip = response[:place]
      pip.set_val(field: :completion_steps, val: name, source: name)
      add_state("After #{name}")
    end

    def flag_it_up
      pip.flag(name: "Triangulated", details: "Save as alternative in future", info: pip.attrs) if pip.triangulated
      pip.flag(name: "Tracking Data", info: { attrs: pip.attrs, images: pip.photos } )
    end

    def merge_and_save_with_photos!
      add_state("Before final merge")
      @place = pip.place.find_and_merge
      @place.validate_and_save!( pip.photos.uniq{ |p| p.url }, pip.all_flags ) 
    rescue => e
      place_options.any? ? place_options : nil
    end

    def retry_foursquare?
      (pip.unsure.any? && pip.newer_info_on_unsure? ) || 
        ( pip.completed("FoursquareExplore") && !pip.completed("FoursquareRefine") ) ||
        ( pip.flags.find{ |f| f.name == "Insufficient Atts for FoursquareExplore" } &&
          ApiCompleter::FoursquareExplore.new(pip).sufficient_to_fetch? )
    end

    def place_options
      pip.datastores.reject{ |d| d._name == 'Base' }.map{ |d| PlaceOption.from_datastore(d, pip.feature_type) }
    end

    def some_location_data?
      (pip.coordinate) || pip.locality || pip.region || pip.subregion || pip.sublocality || pip.country || pip.street_address || pip.full_address || attrs.nearby
    end
  end
end