class Day

  attr_accessor :items, :leg
  delegate :plan, to: :leg

  def initialize(hash, leg)
    @leg = leg
    @items = Item.serialize(hash.delete('items').compact, self)
  end

  def self.serialize(day_array, leg)
    day_array.map do |day|
      new(day, leg)  
    end
  end

  def last_item
    items.last
  end

  def first_item
    items.first
  end

  def coordinates
    items.map(&:coordinate).join("+")
  end

  def day_in_trip
    items.first.parent_day
  end

  def non_bucketed_items_with_tabs
    items.select(&:has_tab).select(&:parent_day)
  end
end