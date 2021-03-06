class Mark < BaseModel
    
  before_save :remove_items_if_deleted!
  before_save { category.downcase! if category_changed? }
  
  belongs_to :place
  belongs_to :user

  validate!

  has_many_polymorphic table: :sources
  has_many_polymorphic table: :flags, options: {}
  has_many_polymorphic table: :notes

  has_many :items, dependent: :destroy
  has_many :place_options, dependent: :destroy

  has_one :arrival, class_name: 'Travel', foreign_key: 'to_id'
  has_one :departure, class_name: 'Travel', foreign_key: 'from_id'

  boolean_accessor :lodging, :meal, :published, :been, :loved, :deleted

  scope :with_tabs,     ->        { where(show_tab: true) }
  scope :with_lodging,  ->        { where(lodging: true) }
  scope :sites,         ->        { where(lodging: false, meal: false) }
  scope :with_mark,     -> (mark) { where(mark: mark) }
  scope :marked_up,     ->        { with_mark('up') }
  scope :marked_down,   ->        { with_mark('up') }
  scope :starred,       ->        { with_mark('star') }
  scope :sourced_with,  -> (source_name) { where(id: Source.where(name: source_name, obj_type: 'Mark').pluck(:obj_id)) }
  default_scope { not_deleted }

  delegate    :names,
              :lat, :lon, 
              :street_addresses, :sublocality, :locality, :subregion, :region, :country, 
              :phone, :phones, :website,
              :meta_categories, :categories,

              :images, 

              :menu, :mobile_menu, 
              :reservations, :reservations_link, :hours, 

              :coordinate, :image,
              :name, :image_url, :image_source, :address, :locale, :meta_icon,
              :savers, :lovers, :visitors, :guides,

              :name,
              :street_address,
              :meta_icon, :meta_category, 
                to: :place

  def self.places
    Place.where( id: pluck(:place_id) )
  end

  def self.with_places
    where.not( place_id: nil )
  end

  def self.without_places
    where( place_id: nil )
  end

  def self.savers( place_id )
    where( place_id: place_id ).pluck(:user_id)    
  end

  def self.lovers( place_id )
    loved.where( place_id: place_id ).pluck(:user_id)    
  end

  def self.visitors( place_id )
    been.where( place_id: place_id ).pluck(:user_id)    
  end

  def self.guides( place_id )
    Item.where( mark_id: self.where( place_id: place_id ).pluck(:id) ).pluck( :plan_id )
  end

  def self.with_original_query( attrs )
    results = select do |m|
      m.query.names == attrs.names && 
      m.query.nearby == attrs.nearby && 
      m.query.lat == attrs.lat && 
      m.query.lon == attrs.lon 
    end
    results.first
  end

  # INSTANCE METHODS

  def copy!(new_user:, keep: [:sources, :notes])
    Mark.transaction do 
      if mark = Mark.find_by(user_id: new_user.id, place_id: place_id)
        return mark
      end
      new_mark = dup_without_relations!(keep: [:place_id], override: { user_id: new_user.id } )
      keep.each do |assc| 
        others = assc == :notes ? { source: user } : {}
        copy_polymorphic!(to: new_mark, relation: assc, other_attrs: others)
      end
      new_mark
    end
  end

  def save_with_source!(source_url:)
    to_save = Mark.unscoped.find_by(user_id: user_id, place_id: place_id) || self
    to_save.save! unless to_save.persisted?
    to_save.create_source!(source_url: source_url) if source_url.present?
    to_save
  end

  def source
    sources.first
  end

  def create_source!(source_url:)
    parser = SourceParser.new(source_url)
    base_sources = Source.where(name: parser.name, base_url: parser.base)

    matching_sources = base_sources.where(obj: self, trimmed_url: parser.trimmed)
    
    matching_sources.create!(full_url: parser.full) unless matching_sources.any?
  end

  def self.create_for_user_from_source!(user, source, url)
    mark = source.obj
    return mark if mark.user == user

    if mark.place_id
      new_mark = user.marks.where(place_id: mark.place_id).first_or_initialize
      new_mark.save_with_source!(source_url: url)
    else
      new_mark = user.marks.new
      new_mark.save_with_source!(source_url: url)
      mark.place_options.each { |po| po.duplicate(mark_id: new_mark.id).save! }
    end
    new_mark
  end
  
  def self.average_updated
    array = map(&:updated_at).map(&:to_i)
    array.sum/array.count.to_f
  end

  # PLACE

  def href
    route_helper = Rails.application.routes.url_helpers
    if has_place? then route_helper.place_path(place) else route_helper.mark_path(mark) end
  end

  # INSTANCE METHODS

  def query
    @query ||= MarkMod::Query.new(self)
  end

  def has_place?
    place.present?
  end

  def show_icon
    @show_icon ||= Icon.new(category, lodging, meal, mark).filename
  end

  def mark?(test_mark)
    mark == test_mark
  end

  def previous
    siblings.find_by_order(order - 1)
  end

  # ADD NEW MARK

  def self.add_from_place_data!(user, data)
    return unless place = Place.find_or_initialize(data)
    place = place.validate_and_save!( data[:images] || [] ) unless place.persisted?
    place.background_complete!
    mark = Mark.unscoped.where(user: user, place_id: place.id).first_or_initialize
    mark.update_attributes!(deleted: false)
    mark.save!
    return mark
  end

  private

  def siblings
    Item.where(day_id: day_id)
  end

  def remove_items_if_deleted!
    items.destroy_all if deleted && deleted_changed?
  end
end
