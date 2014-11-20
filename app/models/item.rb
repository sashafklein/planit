class Item < ActiveRecord::Base

  include ActiveRecord::MetaExt
  
  belongs_to :mark
  belongs_to :plan
  belongs_to :day

  delegate :place, to: :mark
  delegate :leg, to: :day
  validates_presence_of :mark, :plan

  enum day_of_week: { monday: 1, tuesday: 2, wednesday: 3, thursday: 4, friday: 5, saturday: 6, sunday: 7 }

  before_save { format_start_time if start_time_changed? }

  def self.marks
    Mark.where(id: pluck(:mark_id))
  end

  def self.places
    marks.places
  end

  def weekday
    day_of_week ? day_of_week.capitalize : nil
  end

  private

  def format_start_time
    cleaned = self.start_time.gsub('.', '').downcase

    if cleaned.include?('am') && base_time = cleaned.split('am')[0].strip
      self.start_time = [base_time.split(':')[0], base_time.split(':')[1] || '00'].join(":")
    elsif cleaned.include?('pm') && base_time = cleaned.split('pm')[0].strip
      self.start_time = [(base_time.split(':')[0].to_i + 12).to_s, base_time.split(':')[1] || '00'].join(":")
    end

    array = self.start_time.split(":")
    self.start_time = "#{ array.first.rjust(2,'0') }:#{ array.last.ljust(2,'0') }"
  end
end