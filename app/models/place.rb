class Place < ActiveRecord::Base

  before_save { self.names = names.compact.uniq if names_changed? }
  before_save { self.street_addresses = street_addresses.compact.uniq if street_addresses_changed? }

  has_one :item
  has_many :images, as: :imageable
  
  include ActiveRecord::MetaExt
  validate!

  scope :with_address, -> (address) { address.blank? ? all : where("'#{ address.is_a?(Array) ? address.first : address }' = ANY (street_addresses)") }
  scope :with_name, -> (name) { name.blank? ? all : where("'#{ name.is_a?(Array) ? name.first : name }' = ANY (names)") }

  def name
    names.first
  end

  def street_address
    street_addresses.first
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
    return @nearby if @nearby
    return nil unless [locality, region, country].any?(&:present?)
    @nearby ||= [locality, region, country].reject(&:blank?).join(", ")
  end
end
