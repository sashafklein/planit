class SearchMarkSerializer < BaseSerializer
  attributes :href, :id

  has_one :place, serializer: SearchPlaceSerializer

  def href
    object_path(object)
  end

end