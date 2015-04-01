class MarkPlaceOptionsSerializer < ActiveModel::Serializer
  attributes :id

  has_many :place_options, serializer: PlaceOptionsSerializer
end
