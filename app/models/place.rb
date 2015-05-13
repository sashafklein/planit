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

  def get_place_geoname
    response = HTTParty.get( geonames_url )
    return unless response = response['geonames']
    return unless response = response.first
    location = Location.find_by( geoname_id: response['geonameId'] )
    if location
      ObjectLocation.where({ obj_id: id, obj_type: 'Place', location_id: location.id }).first_or_create
    elsif response['name']
      location = Location.create_from_geonames!( response )
      ObjectLocation.where({ obj_id: id, obj_type: 'Place', location_id: location.id }).first_or_create
    else
      binding.pry
    end
    location.build_out_location_hierarchy
  end

  private

  def geonames_url
    "http://api.geonames.org/findNearbyPlaceNameJSON?lat=#{ lat }&lng=#{ lon }&featureClass=P&style=full&username=planit"
  end

end