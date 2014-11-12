class PlaceSerializer < ActiveModel::Serializer
  attributes :id, :lat, :lon, :name, :street_address, :region, :locality, :country
end