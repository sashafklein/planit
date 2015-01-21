class PlaceHours

  DAYS = [:mon, :tue, :wed, :thu, :fri, :sat, :sun]

  attr_accessor :hours, :bands
  def initialize(hour_set, timezone)
    @timezone, @hours = timezone, SuperHash.new
    SuperHash.new(hour_set).each { |day, _| @hours[day] = digest_hour_bands_for_day(hour_set, day) }
    @hours.reject!{ |k, v| v.blank? }
    @bands = get_bands
  end

  def open_until
    return nil unless open?
    
    closing_time, day = current_band.last, day_of_week
    
    if closing_time >= 24 
      day = day_of_week(1)
      closing_time -= 24
    end

    { day: day.to_s, time: from_float( closing_time ) }
  end

  def open_again_at
    return nil if open?
    band_and_day = { band: bands[day_of_week].reject{ |b| b.first < float_time }.first, day: day_of_week }
    
    unless band_and_day && band_and_day[:band]
      (1..6).each do |i|
        if band = bands[ day_of_week(i) ].first
          break if band_and_day = { band: band, day: day_of_week(i) }
        end
      end
    end

    return nil unless band_and_day.values.all?(&:present?)

    { day: band_and_day[:day], time: from_float( band_and_day[:band].first ) }
  end

  def open?
    current_band ? true : false
  end

  def current_time
    DateTime.current.in_time_zone(@timezone)
  end

  private

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

  def string_time
    current_time.strftime("%H%M")
  end

  def float_time
    num string_time
  end

  def from_float(float)
    first, last = float.to_s.split('.')
    "#{ first.rjust(2, '0') }#{ last.ljust(2, '0') }"
  end

  def overlap_hours(hour_set)
    return nil unless overlap = hour_set.reject{ |a| a.empty? }.find{ |hs| num(hs.last) > 24 }
    ['0000', from_float( num(overlap[1]) - 24 ) ]
  end

  def num(time_string)
    (time_string[0..1].to_f + (time_string[2..-1].to_f / 100)).round(2)
  end

  def current_band
    bands[day_of_week].to_a.find{ |b| b.last > float_time && b.first <= float_time }
  end

  def digest_hour_bands_for_day(hour_bands, today)
    hb = SuperHash.new(hour_bands.reduce_to_hash do |k, v| 
      v.map do |a| 
        num(a.last) <= num(a.first) ? [a.first, from_float(num(a.last) + 24)] : a
      end
    end)
    yesterday_hours = hb[ previous(today) ]
    yesterday_overlap = yesterday_hours.present? ? overlap_hours( yesterday_hours ) : nil
    full_hours = (hb[today] + [ yesterday_overlap ] ).compact
  end

  def get_bands
    bands = SuperHash.new( DAYS.reduce({}){ |hash, day| hash[day] = []; hash } )
    hours.each do |day, day_hours|
      day_hours.each do |array|
        bands[day] << (num(array.first)..num(array.last))
      end
      bands[day].sort!{ |a, b| a.first <=> b.first }
    end
    bands
  end

  def previous(day)
    DAYS[ DAYS.index(day.to_sym) - 1 ]
  end

  def next_day(day)
    DAYS[ DAYS.index(day.to_sym) + 1 ]
  end
end