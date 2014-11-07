class MarkSerializer < ActiveModel::Serializer
  attributes :id, :lat, :lon, :name, :image

  def image
    object.images.first
  end

  def place
    PlaceSerializer.new(object.place)
  end
end
