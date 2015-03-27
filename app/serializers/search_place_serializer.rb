class SearchPlaceSerializer < BaseSerializer
  attributes :id, :name, :image_url, :image_source, :address, :locale, :href, :categories, :meta_icon, :country
  delegate :street_address, :sublocality, :locality, :subregion, :region, :country, :categories, :meta_icon, :meta_categories, to: :object

  has_many :images

  def name
    object.names.first
  end

  def image_url
    attrs.to_sh.only(:url, :source)
  end

  def image_source
    image.try(:source)
  end

  def image_url
    image.try(:url)
  end

  def address
    constructed_full_address || object.full_address
  end

  def locale
    constructed_locale
  end

  def href
    object_path(object)
  end

  private

  def image
    images.first
  end

  def constructed_full_address
    [street_address, sublocality].compact.join(", ")
  end

  def constructed_locale
    [locality, subregion].compact.uniq.concat([region]).compact.join(", ")
  end

end