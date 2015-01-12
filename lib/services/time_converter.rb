module Services
  class TimeConverter

    attr_accessor :input
    def initialize(input)
      @input = input.to_s
    end

    def self.convert_hours(hours)
      full_hours = SuperHash.new split_into_days(hours.recursive_symbolize_keys)

      %w(mon tue wed thu fri sat sun).map(&:to_sym).reduce({}) do |new_hours, day|
        if full_hours[day]
          new_hours[day.to_s] = []

          if full_hours[day].is_a?(Hash) || full_hours[day].first.is_a?(Hash)
            [full_hours[day]].flatten.each do |hour_band|
              new_hours[day.to_s] << [
                self.new( hour_band.start_time ).absolute,
                self.new( hour_band.end_time ).absolute 
              ]
            end
          else # Array format
            full_hours[day].each do |hour_band|
              new_hours[day.to_s] << hour_band.map{ |t| self.new(t).absolute }
            end
          end
        end
        
        new_hours
      end
    end

    def self.hours_converted?(hours)
      formatted = hours.all? do |day, hb|
        %w(mon tue wed thu fri sat sun).include?(day) && hb &&
          (hb.all?{ |band| band.last == '0000' || (band.first != band.last) }) && 
          (hb.all?{ |band| band.all?{ |t| t == new(t).absolute } })
      end
      formatted && hours.keys.all?{ |day| %w(mon tue wed thu fri sat sun).include? day }
    end

    def self.from_float(float)
      self.new(float.to_s.gsub('.', ':'))
    end

    def self.numericize(string)
      self.new(string).numericize
    end

    def absolute
      @absolute ||= input == depunctuate(input) ? from_flat_input : Time.parse(input).strftime("%H%M")
    end

    def am_pm
      @am_pm ||= time.strftime("%-l:%M %P")
    end

    def numericize
      time.strftime("%-k").to_f + (time.strftime("%M").to_f / 60.0)
    end

    private

    def time
      @time ||= Time.parse( add_colon(absolute) )
    end

    def from_flat_input
      Time.parse( add_colon( pad(input) ) ).strftime("%H%M")
    end

    def add_colon(string)
      new_string = string.dup
      new_string.insert(2, ":")
    end

    def pad(string)
      (input.rjust(2, '0')).ljust(4, '0')
    end

    def depunctuate(string)
      string.chars.select{ |char| char =~ /[0-9]/ }.join("")
    end

    def self.split_into_days(hour_hash)
      return hour_hash unless hour_hash.any?{ |k, v| hyphens.any?{ |h| k.to_s.include?(h) } }
      order = %w(mon tue wed thu fri sat sun)

      new_hash = {}
      hour_hash.stringify_keys.each do |k, v|
        if hyphen = hyphens.find{ |h| k.include?(h) }
          first, last = k.split( hyphen )
          order[ order.index(first)..order.index(last) ].each do |day|
            new_hash[day.to_sym] = v
          end
        else
          new_hash[k.to_sym] = v
        end
      end
      new_hash
    end

    def self.hyphens
      ['-', String::LONG_DASH]
    end

  end
end