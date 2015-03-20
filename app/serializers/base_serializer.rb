class BaseSerializer < ActiveModel::Serializer

  def asset_path(path)
    ActionController::Base.helpers.asset_path(path)
  end

  def object_path(path)
    Rails.application.routes.url_helpers.send( "#{object.class.to_s.downcase}_path", object)
  end

  def encode(input, salt: 'Tinalp')
    Digest::SHA2.hexdigest("#{ salt }#{input}")
  end
end