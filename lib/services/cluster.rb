module Servies
    class Cluster

    attr_accessor :locations, :bounds

    def initialize(locations)
      @locations = locations
      @bounds = bounds_from_locations(locations)
    end

    private

    def bounds_from_locations(locations)
      
    end
  end
end