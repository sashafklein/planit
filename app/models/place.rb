class Place < BaseModel

  boolean_accessor :published

  has_one :item
  has_many :marks, dependent: :destroy
  has_many_polymorphic table: :images, name: :imageable
  has_many_polymorphic table: :flags, options: {}
  has_many_polymorphic table: :shares
  has_many_polymorphic table: :notes

  has_many_polymorphic table: :object_locations
  has_many :locations, through: :object_locations, as: :obj
  
  array_accessor :completion_step, :street_address, :name, :category, :meta_category, :phone
  json_accessor :hours, :extra

  elastic_searchable columns_and_weights: ['names^10', 'categories', 'meta_categories'], fuzziness: 2

  validate!

  delegate :open?, :open_again_at, :open_until, to: :hour_calculator
  enum feature_type: [:destination, :sublocality, :locality, :subregion, :region, :country, :area]

  extend PlaceMod::Queries

  include ActsLikePlace

  def self.locations
    Location.where( id: object_locations.pluck(:location_id) )
  end
  
  def savers
    Mark.savers( id )
  end

  def lovers
    Mark.lovers( id )
  end

  def visitors
    Mark.visitors( id )
  end

  def guides
    Mark.guides( id )
  end

  def get_place_geoname!
    location = Location.find_or_create!( response: geonames_response, obj: self )
    location.build_out_location_hierarchy if location
    location
  end

  private

  def geonames_url
    "http://api.geonames.org/findNearbyPlaceNameJSON?lat=#{ lat }&lng=#{ lon }&featureClass=P&style=full&username=planit"
  end

  def geonames_response
    return @gr if @gr
    res = HTTParty.get( geonames_url )
    @gr = res.try(:[], 'geonames').try(:[], 0) || {}
  end

end