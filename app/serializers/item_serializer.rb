class ItemSerializer < ActiveModel::Serializer
  attributes :id, :updated_at_day
  has_one :plan, serializer: PlanSerializer
  has_one :mark, serializer: MarkSerializer

  def updated_at_day
    object.updated_at.strftime('%y%m%d')
  end
end