class MilitaryTime

  attr_accessor :time_string
  def initialize(time_string)
    @time_string = time_string
  end

  def convert
    new_time_string = time_string.dup
    cleaned = new_time_string.gsub('.', '').downcase

    if cleaned.include?('am') && base_time = cleaned.split('am')[0].strip
      new_time_string = [base_time.split(':')[0], base_time.split(':')[1] || '00'].join(":")
    elsif cleaned.include?('pm') && base_time = cleaned.split('pm')[0].strip
      new_time_string = [(base_time.split(':')[0].to_i + 12).to_s, base_time.split(':')[1] || '00'].join(":")
    end

    array = new_time_string.split(":")
    "#{ array.first.rjust(2,'0') }:#{ array.last.ljust(2,'0') }"
  end
end