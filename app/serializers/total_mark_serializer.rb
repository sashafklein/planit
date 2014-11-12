class TotalMarkSerializer < ActiveModel::Serializer
  has_many :items, serializer: ItemSerializer
  has_one :user, serializer: UserSerializer
  has_one :place, serializer: PlaceSerializer

end