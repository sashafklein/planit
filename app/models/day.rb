class Day < BaseModel

  belongs_to :leg
  has_many :items

  default_scope { order('leg_id ASC').order('"order" ASC') }

  delegate :plan, to: :leg
  delegate :user, to: :plan
  
  # delegate :coordinates, :center_coordinate, to: :items
  delegate :parent_day, to: :first_item, as: :day_in_trip

  # DAYS. OPERATORS

  # DAY OPERATORS

  def has_lodging?
    items.marks.where(lodging: true).any?
  end

  def last_item
    items.last
  end

  def first_item
    items.first
  end

  def should_be_mapped(item_index)
    !first_in_leg? && items.find_by_order(item_index-1)
  end

  def previous_lodging
    return nil unless previous
    previous.items.with_lodging.last
  end

  def items_including_prior_days_lodging
    [previous_lodging].compact + items
  end

  def coordinates_including_prior_days_lodging
    previous_coordinate = previous_lodging.coordinate unless !previous_lodging
    [previous_coordinate, items.coordinates].compact.join("+")
  end

  def next
    return nil if last_in_day?
    siblings.find_by_order( order + 1 )
  end

  def previous
    return nil if first_in_leg?
    siblings.find_by_order( order - 1 )
  end

  def previous_ok_prior_leg
    leg.previous.days.last unless !leg.previous.present?  
  end

  def has_lodging?
    items.with_lodging.any?
  end

  def first_in_leg?
    order == 0
  end

  def last_in_leg?
    order == order.length
  end

  def place_in_trip
    @place ||= plan.days.index(self)
  end

  def coordinates
    items.map(&:coordinate).join("+")
  end

  def center_coordinate
    items.center_coordinate
  end

  private

  def siblings
    leg.days
  end
end
