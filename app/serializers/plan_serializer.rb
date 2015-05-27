class PlanSerializer < BaseSerializer
  attributes :id, :name, :created_at, :updated_at, :place_ids, :href, :best_image, :manifest, :user_id, :user, :collaborators, :latest_location_id, :locations
  delegate :best_image, :uniq_abbreviated_coords, to: :object

  has_many :collaborators, each_serializer: UserSerializer
  has_one :user, serializer: UserSerializer

  def place_ids
    object.places.pluck(:id)
  end

  def href
    object_path(object)
  end

  def locations
    hash = {}
    object.locations.each do |location|
      hash[ location.geoname_id ] = LocationSerializer.new( location, { root: false } ).as_json if location.geoname_id
      if location.admin_id_2
        admin2 = Location.where( geoname_id: location.admin_id_2 ).first
        hash[ admin2.geoname_id ] = LocationSerializer.new( admin2, { root: false } ).as_json if admin2 && admin2.geoname_id
      end
    end
    return hash
  end

end