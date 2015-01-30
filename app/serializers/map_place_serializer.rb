class MapPlaceSerializer < ActiveModel::Serializer
  attributes :id, :lat, :lon, :names, :images, :categories, :meta_categories

  def coordinates
    [object.lat,object.lon]
  end

end