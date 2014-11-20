class PlaceSerializer < ActiveModel::Serializer
  attributes :id, :lat, :lon, :names, :street_addresses, :region, :locality, :country, :images

  has_many :images
end