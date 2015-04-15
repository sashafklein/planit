class NoteSerializer < ActiveModel::Serializer
  attributes :id, :body
  has_one :source, serializer: UserSerializer
end