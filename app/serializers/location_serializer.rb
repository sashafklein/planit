class LocationSerializer < ActiveModel::Serializer
  attributes :id, :asciiName, :adminName1, :countryName, :geonameId, :fcode, :lat, :lon

  def asciiName
    object.ascii_name
  end

  def adminName1
    object.admin_name_1
  end

  def countryName
    object.country_name
  end

  def geonameId
    object.geoname_id
  end

  def fcode
    object.fcode
  end

end