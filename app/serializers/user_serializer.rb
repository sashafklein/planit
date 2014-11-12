class UserSerializer < ActiveModel::Serializer
  attributes :name, :email

  def name
    object.name
  end
end