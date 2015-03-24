class PlaceOption < BaseModel

  include ActsLikePlace
    # Instance: tz, validate_and_save!, image, coordinate, full, nearby, find_and_merge, meta_icon, 
              # alt_names, pinnable, not_in_usa?, in_usa?, other_info?, has_sources?, foursquare_rating, 
              # yelp_id, yelp_rating, tracking_data, tz_object, is?, hour_calculator
    # Class: att_by_frequency, find_or_initialize, center_coordinate, coordinates

  belongs_to :mark
  validates :mark, :mark_id, presence: :true
  has_many_polymorphic table: :flags
  has_many_polymorphic table: :images, name: :imageable

  enum feature_type: [:destination, :sublocality, :locality, :subregion, :region, :country, :area]

  default_scope { order('created_at ASC') }

  array_accessor :completion_step, :street_address, :name, :category, :meta_category, :phone
  json_accessor :hours, :extra

  delegate :open?, :open_again_at, :open_until, to: :hour_calculator

  def self.clean_old!
    where('created_at < ?', 1.month.ago).destroy_all
  end

  def self.from_datastore(ds, feature_type)
    option = new(ds.clean_attrs.merge(feature_type: feature_type))
    option.save(validate: false)

    ds.photos.each do |photo|
      photo.imageable = option
      photo.save_https!
    end

    option
  end

  def choose!
    place = complete
    
    unless place && place.is_a?(Place) && place.persisted?
      Flag.create(name: "Place couldn't be created!", details: "Completion failed during PlaceOption choosing", info: self.attributes)
      return false 
    end
    
    mark.update_attributes!(place_id: place.id)
    [images, flags].map{ |a| a.repoint!(place) }
    place
  end

  def duplicate(mark_id: nil)
    PlaceOption.new( generic_attrs.symbolize_keys.merge({ mark_id: mark_id }) )
  end

  private

  def generic_attrs
    attributes.except("mark_id", "id", "created_at", "updated_at")
  end

  def complete
    Completers::PlaceCompleter.new( generic_attrs ).complete!
  end
end