class Item < ActiveRecord::Base
  
  before_save { category.downcase! if category }
  
  belongs_to :location
  belongs_to :day
  belongs_to :user
  
  has_many :images, as: :imageable
  belongs_to :group, polymorphic: true

  delegate :leg, to: :day
  delegate :plan, to: :leg
  delegate :name, :local_name, :coordinate, :url, :phone, :local_name_unique?, :street_address, to: :location
  delegate :full, :lodging, to: :location, prefix: true

  has_one :arrival, class_name: 'Travel', foreign_key: 'to_id'
  has_one :departure, class_name: 'Travel', foreign_key: 'from_id'

  default_scope { order('"order" ASC') }

  scope :with_tabs,     ->        { where(show_tab: true) }
  scope :with_lodging,  ->        { where(lodging: true) }
  scope :sites,         ->        { where(lodging: false, meal: false) }
  scope :with_mark,     -> (mark) { where(mark: mark) }
  scope :marked_up,     ->        { with_mark('up') }
  scope :marked_down,   ->        { with_mark('up') }
  scope :starred,       ->        { with_mark('star') }

  def self.locations
    Location.where(id: pluck(:location_id))
  end

  def self.coordinates
    locations.map(&:coordinate).join("+")
  end

  def self.center_coordinate
    Location.center_coordinate(locations)
  end

  def self.from_flat_hash!(params)
    return unless params
    location_keys = %w(name local_name postal_code street_address cross_street phone country state city lat lon url).map(&:to_sym)
    location = Location.where(params.select{ |k| location_keys.include?(k) }).first_or_create!
    new_item = create!( params.reject{ |k| location_keys.include?(k) || k == :photo }.merge(location_id: location.id) )
    new_item.images.where(url: params[:photo]).first_or_create! if params[:photo]
    new_item
  end

  def show_icon
    @show_icon ||= Icon.new(category, lodging, meal, mark).filename
  end

  def mark?(test_mark)
    mark == test_mark
  end

  def previous
    siblings.find_by_order(order - 1)
  end

  def image
    images.first
  end

  def recoby
    nil #todo -- make a column or two
  end

  def downby
    nil #todo -- make a column or two
  end

  def rating
    nil #todo -- make a column or two
  end

  def show_arrival
    "Arrive by #{arrival.mode} to #{name}"
  end

  def show_departure
    "Depart by #{departure.mode} to #{name}"
  end

  def is?(category_type)
    categories.include?(category_type.to_s)
  end

  def categories
    @categories ||= CategorySet.new(self).list
  end

  private

  def siblings
    Item.where(day_id: day_id)
  end
end
