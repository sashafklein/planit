class MapPlaceSerializer < ActiveModel::Serializer
  attributes :id, :lat, :lon, :name, :names, :categories, :meta_categories, :sublocality, :locality, :region, :country, :meta_icon, :meta_category, :wifi, :open, :image, :images, :savers, :lovers, :visitors, :guides
  delegate   :meta_icon, :meta_category, to: :object
  
  has_many :images

  def name
    object.names.first
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

  def guides
    Mark.guides( id )
  end

end