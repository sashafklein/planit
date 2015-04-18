class BaseSerializer < ActiveModel::Serializer

  def asset_path(path)
    ActionController::Base.helpers.asset_path(path)
  end

  def object_path(obj)
    path_data = obj.class == 'Plan' ? obj.id : obj
    Rails.application.routes.url_helpers.send( "#{obj.class.to_s.downcase}_path", path_data)
  end

  def encode(input, salt: 'Tinalp')
    Digest::SHA2.hexdigest("#{ salt }#{input}")
  end
end