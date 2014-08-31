module PlanHelper
  def in_next_cluster?(current_cluster, item)
    current_cluster < item['parent_cluster']
  end

  def traveling?(item)
    item['travel_type'].present?
  end

  def in_next_day?(item, prior_day)
    item['parent_day'] > prior_day
  end

  def zebra_class(index)
    if index.odd?
      'odd'
    else
      'even'
    end
  end

  def display_date(data, item)
    data.start_date + item['parent_day'].days
  end

  def has_lodging(day)
    day['items'].any?{ |i| i['lodging']}
    # flawed model, finds "no lodging" for travel days, end of trip
  end

  def print_lodging(lodging_item, index)
    string = ''
    string += "<b>#{lodging_item['name'].titleize}</b>"
    string += " (Day #{lodging_item['parent_day']})"
    string += lodging_location(lodging_item)
    # string += travel_departure_time(travel_info) || ''
    # string += "#{travel_info['type']} #{travel_info['vessel']} from <b>#{travel_info['from']}</b>"
    # string += departure_terminal(travel_info) || ''
    # string += " to <b>#{travel_info['to']}</b>"
    # string += arrival_terminal(travel_info) || ''
    # string += confirmation_info(travel_info) || ''
    string.html_safe
  end

  def print_travel(travel_info, index)
    string = ''
    string += travel_departure_date(travel_info, index)
    string += travel_departure_time(travel_info) || ''
    string += travel_vessel(travel_info) || ''
    string += travel_from(travel_info) || ''
    string += departure_terminal(travel_info) || ''
    string += travel_to(travel_info) || ''
    string += arrival_terminal(travel_info) || ''
    string += arrival_time(travel_info) || ''
    string += confirmation_info(travel_info) || ''
    string.html_safe
  end

  def power(a,b)
    (a ** b)
  end

  def distance_calc(lat1, long1, lat2, long2, rounding)

    dtor = Math::PI/180
    r = 3959
    # r = 6378.14*1000
    # This will calculate in meters. To get KM, remove "*1000" on line 3. To get miles, change line 3 to "r = 3959". I'll post the whole GPX parse code in a few days.
   
    rlat1 = lat1 * dtor 
    rlong1 = long1 * dtor 
    rlat2 = lat2 * dtor 
    rlong2 = long2 * dtor 
   
    dlon = rlong1 - rlong2
    dlat = rlat1 - rlat2
   
    a = power(Math::sin(dlat/2), 2) + Math::cos(rlat1) * Math::cos(rlat2) * power(Math::sin(dlon/2), 2)
    c = 2 * Math::atan2(Math::sqrt(a), Math::sqrt(1-a))
    d = r * c

    return d.round(rounding)

  end


  # Below methods can't be called outside this file
  private 
  
  def lodging_location(info)
    if info['street_address'] && info['city'] && info['state']
      ", #{info['street_address']}, #{info['city']}, #{info['state']}"
    elsif info['street_address'] && info['city']
      ", #{info['street_address']}, #{info['city']}"
    elsif info['street_address'] && info['state']
      ", #{info['street_address']}, #{info['state']}"
    elsif info['address']
      ", #{info['address']}"
    else
      ""
    end
  end

  def travel_departure_date(info, index)
    if info['departure_date']
      "<b>#{info['departure_date'].strftime('%b %d, %Y')}:</b> "
    else
      "#{index + 1}: "
    end
  end

  def arrival_time(info)
    if info['arrival_date'] == info['departure_date']
      ", arriving at #{info['arrival_time']}"
    elsif info['arrival_date'] == (info['departure_date'] + 1)
      ", arriving <b>next day</b> at #{info['arrival_time']}"
    elsif info['arrival_date'] 
      ", arriving on <b>#{info['arrival_date'].strftime('%b %d, %Y')}</b> at #{info['arrival_time']}"      
    else
      ", arriving at #{info['arrival_time']}"
    end
  end

  def travel_to(info)
    " to <b>#{info['to']}</b>" if info['to']
  end

  def travel_from(info)
    " from <b>#{info['from']}</b>" if info['from']
  end

  def travel_vessel(info)
    " #{info['method']} #{info['vessel']}" if info['vessel']
  end

  def travel_departure_time(info)
    "#{info['departure_time']}" if info['departure_time']
  end

  def departure_terminal(info)
    " (T#{info['departure_terminal']})" if info['departure_terminal']
  end

  def arrival_terminal(info)
    " (T#{info['arrival_terminal']})" if info['arrival_terminal']
  end

  def confirmation_info(info)
    "| Confirmation code #{info['confirmation']}" if info['confirmation']
  end
end
