class LocationSerializer < ActiveModel::Serializer

  attributes :id, :name, :asciiName, :adminName1, :adminId1, :adminName2, :adminId2, :countryName, :countryId, :geonameId, :fcode, :lat, :lon, :isCluster, :clusterName, :clusterRank, :clusterId

  def cluster
    LocationMod::Clusterer.new( object ).cluster
    Cluster.find_by( geoname_id: object.geoname_id )
  end

  def clusterName
    cluster.try( :name )
  end

  def clusterRank
    cluster.try( :rank )
  end

  def clusterId
    object.cluster_id
  end

  def isCluster
    clusterName.present?
  end

  def asciiName
    object.ascii_name
  end

  def adminName1
    object.admin_name_1
  end

  def adminId1
    object.admin_id_1
  end

  def adminName2
    object.admin_name_2
  end

  def adminId2
    object.admin_id_2
  end

  def countryName
    object.country_name
  end

  def countryId
    object.country_id
  end

  def geonameId
    object.geoname_id
  end

end