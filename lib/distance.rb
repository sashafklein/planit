class Distance
  def self.day(day1, day2, rounding=2)
    return unless day1 && day2
    day1_item = day1.items.first
    day2_item = day2.items.last

    item(day1_item, day2_item, rounding)
  end

  def self.item(item1, item2, rounding=2)
    return false unless have_lat_lon(item1, item2)

    item_dist(item1, item2, rounding)
  end

  private

  def self.have_lat_lon(item1, item2)
    item1.lat && item1.lon && item2.lat && item2.lon
  end

  def self.item_dist(item1, item2, rounding)
    dtor = Math::PI/180
    r = 3959
    # r = 6378.14*1000
    # This will calculate in meters. To get KM, remove "*1000" on line 3. To get miles, change line 3 to "r = 3959". I'll post the whole GPX parse code in a few days.
   
    rlat1 = item1.lat * dtor 
    rlon1 = item1.lon * dtor 
    rlat2 = item2.lat * dtor 
    rlon2 = item2.lon * dtor 
   
    dlon = rlon1 - rlon2
    dlat = rlat1 - rlat2
   
    a = power(Math::sin(dlat/2), 2) + Math::cos(rlat1) * Math::cos(rlat2) * power(Math::sin(dlon/2), 2)
    c = 2 * Math::atan2(Math::sqrt(a), Math::sqrt(1-a))
    (r * c).round(rounding)
  end

  def self.power(a,b)
    (a ** b)
  end
end