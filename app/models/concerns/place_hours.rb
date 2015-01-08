class PlaceHours

  attr_accessor :place
  def initialize(place)
    @place = place
  end
  delegate :hours, to: :place

  def open_until
    return nil unless open?
    
    closing_time = current_band.last
    closing_time -= 24 if closing_time >= 24

    Services::TimeConverter.new( closing_time.to_s.gsub('.', ':') ).absolute
  end

  def open_again_at
    return nil if open?

    band = bands(day_of_week).reject{ |b| b.first < float_time }.first
    
    band ||= 1..6.find do |incrementer|
      bands( day_of_week(incrementer) ).first
    end
    
    Services::TimeConverter.new( band.first.to_s.gsub('.', ':') ).absolute
  end

  def open?
    current_band ? true : false
  end

  def full_hours(day=nil)
    if day
      full_hours_for_day(day)
    else
      hours.reduce_to_hash{ |key| full_hours_for_day(key) }
    end
  end

  private

  def full_hours_for_day(day)
    (hours[day.to_s].to_a + [ overlap_hours(yesterday_hours(day)) ]).compact
  end

  def opens(day=day_of_week)
    return nil unless full_hours(day)
    
    upcoming_band = full_hours(day).select{ |set| num(set['start_time']) > float_time }.sort{ |a, b| a['start_time'] <=> b['start_time'] }.first
    upcoming_band ? upcoming_band['start_time'] : nil
  end

  def closes(day=day_of_week)
    return nil unless full_hours(day)
    
    upcoming_band = full_hours(day).select{ |set| num(set['start_time']) > float_time }.sort{ |a, b| a['start_time'] <=> b['start_time'] }.last
    upcoming_band ? upcoming_band['end_time'] : nil
  end

  def day_of_week(extra_days=0)
    (current_time + extra_days.days).strftime("%a").downcase
  end


  def current_time
    DateTime.current.in_time_zone(place.timezone.zone)
  end

  def string_time
    current_time.strftime("%H%M")
  end

  def float_time
    num string_time
  end

  def days
    %w( mon tue wed thu fri sat sun )
  end

  def yesterday_hours(today)
    hours[ days[ days.index(today) - 1 ] ]
  end

  def overlap_hours(hour_set)
    return nil unless overlap = hour_set.find{ |hs| num(hs['start_time']) > num(hs['end_time']) && hs['end_time'] != '0000' }

    overlap = overlap.dup 
    overlap['start_time'] = '0000'
    overlap
  end

  def bands(day)
    ranges = full_hours(day).map do |hash|
      start_time, end_time = num(hash['start_time']), num(hash['end_time'])
      end_time += 24 if end_time < start_time
      (start_time..end_time)
    end

    ranges.sort { |a,b| a.first <=> b.first }
  end

  def num(time_string)
    Services::TimeConverter.numericize(time_string)
  end

  def current_band
    bands(day_of_week).find{ |b| b.include?(float_time) }
  end
end