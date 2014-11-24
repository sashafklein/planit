class Item < ActiveRecord::Base

  include ActiveRecord::MetaExt
  
  belongs_to :mark
  belongs_to :plan
  belongs_to :day

  delegate :place, :name, to: :mark
  delegate :leg, to: :day
  validates_presence_of :mark, :plan

  scope :with_tabs, -> { all }
  scope :with_day_of_week, -> (dow) { where("day_of_week <> ?", day_of_weeks[dow.to_s]) }

  enum day_of_week: { monday: 1, tuesday: 2, wednesday: 3, thursday: 4, friday: 5, saturday: 6, sunday: 7 }

  before_save { self.start_time = MilitaryTime.new(self.start_time).convert if start_time_changed? }

  def self.marks
    Mark.where(id: pluck(:mark_id))
  end

  def self.places
    marks.places
  end

  def weekday
    day_of_week ? day_of_week.capitalize : nil
  end
end