module Completers
  class Nearby < Geolocate

    def complete
      return failure unless atts[:nearby]

      pip.flag(name: "API Query", details: "In #{self.class}", info: { query: atts[:nearby] })
      get_results(atts[:nearby])

      update_location_basics(false)
      success
    end
  end
end