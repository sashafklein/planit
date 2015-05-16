class Item < BaseModel

  after_create :resuscitate_mark!
  before_create :set_meta_category

  belongs_to :mark
  belongs_to :plan
  belongs_to :day

  delegate :leg, to: :day
  
  json_accessor :extra
  boolean_accessor :published

  has_many_polymorphic table: :notes

  class << self
    delegate :places, to: :marks
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
              :meta_icon,
                to: :mark

  validates_presence_of :mark, :plan

  scope :with_tabs, -> { all }

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

  def copy!(new_plan:, keep: [:notes])
    Item.transaction do 
      new_mark = mark.copy!(new_user: new_plan.user)
      return unless new_mark
      new_item = dup_without_relations!( override: { mark_id: new_mark.id, plan_id: new_plan.id } )
      keep.each { |assc| copy_polymorphic!(to: new_item, relation: assc, other_attrs: { source: plan.user }) }
      new_item
    end
  end

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

  # INDIVIDUAL ITEM PASS THROUGH LINKAGES

  def lodging
    self.place.name unless !self.mark.lodging
  end

  private

  def siblings
    day.items
  end

  def resuscitate_mark!
    mark.update_attributes!(deleted: false) if mark.deleted
  end

  def set_meta_category
    self.meta_category = mark.place.meta_category if mark.try( :place ) && !self.meta_category
  end
end