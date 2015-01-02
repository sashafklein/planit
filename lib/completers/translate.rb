module Completers
  class Translate < Geolocate

    def complete
      location_vals = [pip.locality, pip.region, pip.country, pip.subregion].reject(&:blank?)

      return success unless location_vals.any?(&:non_latinate?)

      get_results( get_query )

      if response.empty?
        failure
      else
        update_location_basics( should_translate?(pip.subregion), should_translate?(pip.locality), true )
        success
      end
    end

    private

    def should_translate?(place_attr)
      place_attr.blank? || place_attr.non_latinate?
    end
  end
end