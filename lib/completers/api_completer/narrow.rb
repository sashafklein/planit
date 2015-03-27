module Completers
  class ApiCompleter::Narrow < ApiCompleter::Geolocate

    def complete
      return response_hash unless pip.pinnable

      get_results(get_query)

      return response_hash unless venue.found? && (!pip.destination? || response_address_is_specific?)

      if venue.seems_accurate?(pip)
        update_location_basics(true)
      else
        reverse_lat_lon_if_appropriate
        update_location_basics(false) # Don't trust locality
      end

      notify_if_geolocation_data_missing

      response_hash
    end

    private

    def response_address_is_specific?
      non_regional = full_address.cut(region, short_region, country, short_country, subregion, locality, postal_code, ',', ' ')
      non_regional.length > 2 
    end

    def notify_if_geolocation_data_missing
      failure_array = [:locality, :region, :country].select{ |attr| !send(attr) && !pip.val(attr) }
      pip.flag( name: "Failed geolocation", details: "Failed to find listed attrs in Narrow API call", info: failure_array) if failure_array.any?
    end
  end
end