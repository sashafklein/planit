module ItineraryHelper
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

end
