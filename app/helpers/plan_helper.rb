module PlanHelper

  def link_to_print(item, plan)
    subtitle = ''
    subtitle += ", #{item.category.titleize}" unless item.category.blank?
    subtitle += " in #{item.location_full}"
    
    name = content_tag :b do item.name.titleize end
    all = content_tag :p  do name + subtitle    end

    link_to all.html_safe, print_plan_path(plan)
  end

  def info_tab(item, options={})
    raise unless options[:test_attr]
    defaults = { bold_attr: options[:test_attr], show_attr: options[:test_attr], bold: nil, div: 'content-tab-more-info', show_bold: true }
    opts = options.merge(defaults)
    if item.send opts[:test_attr]
      content_tag :div, class: opts[:div] do
        content_tag :b do opts[:bold] || item.send(opts[:bold_attr]) end if opts[:show_bold]
        item.send(opts[:show_attr])
      end
    end
  end

  def zebra_class(index, bucket=false)
    return '' if bucket
    if index
      if index.odd?
        'odd'
      else
        'even'
      end
    end
  end
# This above one was a problem with a single leg & bucket list (Paris Ideas) so I added if index ->

  def day_map_size(items_with_tabs) 
    if items_with_tabs <= 2
      "small-size"
    elsif items_with_tabs <= 4
      "mid-size"
    else
      "full-size"
    end
  end

  def cluster_name(leg, bucket=false)
    if bucket
      "Trip-wide Bucket List"
    else
      name = "Day #{leg.first_day} to #{leg.last_day}"
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
    if lodging_item.category != ''
      cat = lodging_item.category || 'hotel'
      cat.downcase
    else
      cat = 'hotel'
    end
  end

  def print_lodging(item, index)
    string = ''
    string += "<b>#{item.name.titleize}</b>"
    string += " (Day #{item.day.place_in_trip})"
    string += ", #{item.location_lodging}"
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

  def print_distance(day_index, item_index, item, day)
    if day_index != 0 # Not first day
      if item_index == 0
        dist = Distance.item(item, day.previous.items.last, 1)
      else
        dist = Distance.item(item, item.previous, 1)
      end
    elsif item_index != 0 # Not first item
      dist = Distance.item(item, item.previous, 1)
    end
    dist ? "(#{dist} miles)" : ''
  end

  def timeline_cluster_image(day)
    input = '-cluster-pin' # day.time_of_day ? "_#{day.time_of_day}" : '-cluster-pin'
    "timeline#{input}.png"
  end

  # Below methods can't be called outside this file
  private 

  def travel_departure_date(info, index)
    if info['departure_date']
      "<b>#{info['departure_date'].strftime('%b %d, %Y')}:</b> "
    else
      "#{index.to_i + 1}: "
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

  def get_lodging_list(item_list)
    lodging_list = []
    item_list.each do |item|
      if item.mark.lodging
        lodging_list << item.place.name
      end
    end
    return lodging_list
    # .each_with_object(Hash.new(0)){ |m,h| h[m] += 1 }.sort {|a,b| b[1] <=> a[1]}
  end

  def get_locale_list(item_list)
    locality_list = item_list.places.pluck(:locality)
    return locality_list.compact.uniq unless locality_list.compact.uniq.count < 2
    sublocality_list = item_list.places.pluck(:sublocality)
    return sublocality_list.compact.uniq
  end

end

# def defaults
#   { 
#     name: '',
#     departure_date: false, 
#     departure_time: false, 
#     departure: false, 
#     arrival_date: false,
#     arrival_time: false,
#     arrival: false
#   }
# end