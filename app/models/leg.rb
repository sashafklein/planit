class Leg < ActiveRecord::Base

  belongs_to :plan
  has_many :days
  has_many :items, through: :days

  delegate :first_item, to: :first_day
  delegate :last_item, to: :last_day

  delegate :arrival, to: :first_item
  delegate :departure, to: :last_item

  default_scope { order('"order" ASC') }

  def items
    Item.where(day_id: days.pluck(:id))
  end

  def first_day
    days.first
  end

  def last_day
    days.last
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
  
  def only_leg
    siblings.count == 1
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
    last_day.day_in_trip
  end

  def first_day
    first_day.day_in_trip
  end

  def coordinates
    days.map(&:coordinates).join("+")
  end

  def center_coordinate
    items.center_coordinate
  end

  def start
    items.first
  end

  def first_locale
    raise "No non-travel and non-lodging sites for leg: #{leg.inspect}" unless sites.any?  
    sites.first 
  end

  def last_locale
    raise "No non-travel and non-lodging sites for leg: #{leg.inspect}" unless sites.any?
    sites.last
  end


  private


  def siblings
    plan.legs
  end

  def sites
    items.sites
  end
end
