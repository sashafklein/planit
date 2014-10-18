class ItemSerializer < ActiveModel::Serializer
  attributes :id, :lat, :lon, :name

  delegate :lat, :lon, :name, to: :location
  def location
    object.location
  end
end
