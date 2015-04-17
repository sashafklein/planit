class PlaceSerializer < BaseSerializer

  attributes  :id, :names, 
              :lat, :lon, 
              :street_addresses, :sublocality, :locality, :subregion, :region, :country,
              :phone, :phones, :website,
              :meta_categories, :categories,

              :images, 

              :menu, :mobile_menu, 
              :reservations, :reservations_link, :hours, 

              :name, :image_url, :image_source, :address, :locale, :href, :meta_icon,
              :savers, :lovers, :visitors, :guides, :fs_href #, :mark

  delegate    :name,
              :street_address,
              :meta_icon, :meta_category, 
                to: :object

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

  def address
    constructed_full_address || object.full_address
  end

  def locale
    constructed_locale
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

  # def mark
  #   return nil unless scope
  #   object.marks.find_by user_id: scope.id
  # end

  private

  def image
    images.where.not(url: nil).first
  end

  def constructed_full_address
    [street_address, sublocality].compact.join(", ")
  end

  def constructed_locale
    ([(locality || subregion), (region || country)]).compact.join(", ")
  end


end