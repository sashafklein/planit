class PlaceHours

  DAYS = [:mon, :tue, :wed, :thu, :fri, :sat, :sun]

  attr_accessor :hours, :bands
  def initialize(hour_set, timezone)
    @timezone, @hours = timezone, SuperHash.new
    SuperHash.new(hour_set).each { |day, _| @hours[day] = digest_hour_bands_for_day(hour_set, day) }
    @hours.reject!{ |h| h.nil? || h.first.nil? }
    @bands = get_bands
  end

  def open_until
    return nil unless open?
    
    closing_time = current_band.last
    day = closing_time >= 24 ? day_of_week(1) : day_of_week
    closing_time -= 24 if closing_time >= 24

    {
      time: from_float( closing_time ).absolute,
      day: day
    }
  end

  def open_again_at
    return nil if open?

    band_and_day = { band: bands[day_of_week].reject{ |b| b.first < float_time }.first, day: day_of_week }
    
    band_and_day ||= 1..6.find do |incrementer|
      if band = bands[ day_of_week(incrementer) ].first
        { band: band, day: day_of_week(incrementer) }
      end
    end
    
    {
      time: from_float( band_and_day[:band].first ).absolute,
      day: band_and_day[:day]
    }
  end

  def open?
    current_band ? true : false
  end

  # private

  def opens(day=day_of_week)
    return nil unless hours(day).present?
    
    upcoming_band = hours(day).select{ |set| num(set.first) > float_time }.sort{ |a, b| a.first <=> b.first }.first
    upcoming_band ? upcoming_band.first : nil
  end

  def closes(day=day_of_week)
    return nil unless hours(day)
    
    upcoming_band = hours(day).select{ |set| num(set.first) > float_time }.sort{ |a, b| a.first <=> b.first }.last
    upcoming_band ? upcoming_band.last : nil
  end

  def day_of_week(after_today=0)
    (current_time + after_today.days).strftime("%a").downcase
  end

  def current_time
    DateTime.current.in_time_zone(@timezone)
  end

  def string_time
    current_time.strftime("%H%M")
  end

  def float_time
    num string_time
  end

  def from_float(float)
    Services::TimeConverter.from_float( float >= 24 ? float - 24 : float )
  end

  def overlap_hours(hour_set)
    return nil unless overlap = hour_set.find{ |hs| num(hs.first) > num(hs.last) && hs.last != '0000' }

    overlap = overlap.dup 
    overlap[0] = '0000'
    overlap
  end

  def num(time_string)
    time_string[0..1].to_f + (time_string[2..-1].to_f / 60.0).round(2)
  end

  def current_band
    bands[day_of_week].to_a.find{ |b| b.include?(float_time) }
  end

  def digest_hour_bands_for_day(hour_bands, today)
    yesterday_hours = [ hour_bands[ previous(today) ] ].flatten.compact.map(&:values)
    array_of_hashes = ([ hour_bands[today] ].flatten.map(&:values) + [ overlap_hours(yesterday_hours) ]).compact
    array_of_hashes.map do |a| 
      a.last == '0000' ? [a.first, '2400'] : a
    end
  end

  def get_bands
    bands = SuperHash.new( DAYS.reduce({}){ |hash, day| hash[day] = []; hash } )
    hours.each do |day, day_hours|
      day_hours.each do |array|
        start_time, end_time = num(array.first), num(array.last)
        end_time += 24 if end_time <= start_time
        bands[day] << (start_time..end_time) 
      end
      bands[day].sort!{ |a, b| a.first <=> b.first }
    end
    bands.reject{ |k,v| v.empty? }
  end

  def previous(day)
    DAYS[ DAYS.index(day.to_sym) - 1 ]
  end
end