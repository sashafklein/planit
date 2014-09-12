class PseudoDay

  include PseudoModel

  attr_accessor :items, :leg
  delegate :plan, to: :leg

  def initialize(hash, leg)
    @leg = leg
    @items = PseudoItem.serialize(hash.delete('items').compact, self)
    set_as_instance_variables({}, defaults)
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

  # def next_item
  #   ??
  # end

  def coordinates
    items.map(&:coordinate).join("+")
  end

  def day_in_trip
    items.first.parent_day
  end

  def items_with_tabs
    items.select(&:has_tab)
  end

  def should_be_mapped(day_index, item_index)
    day_index != 0 && items[item_index-1]
  end

  def previous_lodging(day_index)
    leg.days[day_index - 1].items.select(&:lodging).last
  end

  def previous(index)
    return nil if index == 0
    leg.days[index-1]
  end

  def has_lodging
    items.any?(&:lodging)
  end

  private

  def defaults
    { time_of_day: false }
  end
end