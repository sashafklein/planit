class NoteSerializer < ActiveModel::Serializer
  attributes :id, :obj_id, :body, :obj_type, :source_name

  def source_name
    object.source.try(:name)
  end
  # has_one :source, serializer: UserSerializer
end