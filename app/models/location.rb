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

  def full
    string = ''
    string += city.titleize unless city.blank?
    string += country.titleize unless country.blank?
    string
  end

  def lodging
    return '' unless street_address || city || state
    [street_address, city, state].compact.join(", ")
  end
end
