module Completers
  class ApiCompleter::Pin < ApiCompleter::Geolocate

    def complete
      return response_hash unless pip.pinnable

      get_results(get_query)

      return response_hash unless venue.found?
      
      if pip.coordinate
        if venue.matcher(pip).ll_fit > 1
          set_vals fields: take , h_bump: -2
        elsif venue.matcher(pip).ll_fit > 0 || venue.location_type == "APPROXIMATE"
          set_vals fields: [:country, :region, :subregion, :locality]
        else
          reverse_lat_lon_if_appropriate
        end
      elsif venue.seems_accurate?(pip)
        set_vals fields: take, h_bump: -2
      end

      response_hash
    end

    private

    def response_address_is_specific?
      non_regional = full_address.cut(region, short_region, country, short_country, subregion, locality, postal_code, ',', ' ')
      non_regional.length > 2
    end
  end
end