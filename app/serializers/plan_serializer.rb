class PlanSerializer < BaseSerializer
  attributes :id, :name, :created_at, :updated_at, :place_ids, :href, :best_image, :manifest
  delegate :best_image, to: :object

  def place_ids
    object.places.pluck(:id)
  end

  def href
    object_path(object)
  end

end