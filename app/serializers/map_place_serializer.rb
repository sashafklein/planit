class MapPlaceSerializer < ActiveModel::Serializer
  attributes :id, :lat, :lon, :names, :categories, :meta_categories, :sublocality, :locality, :region, :country, :meta_icon
  delegate   :meta_icon, to: :object

  has_many :images
  
  def coordinates
    [object.lat,object.lon]
  end

end