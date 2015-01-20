class Mark < ActiveRecord::Base

  include ActiveRecord::MetaExt
    
  before_save { category.downcase! if category_changed? }
  
  belongs_to :place
  belongs_to :user

  has_many :items

  delegate :names, :name, :categories, :category, :coordinate, :url, :phones, :phone, :website,
           :country, :region, :locality, :sublocality, :images, :image, :street_address, to: :place

  delegate :full, :lodging, to: :place, prefix: true

  has_one :arrival, class_name: 'Travel', foreign_key: 'to_id'
  has_one :departure, class_name: 'Travel', foreign_key: 'from_id'

  scope :with_tabs,     ->        { where(show_tab: true) }
  scope :with_lodging,  ->        { where(lodging: true) }
  scope :sites,         ->        { where(lodging: false, meal: false) }
  scope :with_mark,     -> (mark) { where(mark: mark) }
  scope :marked_up,     ->        { with_mark('up') }
  scope :marked_down,   ->        { with_mark('up') }
  scope :starred,       ->        { with_mark('star') }

  def self.places
    Place.where(id: pluck(:place_id))
  end

  class << self
    # delegate :coordinates, to: :places
  end

  def self.coordinates
    places.map(&:coordinate)
  end

  def self.center_coordinate
    Place.center_coordinate(places)
  end

  def self.all_names
    places.map(&:name)
  end

  def self.all_ids
    places.pluck(:id)
  end

  def self.all_countries
    places.att_by_frequency(:country)
  end

  def self.all_regions
    places.att_by_frequency(:region)
  end

  def self.all_localities
    places.att_by_frequency(:locality)
  end
  
  # def self.all_types
  #   places.countries
  # end

  def show_icon
    @show_icon ||= Icon.new(category, lodging, meal, mark).filename
  end

  def mark?(test_mark)
    mark == test_mark
  end

  def previous
    siblings.find_by_order(order - 1)
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

  private

  def siblings
    Item.where(day_id: day_id)
  end
end
