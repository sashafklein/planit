class ItemSerializer < ActiveModel::Serializer
  has_one :plan, serializer: PlanSerializer
  has_one :mark, serializer: MarkSerializer
end