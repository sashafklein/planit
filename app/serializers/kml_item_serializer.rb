class KmlItemSerializer < ActiveModel::Serializer
  attributes :id
  has_one :plan, serializer: PlanSerializer
  has_one :mark, serializer: MarkSerializer
  has_many :notes, serializer: NoteSerializer
end