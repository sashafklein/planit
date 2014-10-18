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

  private

  def break_into_clusters(locations)
    
  end
end