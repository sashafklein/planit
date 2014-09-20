class Day < ActiveRecord::Base

  belongs_to :leg
  has_many :items

  default_scope { order('"order" DESC') }

  delegate :plan, to: :leg
  delegate :user, to: :plan
  
  delegate :coordinates, :center_coordinate, to: :items
  delegate :parent_day, to: :first_item, as: :day_in_trip

  def last_item
    items.last
  end

  def first_item
    items.first
  end

  def should_be_mapped(item_index)
    !first_in_leg? && items.find_by_order(item_index-1)
  end

  def previous_lodging(day_index)
    return nil unless previous
    previous.items.with_lodging.last
  end

  def previous
    return nil if first_in_leg?
    siblings.find_by_order( order - 1 )
  end

  def has_lodging
    items.with_lodging.any?
  end

  def first_in_leg?
    order == 0
  end

  def place_in_trip
    plan.days.index(self) + 1
  end

  private

  def siblings
    leg.days
  end
end
