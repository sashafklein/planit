class PlanSerializer < BaseSerializer
  attributes :id, :name, :created_at, :updated_at, :place_ids, :href, :manifest

  def place_ids
    object.places.pluck(:id)
  end

  def href
    object_path(object)
  end

end