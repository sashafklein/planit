class Leg

  include PseudoModel

  attr_accessor :days, :plan

  def initialize(hash, plan)
    @plan = plan
    @days = Day.serialize( hash.delete('days').compact, self )
    set_as_instance_variables( hash, defaults )
    # , that_thing: 'default_value'
  end

  def leg_TOC(leg, index)
    
  end
  
  def self.serialize(leg_array, plan)
    leg_array.map do |leg|
      new(leg, plan)  
    end
  end

  def only_leg
    plan.legs.count == 1
  end

  def baseAZ(num)
    # temp variable for converting base
    temp = num

    # the base 26 (az) number
    az = ''

    while temp > 0

      # get the remainder and convert to a letter
      num26 = temp % 26
      temp /= 26

      # offset for lack of "0"
      temp -= 1 if num26 == 0

      az = (num26).to_s(26).tr('0-9a-p', 'ZA-Y') + az
    end

    return az
  end

  def caption(index)
    "<b>day #{first_day} - #{last_day}</b>: overview"
    # : leg \"#{baseAZ(index+1)}\"
    # if first_locale.city && last_locale.city && first_locale != last_locale
    #   "From #{first_locale.city} to #{last_locale.city}"
    # else
    #   "From #{first_locale.name} to #{last_locale.name}"      
    # end
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

  def arrival_data
    arrival ? arrival['travel_data'] : ''
  end

  def departure_data
    departure ? departure['travel_data'] : ''
  end

  def arrival_to
    arrival_data ? arrival_data.last['to'] : ''
  end

  def departure_from
    departure_data ? departure_data.first['from'] : ''
  end

  def arrival_method
    arrival ? arrival['method'] : ''
  end

  def departure_method
    departure ? departure['method'] : ''
  end

  def show_arrival
    if arrival_to
      "Arrive by #{arrival_method} to #{arrival_to}"
    else
      "Arrive by #{arrival_method}"
    end
  end

  def show_departure
    if departure_from
      "Departure by #{departure_method} from #{departure_from}"
    else
      "Departure by #{departure_method}"
    end
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