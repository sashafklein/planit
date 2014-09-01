class Leg

  include PseudoModel

  attr_accessor :days, :plan

  def initialize(hash, plan)
    @plan = plan
    @days = Day.serialize( hash.delete('days').compact, self )
    set_as_instance_variables( hash, defaults )
    # , that_thing: 'default_value'
  end
  
  def self.serialize(leg_array, plan)
    leg_array.map do |leg|
      new(leg, plan)  
    end
  end

  def only_leg
    plan.legs.count == 1
  end

  def caption
    if first_locale.city && last_locale.city && first_locale != last_locale
      "From #{first_locale.city} to #{last_locale.city}"
    else
      "From #{first_locale.name} to #{last_locale.name}"      
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
    arrival ? arrival['method'] : ''
  end

  def departure_method
    departure ? departure['method'] : ''
  end

  def start
    days.first.items.first
  end

  def first_locale
    raise "No non-travel and non-lodging sites for leg: #{leg.inspect}" unless sites.any?  
    sites.first 
  end

  def last_locale
    raise "No non-travel and non-lodging sites for leg: #{leg.inspect}" unless sites.any?
    sites.last
  end

  def flat_items
    days.map(&:items).flatten
  end

  private

  def defaults
    { 
      name: '',
      departure: false, 
      arrival: false
    }
  end

  def sites
    days.map(&:items).flatten.reject{ |i| i.travel_type || i.lodging }
  end
end