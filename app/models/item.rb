class Item < ActiveRecord::Base

  include ActiveRecord::MetaExt
  
  belongs_to :mark
  belongs_to :plan
  belongs_to :day

  delegate :names, :categories, :category, :coordinate, :lat, :lon, :url, :phones, :phone, :website, :street_address, :country, :region, :locality, :sublocality, to: :place
  delegate :place, :notes, :name, to: :mark
  delegate :leg, to: :day
  validates_presence_of :mark, :plan

  scope :with_tabs, -> { all }
  scope :with_day_of_week, -> (dow) { where("day_of_week <> ?", day_of_weeks[dow.to_s]) }

  enum day_of_week: { monday: 1, tuesday: 2, wednesday: 3, thursday: 4, friday: 5, saturday: 6, sunday: 7 }

  before_save { self.start_time = MilitaryTime.new(self.start_time).convert if start_time_changed? }

  # CLASS METHODS

  def self.marks
    Mark.where(id: pluck(:mark_id))
  end

  def self.places
    marks.places
  end

  def self.with_lodging
    where(mark_id: Mark.where(id: pluck(:mark_id), lodging: true).pluck(:id))
  end

  def self.coordinates
    marks.coordinates
  end

  def self.allnames
    marks.allnames
  end

  def self.allids
    marks.allids
  end

  # INSTANCE METHODS

  def next
    return nil if last_in_day?
    siblings.find_by_order( order + 1 )
  end

  def previous
    return nil if first_in_day?
    siblings.find_by_order( order - 1 )
  end

  def first_in_day?
    order == 0
  end

  def last_in_day?
    order == order.length
  end

  def weekday
    day_of_week ? day_of_week.capitalize : nil
  end

  # INDIVIDUAL ITEM PASS THROUGH LINKAGES

  def image
    place.image
  end

  def source
    self.mark.source
  end

  def lodging
    self.place.name unless !self.mark.lodging
  end
  private

  def siblings
    day.items
  end
end