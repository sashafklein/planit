class Item < BaseModel

  after_create :resuscitate_mark!
  after_create :add_admin_2_to_plan!
  before_create :set_meta_category
  before_destroy :remove_admin_2_from_plan!

  belongs_to :mark
  belongs_to :plan
  
  json_accessor :extra
  boolean_accessor :published

  has_many_polymorphic table: :notes

  class << self
    delegate :places, to: :marks
  end

  delegate    :place, :names,
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

  def add_admin_2_to_plan!
    return unless plan && admin_2
    locs = plan.object_locations.where( location_id: admin_2.id )
    locs.first_or_create!
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

  def remove_admin_2_from_plan!
    return unless plan && admin_2

    locations_with_admin_2 = plan.places.locations.where( admin_id_2: admin_2.geoname_id )
    not_only_item_with_that_admin_2 = locations_with_admin_2.count > 1 || 
      plan.places.object_locations.where(location_id: locations_with_admin_2.pluck(:id)).count > 1

    plan.object_locations.where(location_id: admin_2.id).destroy_all unless not_only_item_with_that_admin_2
  end

  def admin_2
    return nil unless mark.place
    Location.find_by( geoname_id: mark.place.locations.pluck(:admin_id_2) )
  end
end