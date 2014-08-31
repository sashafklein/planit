class Leg

  include PseudoModel

  attr_accessor :days, :plan

  def initialize(hash, plan)
    @plan = plan
    @days = Day.serialize(hash.delete('days').compact, self)
    set_as_instance_variables hash
  end

  def self.serialize(leg_array, plan)
    leg_array.map do |leg|
      new(leg, plan)  
    end
  end

  def last_day
    days.last.last_item.parent_day
  end

  def first_day
    days.first.first_item.parent_day
  end

  def coordinates
    days.map(&:coordinates).join("+")
  end

  def arrival_method
    respond_to?(:arrival) ? arrival['method'] : ''
  end

  def departure_method
    respond_to?(:departure) ? departure['method'] : ''
  end

  def start
    days.first.items.first
  end

  def first_locale
    raise "No non-travel and non-loding sites for leg: #{leg.inspect}" unless sites.any?  
    sites.first 
  end

  def last_locale
    raise "No non-travel and non-loding sites for leg: #{leg.inspect}" unless sites.any?
    sites.last
  end

  private

  def sites
    days.map(&:items).flatten.reject{ |i| i.travel_type || i.lodging }
  end
end