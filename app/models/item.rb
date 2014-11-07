class Item < ActiveRecord::Base

  extend ActiveRecord::ClassInfo
  
  belongs_to :mark
  belongs_to :plan
  belongs_to :day

  enum day_of_week: { monday: 1, tuesday: 2, wednesday: 3, thursday: 4, friday: 5, saturday: 6, sunday: 7 }

  def weekday
    day_of_week ? day_of_week.capitalize : nil
  end
end