class ItemSerializer < ActiveModel::Serializer
  attributes :id, :lat, :lon, :name, :image

  def image
    object.images.first
  end

  def location
    LocationSerializer.new(object.location)
  end
end
