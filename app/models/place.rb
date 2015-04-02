class Place < BaseModel

  after_create { Place.import unless Rails.env.test? }
  
  boolean_accessor :published

  has_one :item
  has_many :marks, dependent: :destroy
  has_many_polymorphic table: :images, name: :imageable
  has_many_polymorphic table: :flags, options: {}
  has_many_polymorphic table: :shares
  has_many_polymorphic table: :notes

  array_accessor :completion_step, :street_address, :name, :category, :meta_category, :phone
  json_accessor :hours, :extra

  elastic_searchable columns_and_weights: ['names^10', 'categories', 'meta_categories'], fuzziness: 2

  validate!

  delegate :open?, :open_again_at, :open_until, to: :hour_calculator
  enum feature_type: [:destination, :sublocality, :locality, :subregion, :region, :country, :area]

  extend PlaceMod::Queries

  include ActsLikePlace
    # Instance: tz, validate_and_save!, image, coordinate, full, nearby, find_and_merge, meta_icon, 
              # alt_names, pinnable, not_in_usa?, in_usa?, other_info?, has_sources?, foursquare_rating, 
              # yelp_id, yelp_rating, tracking_data, tz_object, is?, hour_calculator
    # Class: att_by_frequency, find_or_initialize, center_coordinate, coordinates

  def savers
    Mark.savers( id )
  end

  def lovers
    Mark.savers( id )
  end

  def visitors
    Mark.savers( id )
  end

end