class JsUserSerializer < BaseSerializer
  attributes :id, :firstName, :lastName, :firstLetter, :slug, :name, :role

  root false

  def firstName
    object.first_name
  end

  def lastName
    object.last_name
  end

  def firstLetter
    object.name.match(/\A./).to_s.upcase()
  rescue; nil
  end

  def name
    object.name
  end

end