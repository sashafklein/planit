class ItemSerializer < ActiveModel::Serializer
  attributes :id
  has_one :plan, serializer: PlanSerializer
  has_one :mark, serializer: MarkSerializer
end