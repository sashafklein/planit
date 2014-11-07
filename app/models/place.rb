class Place < ActiveRecord::Base

  after_touch { names = names.compact.uniq if names_changed? }

  has_one :item
  has_many :images, as: :imageable
  extend ActiveRecord::ClassInfo

  def name
    names.first
  end

  def self.center_coordinate(locations)
    [locations.average(:lat), locations.average(:lon)].join(":")
  end

  def coordinate(joiner=':')
    return false unless lat && lon
    [lat, lon].join( joiner )
  end

  def local_name_unique?
    return true unless name && local_name
    local_name.downcase != name.downcase
  end

  def full
    string = ''
    string += locality.titleize unless locality.blank?
    string += country.titleize unless country.blank?
    string
  end

  def nearby
    return nil unless [locality, region, country].any?(&:present?)
    [locality, region, country].reject(&:blank?).join(", ")
  end
end
