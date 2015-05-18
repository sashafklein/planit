class InboxMarkSerializer < ActiveModel::Serializer
  attributes :id, :user_id, :query, :created_at
  has_one :source

  delegate :query, to: :object

  def created_at
    object.created_at.strftime("%d/%m/%y")
  end
end
