class UserSerializer < ActiveModel::Serializer
  attributes :id, :first_name, :last_name, :name, :firstLetter, :email, :avatar

  def name
    object.name
  end

  def firstLetter
    object.name.match(/\A./).to_s.upcase()
  rescue; nil
  end

end