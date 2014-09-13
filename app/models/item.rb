class Item < ActiveRecord::Base
  
  before_save { category.downcase! }
  
  belongs_to :location
  belongs_to :day

  delegate :leg, to: :day
  delegate :plan, to: :leg

  has_one :arrival, class_name: 'Travel', foreign_key: 'destination_id'
  has_one :departure, class_name: 'Travel', foreign_key: 'origin_id'

  default_scope { order('order ASC') }

  scope :with_tabs,     ->        { where(show_tab: true) }
  scope :with_lodging,  ->        { where(lodging: true) }
  scope :sites,         ->        { where(lodging: false, meal: false) }
  scope :with_mark,     -> (mark) { |mark| where(planit_mark: mark) }
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

  def show_icon
    Icon.new(category, lodging, meal, mark).filename
  end

  def mark?(test_mark)
    mark == test_mark
  end

  def previous(index)
    return nil if index == 0
    siblings.find_by_order(order - 1)
  end

  private

  def siblings
    Item.where(day_id: day_id)
  end
end
