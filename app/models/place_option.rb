class PlaceOption < BaseModel

  include ActsLikePlace
    # Instance: tz, validate_and_save!, image, coordinate, full, nearby, find_and_merge, meta_icon, 
              # alt_names, pinnable, not_in_usa?, in_usa?, other_info?, has_sources?, foursquare_rating, 
              # yelp_id, yelp_rating, tracking_data, tz_object, is?, hour_calculator
    # Class: att_by_frequency, find_or_initialize, center_coordinate, coordinates

  belongs_to :mark
  validates :mark, :mark_id, presence: :true

  enum feature_type: [:destination, :sublocality, :locality, :subregion, :region, :country, :area]

  default_scope { order('created_at ASC') }

  array_accessor :completion_step, :street_address, :name, :category, :meta_category, :phone
  json_accessor :hours, :extra

  delegate :open?, :open_again_at, :open_until, to: :hour_calculator

  def self.clean_old!
    where('created_at < ?', 1.month.ago)
  end

  def choose!
    place = complete
    
    unless place && place.is_a?(Place) && place.persisted?
      Flag.create(name: "Place couldn't be created!", details: "Completion failed during PlaceOption choosing", info: self.attributes)
      return false 
    end
    
    mark.update_attributes!(place_id: place.id)
    place
  end

  private

  def complete
    Completers::PlaceCompleter.new( attributes.except("mark_id", "id", "created_at", "updated_at") ).complete!
  end
end