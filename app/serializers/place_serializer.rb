class PlaceSerializer < BaseSerializer

  attributes  :id, :names, 
              :lat, :lon, 
              :street_addresses, :sublocality, :locality, :subregion, :region, :country,
              :phone, :phones, :website,
              :meta_categories, :categories,

              :images, 

              :menu, :mobile_menu, 
              :reservations, :reservations_link, :hours,

              :name, :altnames, :image_url, :image_source, :address, :locale, :href, :meta_icon,
              :savers, :lovers, :visitors, :guides, :fs_href

  has_many    :images

  def name
    object.names.first
  end

  def image_url
    image.try(:url)
  end

  def image_source
    image.try(:source)
  end

  def href
    object_path(object)
  end

  def savers
    Mark.savers( id )
  end

  def lovers
    Mark.lovers( id )
  end

  def visitors
    Mark.visitors( id )
  end

  def guides
    Mark.guides( id )
  end

  def fs_href
    object.foursquare_id ? "https://www.foursquare.com/v/#{object.foursquare_id}" : nil
  end

  private

  def image
    images.where.not(url: nil).first
  end

end