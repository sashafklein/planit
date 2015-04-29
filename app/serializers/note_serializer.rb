class NoteSerializer < ActiveModel::Serializer
  attributes :id, :object_id, :body
  # has_one :source, serializer: UserSerializer

  def object_id
    object.object_id
  end

end