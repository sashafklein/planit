class MarkSerializer < ActiveModel::Serializer
  attributes :id, :user_id, :coordinate, :name, :image, :place, :place_options

  delegate :name, :coordinate, :image, to: :object

  has_one :place, serializer: PlaceSerializer
end
