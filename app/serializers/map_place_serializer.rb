class MapPlaceSerializer < ActiveModel::Serializer
  attributes :id, :lat, :lon, :names, :categories, :meta_categories, :sublocality, :locality, :region, :country, :meta_icon, :meta_category, :wifi, :open, :image, :images, :savers, :lovers, :visitors
  delegate   :meta_icon, :meta_category, to: :object
  
  has_many :images

  def coordinates
    [object.lat,object.lon]
  end

  def open
    object.open?
  end

  def image
    images.first
  end

  def savers
    Mark.savers( id )
  end

  def lovers
    Mark.lovers( id )
  end

  def visitors
    Mark.visitors( id )
  end

end