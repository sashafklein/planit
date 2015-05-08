class UserSerializer < ActiveModel::Serializer
  attributes :id, :first_name, :last_name, :name, :email, :avatar

  def name
    object.name
  end
end