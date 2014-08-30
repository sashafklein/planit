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

  def overview_coordinates(data)
    legs(data).map{ |leg| leg_coordinates(leg) }.join("+")
  end

  def leg_start(leg)
    days(leg).first['items'].first
  end

  def leg_end(leg)
    days(leg).last['items'].last
  end

  def leg_coordinates(leg)
    days(leg).map{ |d| day_coordinates(d) }.join("+")
  end

  def day_coordinates(day)
    day['items'].compact
      .map{ |i| coordinate(i) }
      .join("+")
  end

  def days(leg)
    leg['days'].compact
  end

  def coordinate(item)
    "#{item['lat']}:#{item['lon']}"
  end

  def legs(data)
    data.legs.compact
  end

  def display_date(data, item)
    data.start_date + item['parent_day'].days
  end

  def print_flight(travel_info, index)
    if travel_info['departure_date']
      "#{travel_info['departure_date'].strftime('%b %d, %Y')}: "
    else
      "#{index}: "
    end
    if travel_info['departure_time']
      "#{travel_info['departure_time']}"
    end
    "#{travel_info['type']} #{travel_info['vessel']} from #{travel_info['from']} to #{travel_info['to']}"
    if travel_info['departure_terminal']
      " (T#{travel_info['departure_terminal']})"
    end
    if travel_info['arrival_terminal']
      " (T#{travel_info['arrival_terminal']})"
    end
    if travel_info['confirmation'] 
      "| Confirmation code #{travel_info['confirmation']}"
    end
  end

end
