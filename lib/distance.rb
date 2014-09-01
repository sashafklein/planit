class Distance

  RAD_PER_DEG             = 0.017453293
  RMILES  = 3956

  def self.day(day1, day2, rounding=1)
    return unless day1 && day2
    day1_item = day1.items.first
    day2_item = day2.items.last

    item(day1_item, day2_item, rounding)
  end

  def self.item(item1, item2, rounding=1)
    return false unless have_lat_lon(item1, item2)

    item_dist(item1, item2, rounding)
  end

  def self.haversine( lat1, lon1, lat2, lon2, rounding=1 )
    dlon = lon2 - lon1
    dlat = lat2 - lat1
   
    dlon_rad = dlon * RAD_PER_DEG
    dlat_rad = dlat * RAD_PER_DEG
   
    lat1_rad = lat1 * RAD_PER_DEG
    lon1_rad = lon1 * RAD_PER_DEG
   
    lat2_rad = lat2 * RAD_PER_DEG
    lon2_rad = lon2 * RAD_PER_DEG
   
    a = (Math.sin(dlat_rad/2))**2 + Math.cos(lat1_rad) *
         Math.cos(lat2_rad) * (Math.sin(dlon_rad/2))**2
    c = 2 * Math.atan2( Math.sqrt(a), Math.sqrt(1-a))
   
    (RMILES * c).round(rounding)
  end

  private

  def self.have_lat_lon(item1, item2)
    item1.lat && item1.lon && item2.lat && item2.lon
  end

  def self.item_dist(item1, item2, rounding=1)
    haversine( item1.lat, item1.lon, item2.lat, item2.lon, rounding )
  end

  def self.power(a,b)
    (a ** b)
  end
end