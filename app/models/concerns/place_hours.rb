class PlaceHours

  attr_accessor :place
  def initialize(place)
    @place = place
  end

  def open_until
    return nil unless open?

    place.hours[ current_time.strftime("%a").downcase ]['end_time']
  end

  def open_again_at
    return nil if open? || open?.nil?

    if opens.to_i > flat_time_there.to_i
      opens
    elsif opens(tomorrow_day_of_week_there)
      opens(tomorrow_day_of_week_there)
    end
  end

  def open?
    return nil unless opens && closes

    if closes.to_i > opens.to_i
      flat_time_there.to_i > opens.to_i && flat_time_there.to_i < closes.to_i 
    else
      flat_time_there.to_i > opens.to_i && flat_time_there.to_i > closes.to_i
    end
  end

  private

  def opens(day=day_of_week_there)
    place.hours[day] ? place.hours[day]['start_time'] : nil
  end

  def closes(day=day_of_week_there)
    place.hours[day] ? place.hours[day]['end_time'] : nil
  end

  def day_of_week_there
    current_time.strftime("%a").downcase
  end

  def tomorrow_day_of_week_there
    (current_time + 1.day).strftime("%a").downcase
  end

  def current_time
    DateTime.current.in_time_zone(place.timezone.zone)
  end

  def flat_time_there
    current_time.strftime("%H%M")
  end
end