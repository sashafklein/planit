class Location < ActiveRecord::Base

  has_one :item

  def self.center_coordinate(locations)
    [locations.average(:lat), locations.average(:lon)].join(":")
  end

  def coordinate
    return false unless lat && lon
    [lat, lon].join(":")
  end

  def local_name_unique?
    return true unless name && local_name
    local_name.downcase != name.downcase
  end
end
