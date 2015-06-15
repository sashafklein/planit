class PlaceSerializer < BaseSerializer

  attributes  :id, :names, 
              :lat, :lon, 
              :street_addresses, :sublocality, :locality, :subregion, :region, :country,
              :phones, :website,
              :meta_categories, :categories,
              :foursquare_icon, :foursquare_id,

              # Details
              :wifi,

              # User-info
              :notes,
              :savers, :lovers, :visitors, :guides,

              # Pseudo/Non-Database Attributes
              :clusterId,
              :name, :altnames, :address, :locale, :meta_icon,
              :image_url, :image_source, 
              :fs_href

              # Removed
              # :href, hours,
              # :menu, :mobile_menu, 
              # :reservations, :reservations_link, 

  def clusterId
    cluster = object.locations.first.cluster
    return cluster.try( :id )
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

  # def href
  #   object_path(object)
  # end

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

  def notes
    hash = {}
    Mark.where( place_id: object.id ).find_each do |mark|
      hash[ mark.user_id ] = mark.notes.try( :first ).try( :body )
    end
    return hash
  end

  def fs_href
    object.foursquare_id ? "https://www.foursquare.com/v/#{object.foursquare_id}" : nil
  end

  private

  def image
    object.image
  end

end