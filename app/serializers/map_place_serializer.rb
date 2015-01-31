class MapPlaceSerializer < ActiveModel::Serializer
  attributes :id, :lat, :lon, :names, :categories, :meta_categories, :sublocality, :locality, :region, :country

  has_many :images
  
  def coordinates
    [object.lat,object.lon]
  end

end