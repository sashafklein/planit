class PlaceSerializer < ActiveModel::Serializer
  attributes :id, :lat, :lon, :names, :street_addresses, :region, 
             :locality, :country, :images, :menu, :mobile_menu, 
             :reservations, :reservations_link, :hours, :meta_categories

  has_many :images

  def coordinates
    [object.lat,object.lon]
  end

end