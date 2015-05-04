class UserSerializer < ActiveModel::Serializer
  attributes :id, :first_name, :last_name, :name, :email

  def name
    object.name
  end
end