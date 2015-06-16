class ClusterSerializer < BaseSerializer

  attributes  :id, :name, 
              :lat, :lon, 

              # Pseudo/Non-Database Attributes
              :geonameId, :countryId

  def geonameId
    object.geoname_id
  end

  def countryId
    object.country_id
  end

end