module Completers
  class ApiCompleter::TranslateAndRefine < ApiCompleter::Geolocate

    def complete
      get_results( get_query )

      return response_hash unless venue.found?
      
      response_hash
      update_location_basics( true )
      response_hash
    end
  end
end