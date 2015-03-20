class JsUserSerializer < BaseSerializer
  attributes :id, :firstName, :lastName, :slug, :name, :role

  root false

  def firstName
    object.first_name
  end

  def lastName
    object.last_name
  end

  def name
    object.name
  end

end