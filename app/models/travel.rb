class Travel < ActiveRecord::Base
  belongs_to :from, class_name: 'Item'
  belongs_to :to, class_name: 'Item'
  has_one :next_step, class_name: 'Travel'

  def previous_step
    Travel.find_by_next_step_id(id)
  end

  def terminus
    next_step_id ? next_step.terminus : to
  end

  def origin
    previous_step ? previous_step.origin : from
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
end
