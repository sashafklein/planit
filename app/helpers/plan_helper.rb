module PlanHelper
  def zebra_class(index, bucket=false)
    return '' if bucket
    if index.odd?
      'odd'
    else
      'even'
    end
  end

  def cluster_name(leg, bucket=false)
    if bucket
      "Trip-wide Bucket List"
    else
      name = "Day #{leg.first_day} to #{leg.last_day}"
      name += ":" unless leg.only_leg
    end
  end

  def timeline_cluster_class(bucket, index)
    if bucket
      'timeline-bucketlist'
    else
      "timeline-cluster no#{index+1}"
    end
  end

  def map_icon
    image_path('pin_sm_red_19x22.png')
  end

  def display_date(data, item)
    data.start_date + item.parent_day.days
  end

  def category(lodging_item)
    cat = lodging_item.category || 'hotel'
    cat.downcase
  end

  def print_lodging(lodging_item, index)
    string = ''
    string += "<b>#{lodging_item.name.titleize}</b>"
    string += " (Day #{lodging_item.parent_day})"
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

  def travel_info(info, index)
    content_tag :div, class: 'content-tab-wrap' do 
      content_tag :div, class: 'content-tab-print time' do
        image_tag "travel-by-#{info['method']}.png"
      end
      content_tag :div, class: 'content-tab-print travel' do
        print_travel(info, index)
      end
    end
  end

  def distance(day_index, item_index, item, day)
    if day_index != 0 # Not first day
      if item_index == 0
        dist = Distance.item(item, day.previous(day_index).items.last, 1)
      else
        dist = Distance.item(item, item.previous(item_index), 1)
      end
    elsif item_index != 0 # Not first item
      dist = Distance.item(item, item.previous(item_index), 1)
    end
    dist ? "(#{dist} miles)" : ''
  end

  def timeline_cluster_image(day)
    input = day.time_of_day ? "_#{day.time_of_day}" : '-cluster-pin'
    "timeline#{input}.png"
  end

  # Below methods can't be called outside this file
  private 
  
  def lodging_location(info)
    if info.street_address && info.city && info.state
      ", #{info.street_address}, #{info.city}, #{info.state}"
    elsif info.street_address && info.city
      ", #{info.street_address}, #{info.city}"
    elsif info.street_address && info.state
      ", #{info.street_address}, #{info.state}"
    elsif info.address
      ", #{info.address}"
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
