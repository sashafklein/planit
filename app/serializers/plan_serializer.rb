class PlanSerializer < BaseSerializer
  attributes :id, :name, :created_at, :updated_at, :place_ids, :href, :best_image, :manifest, :user_id, :user, :collaborators
  delegate :best_image, :uniq_abbreviated_coords, to: :object

  has_many :collaborators, each_serializer: UserSerializer
  has_one :user, serializer: UserSerializer

  def place_ids
    object.places.pluck(:id)
  end

  def href
    object_path(object)
  end

end