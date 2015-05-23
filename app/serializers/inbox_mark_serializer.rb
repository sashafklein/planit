class InboxMarkSerializer < ActiveModel::Serializer
  attributes :id, :user_id, :query, :created_at
  has_one :source

  delegate :query, to: :object

  def created_at
    object.created_at.strftime("%d/%m/%y")
  end

  def query
    {
      name: object.query.names.first,
      nearby: object.query.nearby
    }
  end
end
