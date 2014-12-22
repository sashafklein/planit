module Services   
  class Clusterer

    attr_accessor :locations

    def initialize(locations)
      @locations = locations
      @clusters = break_into_clusters(locations)
    end

    def to_json
      clusters.inject([]) do |array, cluster|
        array << cluster.locations.inject({}) { |hash, loc| h[loc.name] == [loc.lat, loc.lon] }
      end
    end

# NEAREST < 0.5 = PAIR
# START W/ A PLACE ("NEW/SECOND")
# => SEARCH BASED ON LAT/LON TRIMMINGS? KNOW FOR SURE WHAT IT MEANS (SPEED UP)
# => FIND THE *CLOSEST*
# => "UNLINK" IT FROM ITS PAIR IF IT HAS ONE
# => CALCULATE (NEW) CENTERPOINT


# NEED TO STORE CENTER-POINTS FOR ALL OTHER CLUSTER FORMATION
# => CLUSTER INFO STORED AT MARK-LEVEL? MAYBE ALSO ITEM-LEVEL?
# PAIR
# WALKABLE
# RE-CALCULATED AT ADDITION OF ANY MARK/ITEM


    private

    def break_into_clusters(locations)
      
    end
  end
end