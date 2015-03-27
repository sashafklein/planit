module Completers
  class ApiCompleter::Nearby < ApiCompleter::Geolocate

    def complete
      return response_hash unless atts[:nearby]

      flag_query(atts[:nearby])
      get_results(atts[:nearby])

      return response_hash unless venue.found? 

      update_location_basics
      response_hash
    end
  end
end