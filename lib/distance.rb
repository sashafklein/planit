class Distance

  RAD_PER_DEG             = 0.017453293
  RMILES                  = 3956

  def self.day(day1, day2, rounding=1)
    return unless day1 && day2
    day1_item = day1.items.first.place
    day2_item = day2.items.last.place

    item(day1_item, day2_item, rounding)
  end

  def self.between_objects( obj1, obj2, rounding=1 )
    self.haversine( obj1.lat, obj1.lon, obj2.lat, obj2.lon, rounding )    
  end

  private

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

  def self.have_lat_lon(item1, item2)
    item1.lat && item1.lon && item2.lat && item2.lon
  end

  def self.item_dist(item1, item2, rounding=1)
    haversine( item1.lat, item1.lon, item2.lat, item2.lon, rounding )
  end

  def self.items_dist(item_array, rounding=1)
    distance = 0.0
    start_lat, start_lon = 0.0, 0.0
    item_array.each_with_index do |e, i|
      if i == 0
        start_lat = e.lat 
        start_lon = e.lon
        next
      end
      distance += haversine( start_lat, start_lon, e.lat, e.lon, 10 )
    end
    return distance.round(rounding)
  end

  def self.power(a,b)
    (a ** b)
  end
end