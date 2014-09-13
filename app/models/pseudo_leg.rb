class PseudoLeg

  include PseudoModel

  attr_accessor :days, :plan

  def initialize(hash, plan)
    @plan = plan
    @days = PseudoDay.serialize( hash.delete('days').compact, self )
    set_as_instance_variables( hash, defaults )
    # , that_thing: 'default_value'
  end

  def leg_TOC(leg, index)
  end
  
  def center_city
    # API query performed (when? perhaps whenever lge info in the database is changed?) to find the City for this lat.lon pair
  end

  def day_nights
    # count days in a leg, unless another leg holds them w/ housing <= e.g. morning in X but night in Y counts toward Y
    # return array of days in that leg?
  end

  def combined_day_nights
    # return array of days in the legs which share lat/lon
    # e.g. 1, 3, 4, 5, 6, 7, 8
    # print in view as adjacent numbers abbreviated and joined w/ dash + separated by comma e.g. "1, 3-8"
    # sorted in view by .length -- e.g. 7 days in Tokyo <= combined_day_nights.length center_city
  end

  def combined_with
    # return which other legs to combine w/ this one (how?)
  end

  def is_repeat?
    # simple function to say to the map not to reprint the leg?
    #   if distance_to_this_leg < 50
    # What is the logic?  Similar center coordinate measured by distance radius?  With what permitted variability?
  end
  
  def self.serialize(leg_array, plan)
    leg_array.map do |leg|
      new(leg, plan)  
    end
  end

  def only_leg
    plan.legs.count == 1
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

  def center_coordinate
    [lat_avg, lon_avg].join(":")
  end

  def lat_avg
    arr = days.map(&:lat_avg)
    arr.inject{ |sum, el| sum + el }.to_f / arr.size
  end
  
  def lon_avg
    arr = days.map(&:lon_avg)
    arr.inject{ |sum, el| sum + el }.to_f / arr.size
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