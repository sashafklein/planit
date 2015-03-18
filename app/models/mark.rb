class Mark < BaseModel
    
  before_save { category.downcase! if category_changed? }
  
  belongs_to :place
  belongs_to :user

  validate!

  has_many_polymorphic table: :sources
  has_many_polymorphic table: :flags, options: {}
  has_many :items, dependent: :destroy
  has_many :place_options, dependent: :destroy

  delegate :names, :name, :categories, :category, :coordinate, :url, :phones, :phone, :website,
           :country, :region, :locality, :sublocality, :images, :image, :street_address, to: :place

  delegate :full, :lodging, to: :place, prefix: true
  boolean_accessor :lodging, :meal, :published, :been, :loved, :deleted

  has_one :arrival, class_name: 'Travel', foreign_key: 'to_id'
  has_one :departure, class_name: 'Travel', foreign_key: 'from_id'

  scope :with_tabs,     ->        { where(show_tab: true) }
  scope :with_lodging,  ->        { where(lodging: true) }
  scope :sites,         ->        { where(lodging: false, meal: false) }
  scope :with_mark,     -> (mark) { where(mark: mark) }
  scope :marked_up,     ->        { with_mark('up') }
  scope :marked_down,   ->        { with_mark('up') }
  scope :starred,       ->        { with_mark('star') }
  scope :sourced_with,  -> (source_name) { where(id: Source.where(name: source_name, object_type: 'Mark').pluck(:object_id)) }

  make_taggable

  def self.places
    Place.where( id: pluck(:place_id) )
  end

  def self.with_places
    where.not( place_id: nil )
  end

  def self.without_places
    where( place_id: nil )
  end

  def save_with_source!(source_url:)
    save!
    create_source!(source_url: source_url) if source_url.present?
  end

  def source
    sources.first
  end

  def create_source!(source_url:)
    parser = SourceParser.new(source_url)
    base_sources = Source.where(name: parser.name, base_url: parser.base)

    matching_sources = base_sources.where(object: self, trimmed_url: parser.trimmed)
    
    matching_sources.create!(full_url: parser.full) unless matching_sources.any?
  end

  class << self
    # delegate :coordinates, to: :places
  end

  def self.create_for_user_from_source!(user, source, url)
    mark = source.object
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

  def self.coordinates
    with_places.places.map(&:coordinate)
  end

  def self.center_coordinate
    Place.center_coordinate(places)
  end

  def self.all_names
    places.map(&:name)
  end

  def self.all_ids
    places.pluck(:id)
  end

  def self.all_countries
    places.att_by_frequency(:country)
  end

  def self.all_regions
    places.att_by_frequency(:region)
  end

  def self.all_localities
    places.att_by_frequency(:locality)
  end
  
  def self.all_tags
    taggings = Tagging.where(taggable_type: 'Mark', taggable_id: self.pluck(:id))
    Tag.where(id: taggings.pluck(:tag_id) ).pluck(:name)
  end

  def self.filtered(array)
    []
    # MarkFilterer.new(array).results
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

  def recoby
    nil #todo -- make a column or two
  end

  def downby
    nil #todo -- make a column or two
  end

  def rating
    nil #todo -- make a column or two
  end

  def show_arrival
    "Arrive by #{arrival.mode} to #{name}"
  end

  def show_departure
    "Depart by #{departure.mode} to #{name}"
  end

  private

  def siblings
    Item.where(day_id: day_id)
  end
end
