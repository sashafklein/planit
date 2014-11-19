class ImageSerializer < ActiveModel::Serializer
  attributes :url, :source, :source_url, :subtitle
end