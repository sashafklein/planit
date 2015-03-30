class PlaceOptionsSerializer < BaseSerializer

  attributes    :id, :lat, :lon, :names, :street_addresses, :region, :subregion,
                :sublocality, :locality, :country, :images, :meta_categories, :categories,

                :name, :address, :locale, :image_url, :image_source,
                :meta_icon

  delegate      :meta_icon, to: :object

  has_many      :images

  def coordinates
    [object.lat,object.lon]
  end

  def name
    object.names.first
  end

  def image_url
    image.try(:url)
  end

  def image_source
    image.try(:source)
  end

  def address
    constructed_full_address || object.full_address
  end

  def locale
    constructed_locale
  end

  private

  def image
    images.first
  end

  def constructed_full_address
    [street_addresses[0], sublocality].compact.join(", ")
  end

  def constructed_locale
    [locality, subregion].compact.uniq.concat([region]).compact.join(", ")
  end

end