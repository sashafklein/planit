module Completers
  class ApiCompleter::TranslateAndRefine < ApiCompleter::Geolocate

    def complete
      get_results( get_query )

      return response_hash unless venue.found?
      
      update_location_basics(block_non_latinate: true)
      response_hash
    end

    def update_location_basics(block_non_latinate: false)
      set_only_non_latinate [:country, :region, :subregion, :locality, :sublocality]
    end

    def set_only_non_latinate(fields)
      overwriteable_fields = fields.reject{ |f| pip.val(f) && pip.val(f).latinate? }.select{ |f| take?(f) }
      set_vals fields: overwriteable_fields, block_non_latinate: true
    end
  end
end