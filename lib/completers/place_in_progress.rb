module Completers
  class PlaceInProgress

    attr_accessor :unsure, :ds, :completion_steps, :triangulated

    delegate *(Place.attribute_keys + [:coordinate, :pinnable, :name, :phone, :street_address, :foursquare_id, :destination?]), to: :place
    delegate :attrs, :val, :source, :sources, :info, :set_val, :raw_attrs, :clean_attrs, :update, :nearby, :photos, to: :ds

    def initialize(attributes={}, flags=[], photos=[])
      @_base = new_datastore(seed: attributes, name: "Base", instance_vars: { photos: photos })
      @flags, @completion_steps, @unsure, @triangulated = flags, [], [], false
      @ds = @_base
    end

    def set_ds(datastore_name=:base)
      new_ds = datastore(datastore_name)
      @ds = new_ds
    end

    def all_flags
      ([flags] + [ds.flags]).flatten
    end

    def place
      Place.new raw_attrs.to_h
    end

    def flag(name:, details: nil, info: nil)
      @flags << place.flag(name: name, details: details, info: info)
    end

    def completed(*steps)
      steps.all?{ |s| completion_steps.include?(s) }
    end

    def completed_any(*steps)
      steps.any?{ |s| completion_steps.include?(s) }
    end

    def complete(step)
      completion_steps = ( @completion_steps + Array(step) ).flatten.uniq
    end

    def flush!(ds_name=:base)
      remove_instance_variable("@_#{ds_name}")
      set_ds
    end

    def load!(from, hierarchy_bump=10) # Tend towards overriding on explicit side-load
      from_ds = get_datastore(from)
      set_ds

      from_ds.clean_attrs.each do |k, v| 
        @ds.set_val(field: k, val: from_ds.val(k), source: from_ds.source(k), hierarchy_bump: hierarchy_bump)
      end 

      flush!(from)
    end

    def datastores
      instance_variables.select{ |s| s.to_s[1] == '_' }.map do |s|
        get_datastore( s[2..-1] )
      end
    end

    def previous(source_name)
      source_hierarchy[ 0..( source_hierarchy.index(source_name)) ]
    end

    def load_and_flush_siblings!(dstore)
      return unless dstore and dstore.is_a?(TrackHash)
      siblings = datastores.select{ |d| d._name.include?( dstore._name[0..-2] ) }
      siblings.each{ |d| flush!(d._name.underscore) unless d == dstore }
      load!( dstore._name.underscore )
    end

    def viable_datastores(type_name:, venue:)
      datastores.select do |d| 
        d.type == type_name &&
          ( d.val(:names).include?(venue.name) || 
            venue.matcher(d.clean_attrs).ll_fit >= 3 )
      end
    end

    def flags(flag_name=nil)
      flag_name ? @flags.select{ |f| f.name == flag_name } : @flags
    end

    def question!(completer_name)
      @unsure = (@unsure + [completer_name]).uniq
    end

    def newer_info_on_unsure?
      unsure.any? do |step|
        completion_steps.any? do |done|
          source_hierarchy.index(done) > source_hierarchy.index(step)
        end
      end
    end

    def generate_nearby
      place.nearby
    end

    def nearby
      ds.val :nearby
    end

    def add_photos(to_add)
      ds.photos = [ds.photos + Array(to_add)].flatten.compact
    end

    private

    def get_datastore(ds_name)
      instance_variable_get("@_#{ds_name}")
    end

    def datastore(ds_name)
      ds_name ||= :base
      get_datastore(ds_name) || make_datastore(ds_name)
    end

    def make_datastore(ds_name)
      instance_variable_set("@_#{ds_name}", new_datastore(name: ds_name.to_s.camelize))
    end

    # Rightmost has greatest overwrite permissions
    def source_hierarchy
      %w(PlaceInProgress Pin Nearby Narrow FoursquareExplore FoursquareRefine GoogleMaps TranslateAndRefine)
    end

    def new_datastore(seed: nil, name: nil, instance_vars: {photos: []})
      TrackHash.new(defaults: Place.new.attributes, attrs: seed, acceptance_hierarchy: source_hierarchy, name: name, instance_vars: instance_vars)
    end
  end
end