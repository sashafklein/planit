module Completers
  class ApiCompleter::TranslateAndRefine < ApiCompleter::Geolocate

    def complete
      get_results( get_query )

      return response_hash unless venue.found?
      
      update_location_basics( true , block_non_latinate: true)
      response_hash
    end
  end
end