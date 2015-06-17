class Api::V1::LocationsController < ApiController

  def country_clusters
    permission_denied_error unless current_user
    permission_denied_error unless country_id = params[:country_id]
    
    @clusters = Cluster.where( country_id: country_id ).order( 'rank DESC' )
    render json: @clusters, each_serializer: ClusterSerializer
  end

  def find_with_geoname_object
    return permission_denied_error unless current_user
    return error unless data = params[:data]
    @location = Location.find_or_create_with_cluster( data )
    LocationMod::Clusterer.new( @location ).cluster if @location
    render json: @location, serializer: LocationAndClusterSerializer
  end

  def find_with_geoname_id
    return permission_denied_error unless current_user
    return error unless geoname_id = params[:geoname_id]
    @location = Location.find_or_create_with_cluster_via_geoname_id( geoname_id )
    LocationMod::Clusterer.new( @location ).cluster if @location
    render json: @location, serializer: LocationAndClusterSerializer
  end

end