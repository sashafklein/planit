class MapPlaceSerializer < ActiveModel::Serializer
  attributes :id, :lat, :lon, :names, :categories, :meta_categories, :sublocality, :locality, :region, :country, :meta_icon, :meta_category, :wifi, :open
  delegate   :meta_icon, :meta_category, to: :object

  has_many :images
  
  def coordinates
    [object.lat,object.lon]
  end

  def open
    object.open?
  end

end