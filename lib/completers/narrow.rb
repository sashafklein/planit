module Completers
  class Narrow < Geolocate

    def complete
      return failure unless pip.pinnable

      get_results(get_query)
      
      return failure unless response_address_is_specific?

      if seems_accurate?
        update_location_basics(true, true, true)
        pip.set_val(:lat, lat, self.class)
        pip.set_val(:lon, lon, self.class)
        pip.set_val(:postal_code, postal_code, self.class)
        pip.set_val(:full_address, full_address, self.class) if !pip.full_address
      else
        reverse_lat_lon_if_appropriate
        update_location_basics(true, false) # Don't trust locality
      end

      notify_if_geolocation_data_missing

      success
    end

    private

    def response_address_is_specific?
      return false if response.blank?
      non_regional = full_address.cut(region, short_region, country, short_country, subregion, locality, postal_code, ',', ' ')
      non_regional.length > 2
    end

    def notify_if_geolocation_data_missing
      pip.set_val( :flags, "Failed to find geolocation data for locality", self.class) if !locality && !pip.locality
      pip.set_val( :flags, "Failed to find geolocation data for region", self.class) if !region && !pip.region
      pip.set_val( :flags, "Failed to find geolocation data for country", self.class) if !country && !pip.country
    end
  end
end