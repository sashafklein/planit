class Item < BaseModel
  
  belongs_to :mark
  belongs_to :plan
  belongs_to :day

  delegate :leg, to: :day
  
  json_accessor :extra
  boolean_accessor :published

  has_many_polymorphic table: :notes

  class << self
    delegate :places, :coordinates, :all_names, :all_ids, :all_types, :all_countries, :all_regions, :all_localities, to: :marks
  end

  delegate    :names,
              :lat, :lon, 
              :street_addresses, :sublocality, :locality, :subregion, :region, :country, 
              :phone, :phones, :website,
              :meta_categories, :categories,

              :images, 

              :menu, :mobile_menu, 
              :reservations, :reservations_link, :hours, 

              :coordinate, :image,
              :name, :image_url, :image_source, :address, :locale, :href, :meta_icon,
              :savers, :lovers, :visitors, :guides,

              :name,
              :street_address,
              :meta_icon, :meta_category, 
                to: :mark

  validates_presence_of :mark, :plan

  scope :with_tabs, -> { all }
  scope :with_day_of_week, -> (dow) { where("day_of_week <> ?", day_of_weeks[dow.to_s]) }

  enum day_of_week: { monday: 1, tuesday: 2, wednesday: 3, thursday: 4, friday: 5, saturday: 6, sunday: 7 }

  before_save { self.start_time = Services::TimeConverter.new(self.start_time).absolute if start_time_changed? }

  # CLASS METHODS

  def self.marks
    Mark.where(id: pluck(:mark_id))
  end

  def self.with_places
    where( mark_id: Mark.with_places )
  end

  def self.without_places
    where( mark_id: Mark.without_places )
  end

  def self.with_lodging
    where(mark_id: Mark.where(id: pluck(:mark_id), lodging: true).pluck(:id))
  end
  
  # INSTANCE METHODS

  def has_place?
    Mark.find( mark_id ).has_place?
  end

  def next
    return nil if last_in_day?
    siblings.find_by_order( order + 1 )
  end

  def previous
    return nil if first_in_day?
    siblings.find_by_order( order - 1 ) || siblings.find_by_id( id - 1 )
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

  def lodging
    self.place.name unless !self.mark.lodging
  end

  private

  def siblings
    day.items
  end
end