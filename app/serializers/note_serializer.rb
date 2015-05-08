class NoteSerializer < ActiveModel::Serializer
  attributes :id, :obj_id, :body
  # has_one :source, serializer: UserSerializer
end